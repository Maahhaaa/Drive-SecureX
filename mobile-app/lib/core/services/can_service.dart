import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CANMessage {
  final String canId;
  final double timestamp;
  final int byte1, byte2, byte3, byte4, byte5, byte6, byte7, byte8;
  final double timeDiff;
  final String label;

  CANMessage({
    required this.canId,
    required this.timestamp,
    required this.byte1,
    required this.byte2,
    required this.byte3,
    required this.byte4,
    required this.byte5,
    required this.byte6,
    required this.byte7,
    required this.byte8,
    required this.timeDiff,
    required this.label,
  });

  factory CANMessage.fromMap(Map map) => CANMessage(
    canId: (map['canId'] ?? map['can_id'])?.toString() ?? '0x0',
    timestamp: _toDouble(map['timestamp']),
    byte1: _toInt(map['byte1']),
    byte2: _toInt(map['byte2']),
    byte3: _toInt(map['byte3']),
    byte4: _toInt(map['byte4']),
    byte5: _toInt(map['byte5']),
    byte6: _toInt(map['byte6']),
    byte7: _toInt(map['byte7']),
    byte8: _toInt(map['byte8']),
    timeDiff: _toDouble(map['time_diff']),
    label: map['label']?.toString() ?? 'unknown',
  );
}

class CANStats {
  final double messageFrequency;
  final int totalMessages;
  final int dosCount;
  final int normalCount;
  final String? lastAlert;

  const CANStats({
    required this.messageFrequency,
    required this.totalMessages,
    required this.dosCount,
    required this.normalCount,
    this.lastAlert,
  });

  factory CANStats.fromMap(Map map) => CANStats(
    messageFrequency: _toDouble(map['message_frequency']),
    totalMessages: _toInt(map['total_messages']),
    dosCount: _toInt(map['dos_count']),
    normalCount: _toInt(map['normal_count']),
    lastAlert: map['last_alert']?.toString(),
  );
}

class CANService {
  static final _poller = _CANApiPoller(
    Uri.parse('http://kali.local:8000/latest'),
  );

  Stream<bool> connectedStream() {
    return _poller.stream.map((snapshot) => snapshot.isConnected).distinct();
  }

  // Live latest buffered attack messages from the API, capped with FIFO at 50.
  Stream<List<CANMessage>> messagesStream() {
    return _poller.stream.map((snapshot) => snapshot.messages);
  }

  Stream<List<CANMessage>> receivedMessagesStream() {
    return _poller.stream.map((snapshot) => snapshot.receivedMessages);
  }

  Future<List<CANMessage>> latestMessagesOnce() async {
    return (await _poller.fetchNow()).messages;
  }

  Stream<CANMessage?> latestMessageStream() {
    return _poller.stream.map((snapshot) => snapshot.latestMessage);
  }

  Future<CANMessage?> latestMessageOnce() async {
    return (await _poller.fetchNow()).latestMessage;
  }

  // only attack messages
  Stream<List<CANMessage>> alertsStream() {
    return messagesStream().map(
      (messages) => messages.where(_isAttackMessage).toList(growable: false),
    );
  }

  // stats (frequency, counts, last alert)
  Stream<CANStats> statsStream() {
    return _poller.stream.map((snapshot) => snapshot.stats);
  }

  Future<CANStats> latestStatsOnce() async {
    return (await _poller.fetchNow()).stats;
  }

  Future<void> blockAttack() {
    return _poller.blockAttack();
  }
}

class _CANApiSnapshot {
  final bool isConnected;
  final List<CANMessage> messages;
  final List<CANMessage> receivedMessages;
  final CANMessage? latestMessage;
  final CANStats stats;

  const _CANApiSnapshot({
    required this.isConnected,
    required this.messages,
    required this.receivedMessages,
    required this.latestMessage,
    required this.stats,
  });

  factory _CANApiSnapshot.disconnected([
    List<CANMessage> messages = const [],
    CANStats? stats,
    List<CANMessage> receivedMessages = const [],
  ]) {
    return _CANApiSnapshot(
      isConnected: false,
      messages: messages,
      receivedMessages: receivedMessages,
      latestMessage: null,
      stats: stats ?? _emptyStats,
    );
  }
}

class _CANApiPoller {
  static const _pollInterval = Duration(milliseconds: 500);
  static const _maxMessages = 50;

  final Uri endpoint;
  final http.Client _client;
  final StreamController<_CANApiSnapshot> _controller =
      StreamController<_CANApiSnapshot>.broadcast();

  Timer? _timer;
  _CANApiSnapshot _latest = _CANApiSnapshot.disconnected();
  final List<CANMessage> _messageBuffer = [];
  final List<CANMessage> _receivedMessageBuffer = [];
  final Set<String> _messageKeys = {};
  final Set<String> _receivedMessageKeys = {};

  _CANApiPoller(this.endpoint, {http.Client? client})
    : _client = client ?? http.Client() {
    _controller.onListen = _start;
    _controller.onCancel = _stopIfIdle;
  }

  Stream<_CANApiSnapshot> get stream async* {
    yield _latest;
    yield* _controller.stream;
  }

  Future<_CANApiSnapshot> fetchNow() => _fetchAndPublish();

  Future<void> blockAttack() async {
    final response = await _client.post(
      endpoint.replace(path: '/block_attack'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'API returned ${response.statusCode}',
        endpoint.replace(path: '/block_attack'),
      );
    }
  }

  void _start() {
    _timer ??= Timer.periodic(_pollInterval, (_) => _fetchAndPublish());
    unawaited(_fetchAndPublish());
  }

  void _stopIfIdle() {
    if (!_controller.hasListener) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<_CANApiSnapshot> _fetchAndPublish() async {
    try {
      final response = await _client.get(endpoint);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw http.ClientException(
          'API returned ${response.statusCode}',
          endpoint,
        );
      }

      final decoded = jsonDecode(response.body);
      final incomingMessages = _messagesFromApiValue(decoded);
      final latestMessage = incomingMessages.isEmpty
          ? _latest.latestMessage
          : incomingMessages.last;
      final receivedMessages = _mergeReceivedMessages(incomingMessages);
      final messages = _mergeMessages(incomingMessages);
      final stats = _statsFromMessages(receivedMessages, messages);
      _latest = _CANApiSnapshot(
        isConnected: true,
        messages: messages,
        receivedMessages: receivedMessages,
        latestMessage: latestMessage,
        stats: stats,
      );
    } catch (_) {
      _latest = _CANApiSnapshot.disconnected(
        _latest.messages,
        _latest.stats,
        _latest.receivedMessages,
      );
    }

    if (!_controller.isClosed) _controller.add(_latest);
    return _latest;
  }

  List<CANMessage> _mergeMessages(List<CANMessage> incoming) {
    for (final message in incoming) {
      final key = _messageKey(message);
      if (_messageKeys.contains(key) || !_isAttackMessage(message)) continue;

      _addBufferedMessage(message);
    }

    return List.unmodifiable(_messageBuffer);
  }

  List<CANMessage> _mergeReceivedMessages(List<CANMessage> incoming) {
    for (final message in incoming) {
      final key = _messageKey(message);
      if (_receivedMessageKeys.contains(key)) continue;

      _receivedMessageBuffer.add(message);
      _receivedMessageKeys.add(key);
      _receivedMessageBuffer.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      while (_receivedMessageBuffer.length > _maxMessages) {
        final removed = _receivedMessageBuffer.removeAt(0);
        _receivedMessageKeys.remove(_messageKey(removed));
      }
    }

    return List.unmodifiable(_receivedMessageBuffer);
  }

  void _addBufferedMessage(CANMessage message) {
    final key = _messageKey(message);
    if (_messageKeys.contains(key)) return;

    _messageBuffer.add(message);
    _messageKeys.add(key);
    _messageBuffer.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    while (_messageBuffer.length > _maxMessages) {
      final removed = _messageBuffer.removeAt(0);
      _messageKeys.remove(_messageKey(removed));
    }
  }
}

bool _isAttackMessage(CANMessage message) {
  return message.label.toLowerCase() != 'normal';
}

String _messageKey(CANMessage message) {
  return [
    message.timestamp,
    message.canId,
    message.byte1,
    message.byte2,
    message.byte3,
    message.byte4,
    message.byte5,
    message.byte6,
    message.byte7,
    message.byte8,
    message.timeDiff,
    message.label,
  ].join('|');
}

List<CANMessage> _messagesFromApiValue(Object? value) {
  final messagesValue = _extractMessagesValue(value);
  if (messagesValue is List) {
    return messagesValue
        .whereType<Map>()
        .map((e) => CANMessage.fromMap(Map.from(e)))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  if (messagesValue is Map) {
    if (_looksLikeMessage(messagesValue)) {
      return [CANMessage.fromMap(Map.from(messagesValue))];
    }
    return messagesValue.values
        .whereType<Map>()
        .map((e) => CANMessage.fromMap(Map.from(e)))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  return [];
}

Object? _extractMessagesValue(Object? value) {
  if (value is List) return value;
  if (value is! Map) return null;

  for (final key in ['can_messages', 'messages', 'data', 'latest']) {
    if (value.containsKey(key)) return value[key];
  }

  return _looksLikeMessage(value) ? value : null;
}

CANStats _statsFromMessages(
  List<CANMessage> messages, [
  List<CANMessage> attackMessages = const [],
]) {
  if (messages.isEmpty) return _emptyStats;

  final normalCount = messages
      .where((message) => message.label.toLowerCase() == 'normal')
      .length;
  final firstTimestamp = messages.first.timestamp;
  final lastTimestamp = messages.last.timestamp;
  final elapsed = lastTimestamp - firstTimestamp;

  return CANStats(
    messageFrequency: elapsed > 0 ? messages.length / elapsed : 0,
    totalMessages: messages.length,
    dosCount: attackMessages.length,
    normalCount: normalCount,
    lastAlert: attackMessages.isEmpty ? null : attackMessages.last.label,
  );
}

bool _looksLikeMessage(Map value) {
  return value.containsKey('can_id') ||
      value.containsKey('timestamp') ||
      value.containsKey('byte1');
}

const _emptyStats = CANStats(
  messageFrequency: 0,
  totalMessages: 0,
  dosCount: 0,
  normalCount: 0,
);

double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

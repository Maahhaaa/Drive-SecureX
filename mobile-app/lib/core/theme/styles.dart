import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static TextStyle get inter18bold => GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle get inter14medium => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get inter16medium =>GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get inter16semi => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle get inter32bold => GoogleFonts.inter(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle get inter12regular => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
  );
}

 # Drive-SecureX ML

Machine Learning module for **Drive-SecureX**, an Intrusion Detection System (IDS) for detecting cyber attacks on the CAN Bus network.

## Features

- Data preprocessing
- Feature engineering & feature selection (13 features)
- Model training and testing
- Multiple ML classifiers:
  - XGBoost
  - Decision Tree (DT)
  - Support Vector Machine (SVM)
  - K-Nearest Neighbors (KNN)
- Cross-vehicle validation

## Dataset

- DSX CAN Dataset (Train/Test)
- Kia Soul CAN-MIRGU Dataset (Validation)

## Tech Stack

- Python
- NumPy
- Pandas
- Scikit-learn
- XGBoost
- Matplotlib

## Workflow

```text
Dataset
   ↓
Preprocessing
   ↓
Feature Engineering & Selection (13 Features)
   ↓
Train / Test Split
   ↓
Train Models
   ├── XGBoost
   ├── Decision Tree (DT)
   ├── Support Vector Machine (SVM)
   └── K-Nearest Neighbors (KNN)
   ↓
Model Evaluation
   ↓
Validation on Kia Soul Dataset
```

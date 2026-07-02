<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=32&duration=3000&pause=1000&color=00C2CB&center=true&vCenter=true&width=700&lines=Drive-SecureX+ML;CAN+Bus+Intrusion+Detection+System;Powered+by+Machine+Learning+%F0%9F%9A%97" alt="Typing SVG" />

<br/>

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![XGBoost](https://img.shields.io/badge/XGBoost-Classifier-EB5B25?style=for-the-badge&logo=xgboost&logoColor=white)
![Scikit-learn](https://img.shields.io/badge/Scikit--learn-ML-F7931E?style=for-the-badge&logo=scikitlearn&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-Data-150458?style=for-the-badge&logo=pandas&logoColor=white)
![NumPy](https://img.shields.io/badge/NumPy-Array-013243?style=for-the-badge&logo=numpy&logoColor=white)

![Status](https://img.shields.io/badge/status-active-success?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)
![Made with Love](https://img.shields.io/badge/made%20with-%E2%9D%A4-red?style=flat-square)

</div>

<br/>

<p align="center">
<img src="https://user-images.githubusercontent.com/74038190/212284100-561aa473-3905-4a80-b561-0d28506553ee.gif" width="100%">
</p>

## 🚗 About the Project

**Drive-SecureX ML** is the machine learning core of **Drive-SecureX**, an Intrusion Detection System (IDS) built to detect cyber attacks on the **CAN Bus network** — the backbone communication protocol of modern vehicles. This module handles everything from raw CAN traffic to real-time-ready attack classification.

<br/>

## ✨ Features

<table align="center">
<tr>
<td align="center" width="200">🧹<br/><b>Data Preprocessing</b><br/><sub>Cleaning & structuring raw CAN traffic</sub></td>
<td align="center" width="200">🧪<br/><b>Feature Engineering</b><br/><sub>13 selected features</sub></td>
<td align="center" width="200">🤖<br/><b>Model Training</b><br/><sub>4 classifiers benchmarked</sub></td>
<td align="center" width="200">🔁<br/><b>Cross-Vehicle Validation</b><br/><sub>Generalization testing</sub></td>
</tr>
</table>

### 🧠 Classifiers

| Model | Icon | Role |
|---|---|---|
| **XGBoost** | 🚀 | High-performance gradient boosting |
| **Decision Tree (DT)** | 🌳 | Interpretable baseline |
| **Support Vector Machine (SVM)** | 📐 | Margin-based classification |
| **K-Nearest Neighbors (KNN)** | 📍 | Distance-based classification |

<br/>

## 📊 Datasets

<div align="center">

| Dataset | Purpose |
|---|---|
| 🗄️ **DSX CAN Dataset** | Train / Test |
| 🚙 **Kia Soul — CAN-MIRGU Dataset** | Cross-vehicle Validation |

</div>

<br/>

## 🛠️ Tech Stack

<div align="center">

![Python](https://skillicons.dev/icons?i=python)
&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/pandas/pandas-original.svg" width="48" title="Pandas"/>
&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/numpy/numpy-original.svg" width="48" title="NumPy"/>
&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/scikitlearn/scikitlearn-original.svg" width="48" title="Scikit-learn"/>
&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/matplotlib/matplotlib-original.svg" width="48" title="Matplotlib"/>

</div>

<br/>

## 🔄 Workflow

```mermaid
flowchart TD
    A([📦 Dataset]) --> B[🧹 Preprocessing]
    B --> C[🧪 Feature Engineering & Selection<br/><i>13 Features</i>]
    C --> D[✂️ Train / Test Split]
    D --> E{🤖 Train Models}
    E --> F1[🚀 XGBoost]
    E --> F2[🌳 Decision Tree]
    E --> F3[📐 SVM]
    E --> F4[📍 KNN]
    F1 --> G[📈 Model Evaluation]
    F2 --> G
    F3 --> G
    F4 --> G
    G --> H([🚙 Validation on Kia Soul Dataset])

    style A fill:#00C2CB,stroke:#00838a,color:#fff
    style H fill:#00C2CB,stroke:#00838a,color:#fff
    style E fill:#f4f4f4,stroke:#999
    style G fill:#ffe6a7,stroke:#cc9900
    style F1 fill:#ffd6d6,stroke:#cc3b3b
    style F2 fill:#d6f5d6,stroke:#3ba33b
    style F3 fill:#d6e4ff,stroke:#3b6bcc
    style F4 fill:#fff2cc,stroke:#cca300
```

<br/>

<p align="center">
<img src="https://user-images.githubusercontent.com/74038190/212284158-e840e285-664b-44d7-b79b-e264b5e54825.gif" width="100%">
</p>

<div align="center">

### 🚀 Get Started

```bash
git clone https://github.com/your-username/drive-securex-ml.git
cd drive-securex-ml
pip install -r requirements.txt
```

<br/>

⭐ **If this project helped you, consider giving it a star!** ⭐

</div>

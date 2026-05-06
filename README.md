# 📁 Smart File Sharing & Collaboration App

A **Flutter-based offline-first** Smart File Sharing and Collaboration application with Firebase integration, version tracking, and real-time collaboration features.

---

## 🚀 Features

- 🔐 **Firebase Authentication** — Secure email/password sign-in & sign-up
- 📂 **File Management** — Upload, view, delete, and organize files
- 🕓 **Version Tracking** — Track file versions with timestamps
- 💬 **Comments System** — Add and view comments on files
- 📴 **Offline-First Storage** — Full local persistence using Hive
- 🌐 **Connectivity Awareness** — Detects online/offline status
- 🎨 **Modern UI** — Dark-themed, animated UI with Google Fonts

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | Flutter Riverpod |
| Navigation | Go Router |
| Local Storage | Hive + Hive Flutter |
| Backend/Auth | Firebase Core + Firebase Auth |
| UI Enhancements | Flutter Animate, Google Fonts |
| Connectivity | Connectivity Plus |

---

## 📦 Project Structure

```
lib/
├── core/
│   ├── models/          # Data models (FileModel, VersionModel, Comment)
│   ├── providers/       # Riverpod state providers
│   ├── repositories/    # Data access layer
│   ├── services/        # Hive & Firebase services
│   └── theme/           # App theme & color scheme
├── features/
│   ├── auth/            # Login & Registration screens
│   ├── files/           # File list, upload, detail screens
│   ├── search/          # File search screen
│   └── shared/          # Shared files screen
├── widgets/             # Reusable widgets
├── app_router.dart      # GoRouter configuration
├── shell_scaffold.dart  # Bottom nav shell
└── main.dart            # App entry point
```

---

## 🏁 Getting Started

### Prerequisites
- Flutter SDK >= 3.3.0
- Dart SDK >= 3.3.0
- Firebase project configured

### Installation

```bash
# Clone the repository
git clone https://github.com/ShivamBhalodiya11/File_CollobrationApp.git

# Navigate to project directory
cd File_CollobrationApp

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📋 Commit History

| # | Commit | Description |
|---|--------|-------------|
| 1 | Project Initialization | Flutter project setup, pubspec.yaml, Firebase config, folder structure |
| 2 | UI Implementation | Screens, navigation, shell scaffold, theme, Google Fonts |
| 3 | Core Logic | File model, version tracking, comments, Riverpod providers |
| 4 | Offline Storage & Final Enhancements | Hive integration, connectivity, animations, final polish |

---

## 👨‍💻 Author

**Shivam Bhalodiya** — [@ShivamBhalodiya11](https://github.com/ShivamBhalodiya11)

---

## 📄 License

This project is for educational purposes as part of a Mobile Application Development course.

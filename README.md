# Automated College Timetable Management System

A comprehensive integrated system for managing college timetables with automatic generation, real-time updates, and role-based access control. This system consists of three main components: an automated timetable generator API, a student/teacher mobile application, and an admin management interface.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [System Architecture](#system-architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## 🎯 Project Overview

This is an enterprise-grade timetable management system designed for educational institutions. It provides:

- **Intelligent Timetable Generation**: Automated scheduling using constraint programming to avoid conflicts
- **Mobile Application**: Flutter-based cross-platform app for students and teachers
- **Admin Dashboard**: Flutter admin panel for system management and monitoring
- **Real-time Synchronization**: Firebase integration for live updates across all platforms
- **Role-Based Access**: Separate interfaces and permissions for students, teachers, and administrators

### Key Features

✅ Automated conflict-free timetable generation  
✅ Real-time notifications for schedule changes  
✅ Role-based authentication and authorization  
✅ Offline support with local caching  
✅ Cross-platform support (iOS, Android, Web)  
✅ RESTful API for timetable operations  

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Mobile Applications                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Teacher & Student Mobile App (Flutter)             │   │
│  │  - Authentication                                    │   │
│  │  - Timetable View                                    │   │
│  │  - Real-time Notifications                           │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Admin Dashboard (Flutter Web)                       │   │
│  │  - Timetable Management                              │   │
│  │  - User Management                                   │   │
│  │  - System Configuration                              │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
        ┌───────────▼─────────┐   ┌─────▼──────────────┐
        │    Firebase Cloud   │   │  Python Flask API  │
        │  - Authentication   │   │  - Timetable Gen   │
        │  - Realtime DB      │   │  - Constraints     │
        │  - Cloud Storage    │   │  - Optimization    │
        └─────────────────────┘   └────────────────────┘
```

### Component Interaction

1. **Mobile Apps** → Firebase (Authentication, realtime updates)
2. **Mobile Apps** → Flask API (Request timetable generation)
3. **Admin App** → Firebase (Manage users and configurations)
4. **Flask API** ← Firebase (Fetch parameters for generation)

---

## 📦 Prerequisites

### System Requirements

- **Operating System**: Windows, macOS, or Linux
- **RAM**: Minimum 8GB (16GB recommended)
- **Disk Space**: 10GB for all tools and projects

### Required Tools

#### For Flutter Applications (Mobile & Admin)

- **Flutter SDK**: v3.6.0 or higher ([Download](https://flutter.dev/docs/get-started/install))
- **Dart**: Included with Flutter
- **Android Studio** (for Android development)
  - Android SDK (API Level 21 or higher)
  - Android NDK
- **Xcode** (for iOS development - macOS only)
- **Visual Studio Code** or **Android Studio**

#### For Python Flask API

- **Python**: v3.8 or higher ([Download](https://www.python.org/downloads/))
- **pip**: Python package manager (included with Python)
- **Virtual Environment**: `venv` or `virtualenv`

#### Database & Authentication

- **Firebase Account**: Google account with Firebase project
- **Firebase CLI** (optional but recommended)

### Verify Installations

```bash
# Check Flutter
flutter --version

# Check Dart
dart --version

# Check Python
python --version
pip --version
```

---

## 📂 Project Structure

```
my project/
├── admin_app/                          # Admin Dashboard (Flutter)
│   ├── lib/
│   │   ├── main.dart                   # App entry point
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   │   ├── colors.dart
│   │   │   │   └── routes.dart
│   │   │   ├── models/
│   │   │   ├── services/
│   │   │   └── widgets/
│   │   └── features/
│   │       ├── auth/
│   │       ├── dashboard/
│   │       ├── teacher/
│   │       └── timetable/
│   ├── pubspec.yaml                    # Flutter dependencies
│   ├── firebase.json                   # Firebase configuration
│   └── README.md
│
├── Teacher_student_mobile_app/         # Mobile Application (Flutter)
│   ├── lib/
│   │   ├── main.dart                   # App entry point
│   │   ├── core/
│   │   │   ├── constants.dart
│   │   │   ├── errors/
│   │   │   └── utils/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── firebase/
│   │   │   ├── auth_service.dart
│   │   │   ├── firebase_service.dart
│   │   │   └── notification_service.dart
│   │   └── presentation/
│   │       ├── auth/
│   │       ├── student/
│   │       ├── teacher/
│   │       └── shared_widgets/
│   ├── android/                        # Android native code
│   ├── ios/                            # iOS native code
│   ├── pubspec.yaml                    # Flutter dependencies
│   ├── firebase.json                   # Firebase configuration
│   └── README.md
│
├── Timetable_Generation_Endpoint/      # Python Flask API
│   ├── app.py                          # Flask application
│   ├── generate_timetable.py           # Constraint solver
│   ├── requirements.txt                # Python dependencies
│   ├── pyproject.toml                  # Project configuration
│   └── README.md
│
└── README.md                           # This file
```

---

## 🚀 Setup Instructions

### Step 1: Clone/Download the Project

```bash
# Navigate to the project directory
cd "C:\Users\bhuva\OneDrive\Documents\my project"
```

### Step 2: Setup Flutter Applications

#### 2.1 Teacher/Student Mobile App

```bash
# Navigate to the mobile app directory
cd Teacher_student_mobile_app

# Get Flutter dependencies
flutter pub get

# (Optional) Clean previous builds
flutter clean
```

#### 2.2 Admin Dashboard App

```bash
# Navigate to the admin app directory
cd ../admin_app

# Get Flutter dependencies
flutter pub get

# (Optional) Clean previous builds
flutter clean
```

### Step 3: Setup Python Flask API

```bash
# Navigate to the API directory
cd ../Timetable_Generation_Endpoint

# Create a virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate

# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Step 4: Firebase Configuration

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Create a new project" or select an existing one
   - Note your Project ID

2. **Enable Services**:
   - Enable **Authentication** (Email/Password)
   - Enable **Realtime Database**
   - Enable **Cloud Firestore** (if using)
   - Enable **Cloud Storage**

3. **Configure Flutter Apps**:
   - Download `google-services.json` from Firebase Console
   - Place it in `Teacher_student_mobile_app/android/app/`
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `Teacher_student_mobile_app/ios/Runner/`

4. **Update Firebase Project ID**:
   - In `admin_app/lib/main.dart`, update:
     ```dart
     const projectId = "your-project-id";
     ```
   - In `Teacher_student_mobile_app/lib/firebase_options.dart`, ensure correct configuration

---

## ▶️ Running the Application

### Option A: Run All Components (Recommended)

#### Terminal 1: Start Python Flask API

```bash
cd Timetable_Generation_Endpoint

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Run Flask server
python app.py
```

The API will be available at `http://localhost:5000`

#### Terminal 2: Run Mobile App (Android)

```bash
cd Teacher_student_mobile_app

# Run on Android device/emulator
flutter run -d android

# Or specify device
flutter run -d emulator-5554
```

#### Terminal 3: Run Admin Dashboard (Web)

```bash
cd admin_app

# Run on Chrome/Web
flutter run -d chrome

# Or on Edge
flutter run -d edge
```

### Option B: Run Individual Components

#### Run Mobile App Only

```bash
cd Teacher_student_mobile_app
flutter run
# Select device when prompted
```

#### Run Admin App Only

```bash
cd admin_app
flutter run -d chrome
```

#### Run Flask API Only

```bash
cd Timetable_Generation_Endpoint
source venv/bin/activate  # or venv\Scripts\activate on Windows
python app.py
```

---

## 📡 API Documentation

### Timetable Generation Endpoint

**Endpoint**: `POST /generate-timetable`

**URL**: `http://localhost:5000/generate-timetable`

#### Request Format

```json
{
  "num_of_classrooms": 5,
  "num_of_labrooms": 2,
  "sections": [
    {
      "section_id": "CS-1A",
      "courses": [
        {
          "course_id": "CS101",
          "course_name": "Introduction to CS",
          "teacher_id": "T001",
          "type": "theory",
          "hours_per_week": 3
        },
        {
          "course_id": "CS102",
          "course_name": "Programming Lab",
          "teacher_id": "T002",
          "type": "lab",
          "hours_per_week": 2
        }
      ]
    }
  ],
  "teachers": [
    {
      "teacher_id": "T001",
      "name": "Dr. John Doe",
      "max_hours_per_day": 4
    }
  ]
}
```

#### Response Format (Success)

```json
{
  "status": "success",
  "timetable": {
    "CS-1A": {
      "Monday": [
        {
          "time_slot": "08:30-09:30",
          "course_id": "CS101",
          "course_name": "Introduction to CS",
          "teacher_id": "T001",
          "classroom": "Room-1",
          "type": "theory"
        }
      ],
      "Tuesday": [],
      "Wednesday": [],
      "Thursday": [],
      "Friday": [],
      "Saturday": []
    }
  },
  "constraints_satisfied": true
}
```

#### Response Format (Error)

```json
{
  "status": "failed",
  "message": "Error message explaining the issue",
  "error_details": {}
}
```

#### Constraints Handled

- ✅ No teacher conflict (same teacher in multiple sections at same time)
- ✅ Classroom availability limits
- ✅ Lab room availability limits
- ✅ No classes after 1:00 PM on Saturdays
- ✅ Classes between 8:30 AM - 4:00 PM
- ✅ 30-minute break from 10:30 AM - 11:00 AM
- ✅ Lab sessions in continuous 2-hour blocks
- ✅ Minimized idle periods

#### Example cURL Request

```bash
curl -X POST http://localhost:5000/generate-timetable \
  -H "Content-Type: application/json" \
  -d @request.json
```

---

## ⚙️ Configuration

### Firebase Configuration

#### Authentication Methods

Currently supported:
- Email/Password authentication

To add more methods:
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable desired providers (Google, Facebook, etc.)
3. Update mobile app auth providers in `firebase_service.dart`

#### Database Rules

Set appropriate Firestore security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    match /timetables/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

### Flutter App Configuration

#### Change API Endpoint

In `Teacher_student_mobile_app/lib/firebase/firebase_service.dart`:

```dart
const String apiEndpoint = "http://your-server:5000";
```

#### Change Firebase Project

Update in both apps:
- `admin_app/lib/main.dart`
- `Teacher_student_mobile_app/lib/firebase_options.dart`

### Python API Configuration

In `Timetable_Generation_Endpoint/app.py`:

```python
if __name__ == '__main__':
    app.run(
        debug=True,
        host='0.0.0.0',      # Change to expose publicly
        port=5000,           # Change port if needed
        ssl_context='adhoc'  # Enable HTTPS
    )
```

---

## 🛠️ Troubleshooting

### Flutter Issues

#### Issue: "Flutter command not found"

```bash
# Add Flutter to PATH (Windows)
$env:PATH += ";C:\path\to\flutter\bin"

# Or on macOS/Linux
export PATH="$PATH:/path/to/flutter/bin"

# Verify installation
flutter --version
```

#### Issue: "No devices found"

```bash
# List available devices
flutter devices

# Start Android emulator
emulator -list-avds
emulator -avd device-name

# For iOS, use Xcode's simulator
open -a Simulator
```

#### Issue: Dependency conflicts

```bash
# Clean and reinstall
flutter clean
flutter pub get

# Upgrade packages
flutter pub upgrade
```

### Python Issues

#### Issue: "Python not found"

```bash
# Verify Python installation
python --version

# Or use python3
python3 --version
```

#### Issue: Module not found

```bash
# Ensure virtual environment is activated
# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

# Reinstall requirements
pip install -r requirements.txt
```

#### Issue: Port 5000 already in use

```bash
# Find process using port 5000
# Windows
netstat -ano | findstr :5000

# macOS/Linux
lsof -i :5000

# Kill process or change port in app.py
```

### Firebase Issues

#### Issue: Authentication failing

1. Check Firebase project ID matches in apps
2. Verify Firebase rules allow read/write
3. Check internet connectivity
4. Clear app cache and reinstall

#### Issue: Realtime Database permissions denied

1. Go to Firebase Console → Realtime Database → Rules
2. Ensure rules allow authenticated users to read/write
3. For development, use test mode (allows all)

### API Integration Issues

#### Issue: App can't reach Python API

```bash
# Test API availability
curl http://localhost:5000/generate-timetable

# Check if server is running
# Windows: netstat -ano | findstr :5000
# macOS/Linux: lsof -i :5000

# For remote access, update API endpoint in app
# Change from localhost to server IP
```

---

## 📊 Performance Optimization

- **Mobile App**: Enable proguard/R8 for Android release builds
- **API**: Use caching for frequently generated timetables
- **Firebase**: Use indexes for frequently queried fields
- **Database**: Clean up expired notifications regularly

---

## 🔐 Security Considerations

1. **Never commit Firebase credentials** - Add to `.gitignore`
2. **Use environment variables** for sensitive data
3. **Enable SSL/TLS** for production API
4. **Implement rate limiting** for API endpoints
5. **Regular security audits** of Fire base rules
6. **Keep dependencies updated** for security patches

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Python Flask Documentation](https://flask.palletsprojects.com/)
- [Google OR-Tools Guide](https://developers.google.com/optimization)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture)

---

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/feature-name`
2. Commit changes: `git commit -am 'Add feature'`
3. Push to branch: `git push origin feature/feature-name`
4. Submit a Pull Request

---

## 📄 License

This project is proprietary and confidential.

---

## 📞 Support

For issues, questions, or support:
- Check the [Troubleshooting](#troubleshooting) section
- Review individual project README files
- Contact the development team

---

**Last Updated**: April 2026  
**Version**: 1.0.0

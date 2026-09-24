# 📚 Kitap Okuma — Flutter Book Reading App

A cross-platform book-reading companion built with **Flutter** and **Firebase**. Readers browse a book catalogue, keep favourites, follow a monthly reading list and manage their own shelf, while admins curate the catalogue.

## ✨ Features

- **Accounts** — e-mail / password sign-up and login with Firebase Authentication
- **Catalogue** — books with cover, author, page count, publish year and category (Cloud Firestore)
- **Book details** page
- **Favourites** and a personal **profile shelf**
- **Monthly reading list**
- **Admin panel** — separate admin login to add, edit and delete books

## 🧰 Tech stack

Flutter (Dart 3.5+) · Firebase Authentication · Cloud Firestore · flutter_dotenv

Firestore collections: `books`, `favorites`, `profile_books`, `monthly_books`

## 📁 Project structure

```text
lib/
├── main.dart             # App entry point and routes (/login, /home, /profile, /favorites)
├── firebase_options.dart # Firebase options read from .env
├── models/book.dart      # Book model and Firestore mapping
├── screens/              # login, register, home, book detail, favourites, profile,
│                         # monthly list, admin login / panel, add & edit book
├── widgets/book_card.dart
└── ultis/                # theme and constants
```

## 🚀 Getting started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.5 or newer).
2. Create a Firebase project and enable **Email/Password** authentication and **Cloud Firestore**.
3. Create a `.env` file in the project root:

   ```env
   FIREBASE_API_KEY=...
   FIREBASE_AUTH_DOMAIN=...
   FIREBASE_PROJECT_ID=...
   FIREBASE_STORAGE_BUCKET=...
   FIREBASE_MESSAGING_SENDER_ID=...
   FIREBASE_APP_ID=...
   FIREBASE_MEASUREMENT_ID=...
   ```

   Make sure `.env` is listed under `flutter: assets:` in `pubspec.yaml` and loaded with `await dotenv.load()` before `Firebase.initializeApp`.

4. Install the dependencies and run the app:

   ```bash
   flutter pub get
   flutter run
   ```

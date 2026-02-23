# PanchayatApp

A modern, transparent, and secure platform for the people of Bihar to report grievances directly to their local Panchayat officials.

## 🚀 Tech Stack

- **Frontend**: Flutter (Cross-platform)
- **State Management**: Riverpod 3.x (Notifier API)
- **Backend / Database**: Supabase (PostgreSQL)
- **Auth**: Supabase Auth (Google OAuth)
- **Storage**: Supabase Storage (Images & Videos)
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Optimization**: R8 Minification & Dart Obfuscation

## 🛡️ Security & Privacy

- **Row Level Security (RLS)**: Enabled on all patient tables to ensure users only access their own data or public posts.
- **Anonymous Reporting**: Users can choose to hide their identity for sensitive grievances.
- **Auto-Moderation**: Posts are automatically hidden after 5 reports for manual admin review.

## 📹 24h Video Policy

To optimize storage costs and performance:
- Videos uploaded to the `temp_videos` bucket are automatically deleted **24 hours** after upload.
- This is handled by a Supabase Edge Function and a database cron job.
- User-critical images are stored in `permanent_images`.

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (Stable channel)
- Android SDK & NDK (for production builds)
- A Supabase Project

### Initial Setup
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-repo/panchayat-app.git
    cd panchayat-app
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Configure Credentials**:
    Update `lib/core/app_constants.dart` with your Supabase URL and Anon Key.
4.  **Firebase Setup**:
    Add your `google-services.json` (Android) to `android/app/`.

### Running the App
- **Development**:
  ```bash
  flutter run
  ```
- **Production (Android APK)**:
  ```bash
  flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
  ```

## 🧠 Developer Notes

### Offline-First Architecture
The app follows a robust **Offline-First** logic:
- **Local Persistence**: All grievances are cached locally using **Hive**. This allows users to view their history and browse recent feed items without an active internet connection.
- **Sync Strategy**: When the user refreshes the feed, the app fetches fresh data from **Supabase** and updates the local Hive box atomically.
- **Resilience**: Even if Supabase is unreachable, the UI remains functional (Read-only mode) using the stale local data.

### Key Rotation & Security
To maintain a secure production environment, follow these steps if you need to rotate keys:
1.  **Supabase Keys**:
    - Navigate to `Settings -> API` in your Supabase dashboard.
    - Click **Roll Secret** for your service role or generate a new Anon Key.
    - Immediately update `lib/core/app_constants.dart` and redeploy.
2.  **Google OAuth**:
    - Update the **SHA-1** signatures in the Google Cloud Console if your signing key changes.
    - Download the new `google-services.json` and replace the existing one in `android/app/`.

## ❓ Troubleshooting

- **Google Login Fails**: Ensure `com.inaipanchayat.app://login-callback/` is added to your Supabase Redirect URLs.
- **Push Notifications**: Verify that the FCM token is generated in the console logs and that the device has internet access.
- **Build Errors**: Run `flutter clean` then `flutter pub get`.

---
Built with ❤️ for the people of Bihar.

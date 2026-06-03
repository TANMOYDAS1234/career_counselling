# Building EduBot (Android + iOS) without a Mac

The app talks to the live backend by default
(`https://career-counselling-backend-ku30.onrender.com`), so a build needs no
extra config to run. To override the backend (e.g. a local one):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

## Local builds (Windows/Linux can build Android; iOS needs macOS)

```bash
flutter pub get
flutter build apk --release          # Android → build/app/outputs/flutter-apk/app-release.apk
# iOS must be built on macOS:
flutter build ipa --release          # iOS  → build/ios/ipa/*.ipa  (needs Xcode + Apple signing)
```

## Cloud builds (you're on Windows → use these for iOS)

Both require the app to be pushed to a Git repo (e.g. GitHub).

### Option 1 — GitHub Actions (free) — `.github/workflows/build.yml`
Runs automatically on every push to `main`. Produces:
- **Android:** a real, installable `app-release.apk` (download from the run's *Artifacts*).
- **iOS:** an **unsigned** compile (`app-unsigned.ipa`) — this *proves the app builds on macOS* but **cannot be installed on a real iPhone** without signing.

### Option 2 — Codemagic (recommended for a real iOS app) — `codemagic.yaml`
1. Sign up at https://codemagic.io and connect this repo.
2. **android-workflow** → installable APK, zero setup.
3. **ios-workflow** → a **signed, installable `.ipa`** — but this needs a **paid
   Apple Developer account ($99/yr)**:
   - Codemagic → *Teams → Integrations → Apple Developer Portal* → add an
     **App Store Connect API key**, then put its name in `codemagic.yaml`
     (`app_store_connect: <name>`).
   - Pick `distribution_type`: `ad_hoc` (specific test devices), `development`,
     or `app_store`.

## The honest truth about iOS

Installing on a physical iPhone **always** requires Apple code-signing, which
**requires a paid Apple Developer account**. There is no free workaround for
device installs — this is Apple's rule, not a limitation of this project. The
free options above let you (a) ship Android to anyone today, and (b) confirm the
iOS app compiles. The moment you have an Apple Developer account, the Codemagic
`ios-workflow` produces an installable `.ipa`.

The iOS project itself is fully configured (photo/camera permissions, iOS 13
target, bundle id `com.edubot.careerCounsellingApp`) — nothing in the code needs
to change.

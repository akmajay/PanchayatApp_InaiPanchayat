---
description: How to deploy the PanchayatApp web version to Firebase Hosting
---

### 1. Install Firebase CLI
If you haven't installed it yet, run:
```bash
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Initialize Firebase in Project Root
Run this command and follow the prompts:
```bash
firebase init hosting
```
- **Select Project**: Choose "Create a new project" or "Use an existing project" (if you already created one in the Firebase Console).
- **Public Directory**: Type `build/web` (This is where Flutter builds its web files).
- **Configure as single-page app**: Type `y` (Yes).
- **Set up automatic builds/deploys with GitHub**: Type `n` (No, unless you want it).
- **Overwrite index.html?**: Type `n` (No! We already optimized yours).

### 4. Build the Production Web App
// turbo
```bash
flutter build web --release --base-href / --pwa-strategy offline-first
```

### 5. Deploy to Firebase
```bash
firebase deploy --only hosting
```

---
**Your app will be live at:** `https://your-project-id.web.app`

# Capabilities Configuration

## Analysis
Based on operation guide analysis, the following capabilities are required:
- Push Notifications (notification, reminder, alert keywords detected)
- In-App Purchase (subscription, premium, monthly, yearly keywords detected)
- Network access (email sending, Firebase backend)

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Push Notifications | ✅ Configured | Xcode Signing & Capabilities |
| In-App Purchase | ✅ Configured | Xcode Signing & Capabilities |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| Firebase Integration | ⏳ Pending | 1. Create Firebase project 2. Download GoogleService-Info.plist 3. Add to Xcode project 4. Enable Firestore, Cloud Functions, Auth in Firebase Console |
| APNs Certificate | ⏳ Pending | 1. Generate APNs key in Apple Developer Portal 2. Upload to Firebase Cloud Messaging settings |
| App Store Connect IAP | ⏳ Pending | 1. Create subscription group in App Store Connect 2. Configure monthly and yearly products 3. Set pricing and display names |

## No Configuration Needed

- HealthKit: Not required (no health data)
- Camera/Photo Library: Not required (file attachments handled via document picker)
- Location Services: Not required
- iCloud/CloudKit: Optional, not required for MVP
- Apple Watch: Not required
- Siri: Not required
- Background Modes: Only remote notifications needed (included with Push Notifications)

## Verification
- Build succeeded after configuration: ⏳ Pending (will verify after code generation)
- All entitlements correct: ⏳ Pending

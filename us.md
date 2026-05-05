# ApproveSnap - iOS Development Guide

## Executive Summary

ApproveSnap is a native iOS application designed for freelancers, small agencies, contractors, and small business owners (1-10 person teams) who need to get client approvals quickly and track them reliably. The app solves the critical pain point of approvals scattered across email chains, Slack, and WhatsApp by providing a centralized, mobile-first approval workflow with magic link sharing that requires no client login.

**Product Vision**: Become the fastest, simplest way for freelancers and small agencies to get client sign-off. No login required for clients. Full audit trail. Native iOS experience.

**Key Differentiators**:
- Only native iOS approval workflow app in the market
- Magic link sharing: clients approve with one click, no account needed
- Complete audit trail with timestamps and IP logging
- Deadline tracking with smart automatic reminders
- Priced at $9.99/mo vs competitors at $50+/mo
- Built for mobile-first workflows, not web-first with mobile wrapper

## Competitive Analysis

| App | Platform | Price | Strengths | Weaknesses | Our Advantage |
|-----|----------|-------|-----------|------------|---------------|
| ApproveThis | Web | $50/mo | 150+ templates, AI workflow, white-label, Zapier integrations | No iOS native app, expensive for freelancers, enterprise-focused | Native iOS, 80% cheaper, freelancer-focused, mobile-first |
| Markum | Web | $19/mo | Simple approval flow, affordable | No iOS app, basic features only, no audit trail | Native iOS, full audit trail, magic links, deadline tracking |
| Adobe Acrobat Sign | iOS+Web | Subscription | Industry standard e-signature, legal compliance | Document signing, not approval workflow, complex UI, enterprise pricing | Purpose-built for approvals, simple UX, no document signing overhead |
| Approval Studio | iOS+Web | $29/mo | Has iOS app, design review focused | Design-only approvals, not general purpose, expensive | General approval workflow, cheaper, broader use cases |
| Approval Donkey | Web | NZ$30/mo | Simple interface | Outdated UI, limited features, no mobile | Modern iOS design, more features, mobile-native |

## Apple Design Guidelines Compliance

- **Human Interface Guidelines**: Follow iOS navigation patterns (TabView, NavigationStack, Sheets)
- **Data Privacy**: Minimal data collection, no third-party analytics, local-first storage
- **App Store Review Guidelines 5.1.1**: Account deletion feature included in Settings
- **Push Notifications**: User-initiated only, clear opt-in flow with UNUserNotificationCenter
- **In-App Purchase**: StoreKit 2 implementation with proper restore purchases button
- **Accessibility**: VoiceOver support, Dynamic Type, semantic colors for dark mode
- **Background Modes**: Remote notifications only, no background fetch abuse
- **CryptoKit Usage**: AES-GCM for magic link encryption, no custom crypto

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (ShareSheet, ActivityViewController)
- **Data**: SwiftData (local persistence), CloudKit (optional sync)
- **Networking**: URLSession with async/await
- **Push**: UNUserNotificationCenter + APNs
- **Crypto**: CryptoKit (AES-GCM for magic links)
- **IAP**: StoreKit 2
- **File Preview**: QuickLook framework
- **Backend**: Firebase (Firestore, Cloud Functions, Auth) - server-side only

## Module Structure

```
ApproveSnap/
├── ApproveSnap/
│   ├── ApproveSnapApp.swift
│   ├── Views/
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift
│   │   │   └── DashboardViewModel.swift
│   │   ├── Projects/
│   │   │   ├── ProjectListView.swift
│   │   │   ├── ProjectDetailView.swift
│   │   │   ├── CreateProjectView.swift
│   │   │   └── ProjectViewModel.swift
│   │   ├── Approvals/
│   │   │   ├── ApprovalItemView.swift
│   │   │   ├── ApprovalDetailView.swift
│   │   │   └── ApprovalViewModel.swift
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   ├── ContactSupportView.swift
│   │   │   └── PaywallView.swift
│   │   └── Shared/
│   │       ├── StatusBadge.swift
│   │       ├── EmptyStateView.swift
│   │       └── CardView.swift
│   ├── Models/
│   │   ├── Project.swift
│   │   ├── ApprovalItem.swift
│   │   ├── AuditLog.swift
│   │   └── Comment.swift
│   ├── Services/
│   │   ├── MagicLinkService.swift
│   │   ├── ApprovalStateMachine.swift
│   │   ├── NotificationService.swift
│   │   ├── PurchaseManager.swift
│   │   └── DataService.swift
│   └── Assets.xcassets/
├── ApproveSnapTests/
└── ApproveSnapUITests/
```

## Implementation Flow

1. Set up SwiftData models (Project, ApprovalItem, AuditLog, Comment)
2. Build TabView navigation (Dashboard, Projects, Settings)
3. Implement Dashboard view with statistics and project cards
4. Build Project CRUD (Create, Read, Update, Delete)
5. Implement ApprovalItem management within projects
6. Build MagicLinkService with CryptoKit AES-GCM encryption
7. Implement ApprovalStateMachine for status transitions
8. Build NotificationService with deadline reminders
9. Implement PurchaseManager with StoreKit 2
10. Build PaywallView and subscription flow
11. Implement Settings with policy links and contact support
12. Add ContactSupportView with feedback backend
13. Polish UI with animations, haptics, and dark mode
14. Test on iPhone and iPad simulators

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: #007AFF (Apple Blue) - trust, professionalism
  - Success: #34C759 (Green) - approved status
  - Warning: #FF9500 (Orange) - pending status
  - Danger: #FF3B30 (Red) - rejected/expired status
  - Background: #F2F2F7 (iOS Light Gray)
  - Card: #FFFFFF (White)
- **Typography**: SF Pro system font, 17pt Semibold headings, 15pt Regular body, 13pt caption
- **Layout**: 16pt standard spacing, 12pt corner radius for cards, max width 720pt on iPad
- **Animations**: Standard iOS 0.25s ease-in-out, spring animations for status changes
- **Haptics**: UIImpactFeedbackGenerator (.medium) for approval actions
- **Dark Mode**: Full support with semantic colors
- **Accessibility**: VoiceOver labels, Dynamic Type, minimum touch target 44pt
- **Icons**: SF Symbols 5 throughout

## Code Generation Rules

- MVVM architecture: View binds to ViewModel, ViewModel operates on Model
- SwiftData for all persistence with @Model macro
- async/await for all asynchronous operations, no callback nesting
- Result type and custom Error enums for error handling
- Swift API Design Guidelines: camelCase variables, PascalCase types
- AES-GCM encryption for magic links with expiration
- Local-first: SwiftData primary, CloudKit optional sync
- UNUserNotificationCenter for all notifications
- StoreKit 2 for all In-App Purchases
- No third-party dependencies unless absolutely necessary
- All attributes in SwiftData models must be optional or have default values
- All relationships must have inverse relationships

## Build & Deployment Checklist

1. Verify Bundle ID: com.zzoutuo.ApproveSnap
2. Verify Deployment Target: iOS 17.0
3. Configure App Icon in Asset Catalog
4. Enable Push Notifications capability
5. Enable In-App Purchase capability
6. Configure StoreKit Configuration file for testing
7. Test on iPhone XS Max simulator
8. Test on iPad Pro 13-inch (M4) simulator
9. Verify dark mode on both devices
10. Verify VoiceOver accessibility
11. Push to GitHub repository
12. Deploy policy pages to GitHub Pages
13. Generate App Store screenshots
14. Submit to App Store Connect

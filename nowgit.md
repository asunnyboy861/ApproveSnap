# ApproveSnap - NowGit

## Repository
- **GitHub**: https://github.com/asunnyboy861/ApproveSnap
- **Owner**: asunnyboy861
- **Visibility**: Public
- **Default Branch**: main

## Project Overview
ApproveSnap is an iOS app that streamlines project approval workflows for freelancers and small agencies. It replaces messy email chains with structured approval tracking, magic link sharing, deadline reminders, and full audit trails.

## Tech Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **In-App Purchase**: StoreKit 2
- **Notifications**: UserNotifications
- **Encryption**: CryptoKit (AES-GCM for magic links)
- **Minimum Deployment**: iOS 17.0
- **Architecture**: MVVM

## Key Features
1. **Project Dashboard** - Overview of all approval projects with status tracking
2. **Approval Items** - Create, manage, and track individual approval items (documents, designs, milestones, links, text)
3. **Magic Link Sharing** - Generate encrypted, time-limited approval links for clients
4. **Deadline Tracking** - Set deadlines with automatic reminders (24h, 12h, 2h before)
5. **Audit Trail** - Complete history of all approval actions with timestamps
6. **Comments** - Threaded comments on approval items
7. **Approval State Machine** - Enforced valid status transitions (pending → approved/rejected/changes requested)
8. **Subscription Paywall** - Monthly ($9.99), Yearly ($99), Lifetime ($199.99)
9. **Contact Support** - In-app feedback submission

## Monetization
- **Free Tier**: 2 projects/month, basic approval, 7-day audit log
- **Pro Monthly**: $9.99/mo with 7-day free trial
- **Pro Yearly**: $99.00/yr (17% savings)
- **Lifetime**: $199.99 one-time purchase

## Policy Pages
- **Privacy Policy**: https://asunnyboy861.github.io/ApproveSnap/privacy.html
- **Terms of Use**: https://asunnyboy861.github.io/ApproveSnap/terms.html
- **Support Page**: https://asunnyboy861.github.io/ApproveSnap/support.html

## Build Instructions
1. Clone the repository
2. Open `ApproveSnap/ApproveSnap.xcodeproj` in Xcode 15+
3. Select "ApproveSnap" scheme and an iOS 17+ simulator
4. Build and run (Cmd+R)

## Project Structure
```
ApproveSnap/
├── ApproveSnap/
│   ├── ApproveSnap.xcodeproj
│   └── ApproveSnap/
│       ├── ApproveSnapApp.swift          # App entry point with SwiftData container
│       ├── ContentView.swift             # Main tab view
│       ├── Models/
│       │   ├── Project.swift             # Project model with status enum
│       │   ├── ApprovalItem.swift        # Approval item with type/status enums
│       │   ├── AuditLog.swift            # Audit trail model
│       │   └── Comment.swift             # Comment model
│       ├── Services/
│       │   ├── MagicLinkService.swift    # AES-GCM encrypted link generation
│       │   ├── ApprovalStateMachine.swift # State transition validation
│       │   ├── NotificationService.swift  # Push notification scheduling
│       │   ├── PurchaseManager.swift      # StoreKit 2 subscription management
│       │   └── DataService.swift          # CRUD operations with SwiftData
│       └── Views/
│           ├── Dashboard/DashboardView.swift
│           ├── Projects/
│           │   ├── ProjectListView.swift
│           │   ├── ProjectDetailView.swift
│           │   └── CreateProjectView.swift
│           ├── Approvals/
│           │   ├── ApprovalDetailView.swift
│           │   └── AddApprovalItemView.swift
│           ├── Settings/
│           │   ├── SettingsView.swift
│           │   ├── PaywallView.swift
│           │   └── ContactSupportView.swift
│           └── Shared/
│               ├── StatusBadge.swift
│               ├── EmptyStateView.swift
│               └── CardView.swift
├── capabilities.md
├── icon.md
├── price.md
├── us.md
└── nowgit.md
```

## Version History
- **v1.0.0** (2026-05-05) - Initial release with core approval workflow features

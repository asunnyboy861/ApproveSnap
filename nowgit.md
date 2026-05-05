# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | ApproveSnap |
| **Git URL** | git@github.com:asunnyboy861/ApproveSnap.git |
| **Repo URL** | https://github.com/asunnyboy861/ApproveSnap |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Item | Value |
|------|-------|
| **Source Folder** | `/docs` in main repository |
| **Deployment Method** | GitHub Pages from `/docs` folder |
| **GitHub Actions** | `.github/workflows/deploy.yml` |

### Deployed Pages

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/ApproveSnap/ | ✅ Active |
| Support | https://asunnyboy861.github.io/ApproveSnap/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/ApproveSnap/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/ApproveSnap/terms.html | ✅ Active |

**Note**: Terms of Use required for IAP subscription apps.

## Repository Structure

### Main App Repository
```
ApproveSnap/
├── ApproveSnap/                       # iOS App Source Code
│   ├── ApproveSnap.xcodeproj/         # Xcode Project
│   └── ApproveSnap/                   # Swift Source Files
│       ├── ApproveSnapApp.swift
│       ├── ContentView.swift
│       ├── Models/
│       │   ├── Project.swift
│       │   ├── ApprovalItem.swift
│       │   ├── AuditLog.swift
│       │   └── Comment.swift
│       ├── Services/
│       │   ├── MagicLinkService.swift
│       │   ├── ApprovalStateMachine.swift
│       │   ├── NotificationService.swift
│       │   ├── PurchaseManager.swift
│       │   └── DataService.swift
│       └── Views/
│           ├── Dashboard/DashboardView.swift
│           ├── Projects/
│           ├── Approvals/
│           ├── Settings/
│           └── Shared/
├── docs/                              # Policy Pages for GitHub Pages
│   ├── index.html                     # Landing Page
│   ├── support.html                   # Support Page
│   ├── privacy.html                   # Privacy Policy
│   └── terms.html                     # Terms of Use
├── .github/workflows/
│   └── deploy.yml                     # GitHub Pages deployment
├── us.md                              # English Development Guide
├── keytext.md                         # App Store Metadata
├── capabilities.md                    # Capabilities Configuration
├── icon.md                            # App Icon Details
├── price.md                           # Pricing Configuration
└── nowgit.md                          # This File
```

## Tech Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **In-App Purchase**: StoreKit 2
- **Notifications**: UserNotifications
- **Encryption**: CryptoKit (AES-GCM for magic links)
- **Minimum Deployment**: iOS 17.0
- **Architecture**: MVVM

## Monetization
- **Model**: Subscription (IAP)
- **Free Tier**: 2 projects/month, basic approval, 7-day audit log
- **Pro Monthly**: $9.99/mo with 7-day free trial
- **Pro Yearly**: $99.00/yr (17% savings)
- **Lifetime**: $199.99 one-time purchase

## Version History
- **v1.0.0** (2026-05-05) - Initial release with core approval workflow features

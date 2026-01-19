# Cleaner BoostEight

iOS application for managing media files: video compression, finding duplicates and similar photos, managing screenshots and screen recordings.

## Architecture

### Patterns Used

- **MVVM** - Model-View-ViewModel separation
- **Coordinator Pattern** - Navigation management (`AppCoordinator`, `MainCoordinator`, `VideoCompressorCoordinator`, `OnboardingCoordinator`)
- **Protocol-Oriented Programming** - All services implemented through protocols
- **Service Layer** - Business logic extracted into services
- **Dependency Injection** - Dependencies injected through initializers

### Design Principles

- **SOLID** principles
- **Composition over Inheritance**
- **Separation of Concerns** (UI / Presentation / Domain / Data layers)

### Technologies

- Swift, UIKit
- Combine (reactive programming)
- Async/Await (asynchronous operations)
- SnapKit (Auto Layout DSL)
- Photos framework
- AVFoundation

### Project Structure

```
App/                    # Entry point
Modules/                # Feature modules (Main, Media, VideoCompressor, etc.)
Sources/
  ├── Coordinators/    # Navigation
  ├── Services/        # Business logic
  ├── Models/          # Data models
  ├── UI/              # Reusable components
  └── Extensions/      # Extensions
Resources/              # Assets, fonts
```

### Key Services

- `VideoCompressionService` - Video compression
- `PhotoFetchService` - Photo library operations
- `MediaCountService` - Media counting
- `MediaCacheService` - Caching
- `PermissionService` - Permission management
- `DiskInfoService` - Disk space info
- `HapticService` - Haptic feedback
- `OnboardingService` - Onboarding flow

### Features

- Video compression with quality selection
- Duplicate photo detection
- Similar photos/videos detection
- Screenshot and screen recording management
- Live Photos management
- Disk space monitoring

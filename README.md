# Right Rudder

**Flight Training Management for Independent CFIs**

Right Rudder is a comprehensive iOS/iPadOS application designed specifically for independent Certified Flight Instructors (CFIs) to manage student records, track lesson progress, maintain compliance documentation, and collaborate with students.

## Overview

Right Rudder helps flight instructors:
- Manage multiple students and their training progress
- Create and assign lesson plans using customizable checklists
- Track student progress across different training categories (PPL, IFR, CPL, CFI, Reviews)
- Maintain FAA-compliant endorsement records
- Share progress and assignments with students via companion app
- Export student records and generate reports
- Work offline with CloudKit sync

## Quick Start

### For Developers

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd "Right Rudder"
   ```

2. **Open in Xcode**
   ```bash
   open "Right Rudder.xcodeproj"
   ```

3. **Build and Run**
   - Select a simulator (e.g., iPhone 15, iOS 18.0)
   - Build: `Cmd+B` or use `xcodebuild` (see `AGENTS.md`)

4. **Read the Playbook**
   - Start with [`AGENTS.md`](AGENTS.md) - the authoritative development guide
   - Review [`.cursor/rules/`](.cursor/rules/) for coding standards

### For Contributors

- **Development Standards**: See [`AGENTS.md`](AGENTS.md)
- **Code Organization**: See [`.cursor/rules/swift-code-organization.mdc`](.cursor/rules/swift-code-organization.mdc)
- **SwiftUI Guidelines**: See [`.cursor/rules/swiftui.mdc`](.cursor/rules/swiftui.mdc)
- **CloudKit Integration**: See [`.cursor/rules/cloudkit.mdc`](.cursor/rules/cloudkit.mdc)

## Project Structure

```
Right Rudder/
├── AGENTS.md                    # Development playbook (read this first!)
├── README.md                    # This file
├── PRD.md                       # Product Requirements Document
├── docs/                        # Documentation
│   └── review/                 # Project review documents
├── scripts/                     # Build and utility scripts
│   └── auto_increment_build.sh # Build number auto-increment script
├── .cursor/                     # Cursor IDE configuration
│   ├── commands/                # Cursor commands
│   └── rules/                   # Cursor rules (coding standards)
├── Right Rudder/                # Main app source code
│   ├── Models/                  # SwiftData models
│   ├── Views/                   # SwiftUI views
│   ├── Services/                # Business logic services
│   └── ...
└── Right Rudder.xcodeproj       # Xcode project
```

## Key Features

- **Student Management**: Track multiple students with detailed profiles
- **Checklist System**: Reference-based templates prevent duplication
- **Progress Tracking**: Calculate progress across training categories
- **CloudKit Integration**: Sync data across devices, share with students
- **Document Management**: Track student documents (certificates, medical, logbook)
- **Endorsement Management**: FAA-compliant endorsement scripts
- **Template Sharing**: Import/export checklist templates
- **Offline Support**: Queue operations when offline, sync when online

## Technology Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData with CloudKit
- **Backend**: CloudKit (iCloud)
- **Platforms**: iOS 17.6+, iPadOS 17.6+
- **Architecture**: MVVM with service layer

## Documentation

### Essential Reading
- [`AGENTS.md`](AGENTS.md) - Development playbook and standards
- [`PRD.md`](PRD.md) - Product requirements and feature specifications

### Project Review
- [`docs/review/PROJECT_REVIEW_INDEX.md`](docs/review/PROJECT_REVIEW_INDEX.md) - Start here for project review
- [`docs/review/PROJECT_REVIEW_BACKLOG.md`](docs/review/PROJECT_REVIEW_BACKLOG.md) - Prioritized work items

### Development Guides
- **Version Management**: See [`.cursor/rules/version-management.mdc`](.cursor/rules/version-management.mdc)
- **Code Organization**: See [`.cursor/rules/swift-code-organization.mdc`](.cursor/rules/swift-code-organization.mdc)
- **SwiftUI Best Practices**: See [`.cursor/rules/swiftui.mdc`](.cursor/rules/swiftui.mdc)
- **CloudKit Integration**: See [`.cursor/rules/cloudkit.mdc`](.cursor/rules/cloudkit.mdc)

## Building the Project

### Prerequisites
- macOS 26+ (or latest)
- Xcode 26.x (or latest)
- Apple Developer account (for CloudKit, optional for simulator builds)

### Build Commands

**Simulator Build (no code signing required):**
```bash
xcodebuild \
  -project "Right Rudder.xcodeproj" \
  -scheme "Right Rudder" \
  -sdk iphonesimulator \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=18.0' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build
```

See [`AGENTS.md`](AGENTS.md) for complete build and test instructions.

## Testing

- **Test Infrastructure**: Currently being set up (see backlog)
- **Coverage Goal**: 80% (currently 0%)
- **Test Targets**: `Right RudderTests`, `Right RudderUITests`

## Version Management

Right Rudder uses **Semantic Versioning** (MAJOR.MINOR.PATCH) with automatic build number increments.

- **Version**: Manual (e.g., `2.0.0`) - updated for releases
- **Build**: Automatic - increments with every build

See [`.cursor/rules/version-management.mdc`](.cursor/rules/version-management.mdc) for details.

## Contributing

1. Read [`AGENTS.md`](AGENTS.md) thoroughly
2. Follow code organization rules (see `.cursor/rules/`)
3. Ensure project builds successfully
4. Format code: `xcrun swift format --in-place --recursive "Right Rudder"`
5. Write tests for new features
6. Update documentation as needed

## App Store

- **App Store Link**: https://apps.apple.com/us/app/right-rudder/id6753633792
- **Current Version**: 1.6.1 (as of review)
- **Codebase Version**: 1.6.2

## License

[Add license information here]

## Support

[Add support/contact information here]

---

**Note**: This is a work in progress. See [`docs/review/PROJECT_REVIEW_BACKLOG.md`](docs/review/PROJECT_REVIEW_BACKLOG.md) for current priorities and known issues.


# AGENTS.md

Authoritative playbook for coding agents working on this iOS/iPadOS codebase. Follow it end-to-end before making changes.

---

## 1. Project Overview
- Native Apple-platform app (iOS + iPadOS). Assume Swift + SwiftUI unless a module explicitly indicates UIKit.
- Source lives at `/Users/nitewriter/Development/Right Rudder`. Run every command from this directory.
- The repository currently contains only scaffolding; expect future commits to add an Xcode workspace/project. Treat detection steps below as mandatory before editing code.

---

## 2. Environment & Toolchain
| Requirement | Notes |
| --- | --- |
| macOS 26+ | Matches host image; keep system patched. |
| Xcode 26.x | Install from App Store or `xcode-select --install`; accept license via `sudo xcodebuild -license`. |
| Command-line utilities | `xcodebuild`, `xcrun`, `simctl` ship with Xcode. |
| Formatting/Linting | Use Apple’s first-party `swift format` CLI (ships with Xcode 26) |

### Quick setup checklist
1. `xcode-select -p` → verify path. If missing: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`.
2. Clone repo and `cd /Users/nitewriter/Development/Right Rudder`.
3. Discover workspace/project (see next section) and run `xed <workspace|project>` to warm caches.
4. If the app later pulls third-party code, run that tool’s install command after inspecting the new files.

---

## 3. Discover Workspaces, Schemes, and Dependencies
Because the repo may evolve, agents must auto-detect the correct entry points before building:
```sh
cd /Users/nitewriter/Development/Right Rudder
ls -1 *.xcworkspace *.xcodeproj 2>/dev/null
```
- Prefer `.xcworkspace` (e.g., `App.xcworkspace`). If both exist, ensure the workspace references every package (SPM, CocoaPods).
- Capture the name for reuse: `export WORKSPACE=$(ls *.xcworkspace | head -n1)`.
- List schemes to find app + test targets: `xcodebuild -list -workspace "$WORKSPACE"`.
- If only `.xcodeproj` exists, set `PROJECT=<name>.xcodeproj` and adjust commands accordingly.

Dependency heuristics:
- This repo currently has no `Package.swift`, `Podfile`, `Gemfile`, or `Brewfile`; skip resolver commands unless those files appear in a future commit.
- If new dependency manifests show up, run the matching installer immediately and document the change in this file.

---

## 4. Build & Run
All examples assume `WORKSPACE` and `SCHEME` exports exist. Replace with real names after discovery.

```sh
# Debug simulator build (fails fast)
xcodebuild \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' \
  build | xcbeautify
```
- Use `DEVELOPER_DIR` if multiple Xcode versions are installed.
- Add `-allowProvisioningUpdates` only when signing for devices.
- Inspect available simulators via `xcrun simctl list devices`.

Reference: `xcodebuild` CLI supports `-scheme`, `-destination`, `-derivedDataPath`, and more for scripted automation.[^xcodebuild]

---

## 5. Testing, Coverage, and Static Analysis
```sh
# Unit/UI tests with coverage
xcodebuild \
  -workspace "$WORKSPACE" \
  -scheme "$TEST_SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' \
  -enableCodeCoverage YES \
  test | xcbeautify

# Lint + format (run if configs exist)
xcrun swift format --in-place . || true
xcrun swift format lint . || true
```
- `xcrun swift format` runs Apple’s first-party formatter and linter bundled with the toolchain; honor any repository `.swift-format.json` when it lands.
- Always run the `test` action with `-enableCodeCoverage YES` so CI can enforce minimum thresholds.[^xcodebuild]
- Prefer targeted runs during development: `xcodebuild test -only-testing:<Target>/<TestCase>`.
- If UI snapshots exist, re-record by passing `UI_TEST_RECORD=1` env vars defined by the project.
- Keep `DerivedData` clean when switching schemes: `xcodebuild clean` or `rm -rf ~/Library/Developer/Xcode/DerivedData`.

Quality gates for every PR:
1. `xcodebuild build` succeeds with zero warnings (treat warnings as failures).
2. `xcodebuild test` succeeds with coverage artifact uploaded (e.g., `.xcresult` zipped).
3. `swift format lint` passes or violations are triaged with inline comments.

---

## 6. UX, Accessibility, and Platform Guidelines
- Follow Apple’s Human Interface Guidelines for layout, typography, and platform-specific affordances; optimize for both compact (iPhone) and regular (iPad) size classes.[^hig]
- Ensure interfaces remain adaptive: adopt `SwiftUI`/`UIKit` responsive stacks, use Dynamic Type, support pointer/keyboard where applicable.
- Accessibility checklist:
  - Provide `accessibilityLabel`, `accessibilityHint`, and `accessibilityTraits`.
  - Validate contrast with SF Symbols and system colors.
  - Test using `xcrun simctl ui` VoiceOver toggles or the Accessibility Inspector.
- Localization: wrap strings with `NSLocalizedString` or `String(localized:)`; keep `.strings` synchronized after copy changes.

Recommended SwiftUI refresher: `SwiftUI by Example` offers composable recipes for layout, async data flow, and modifiers—use it to stay idiomatic when building new surfaces.[^swiftui]

---

## 7. Engineering Principles (applies to every change)
- **DRY – Don’t Repeat Yourself:** Centralize each piece of knowledge behind a single abstraction; factor duplicated UI/state into view models or reusable views to minimize divergent fixes.[^dry]
- **SOLID:** Favor small types with a single responsibility, keep modules open for extension/closed for modification, honor substitutability (protocol-first APIs), prefer lean interfaces, and invert dependencies via protocols + DI containers.[^solid]
- **YAGNI – You Aren’t Gonna Need It:** Ship the smallest slice that solves today’s requirement; defer speculative APIs or feature flags until there’s a validated need.[^yagni]
- Embrace functional patterns where practical: pure reducers, immutable models, async sequences for side effects.

---

## 8. Code Review & PR Checklist
Before opening a PR:
1. ✅ Workspace/scheme commands documented in the PR description if new targets were added.
2. ✅ `xcodebuild build` and `xcodebuild test -enableCodeCoverage YES` logs attached (or CI link).
3. ✅ Screenshots/video for UI changes (iPhone + iPad + dark mode).
4. ✅ Accessibility impact noted (VoiceOver labels, Dynamic Type proof).
5. ✅ New logic covered by unit/UI tests; updated tests for regressions.
6. ✅ `swift format` (both format and lint) executed; no violations ignored without justification.
7. ✅ DRY/SOLID/YAGNI considerations documented when architectural decisions deviate from defaults.

Reviewers should block merges if any checkbox is missing.

---

## 9. Troubleshooting & Tips
- **Simulator fails to boot:** `xcrun simctl shutdown all && xcrun simctl erase all`.
- **Provisioning/signing issues:** Run `xcodebuild -showBuildSettings | grep -e PROVISIONING_PROFILE -e CODE_SIGN` to confirm values and ensure the correct team ID is selected in Xcode.
- **Stuck DerivedData:** `rm -rf ~/Library/Developer/Xcode/DerivedData && xcodebuild clean`.
- **Performance profiling:** Use Instruments (`open -a "Instruments.app"`) and capture traces before optimizing.

---

## 10. Maintaining This Document
- Update workspace/scheme examples whenever new targets land.
- Expand the Testing section with concrete names (e.g., `AppTests`) once the codebase exists.
- Keep references fresh—note Xcode or iOS SDK version bumps inline.

---

### References
[^xcodebuild]: `xcodebuild` manual – supported flags for build/test automation. https://keith.github.io/xcode-man-pages/xcodebuild.1.html
[^hig]: Apple Human Interface Guidelines – core UX rules for Apple platforms. https://developer.apple.com/design/human-interface-guidelines
[^swiftui]: Hacking with Swift – SwiftUI by Example reference patterns. https://www.hackingwithswift.com/quick-start/swiftui
[^dry]: “Don’t repeat yourself” principle. https://en.wikipedia.org/wiki/Don%27t_repeat_yourself
[^solid]: SOLID object-oriented design principles. https://en.wikipedia.org/wiki/SOLID
[^yagni]: “You aren’t gonna need it” principle. https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it
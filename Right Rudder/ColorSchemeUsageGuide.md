# Color Scheme Usage Guide

## Available Color Schemes

1. **Sky Blue** - Clear skies and bright horizons (Default)
2. **Aviation Orange** - Classic aviation warmth
3. **Professional Navy** - Professional and trustworthy
4. **Forest Green** - Natural and grounded

## How to Use

### Option 1: Use Static Color Extensions (Recommended)

```swift
// Primary color for main UI elements, buttons, navigation
.foregroundColor(.appPrimary)
.background(Color.appPrimary)

// Secondary color for accents and highlights
.foregroundColor(.appSecondary)

// Accent color for important actions
.foregroundColor(.appAccent)

// Background color for cards and sections
.background(Color.appBackground)

// Muted box color for content boxes, text editors
.background(Color.appMutedBox)

// Text color
.foregroundColor(.appText)
```

### Option 2: Use AppColorScheme Directly

```swift
@AppStorage("selectedColorScheme") private var selectedColorScheme = AppColorScheme.skyBlue.rawValue

var currentScheme: AppColorScheme {
    AppColorScheme(rawValue: selectedColorScheme) ?? .skyBlue
}

// Then use:
.foregroundColor(currentScheme.primaryColor)
.background(currentScheme.backgroundColor)
```

### Option 3: Use Custom Button Style

```swift
Button("Action") {
    // action
}
.buttonStyle(.app) // Uses AppButtonStyle with primary color
```

## Examples

### Button with Primary Color
```swift
Button(action: {
    // action
}) {
    Text("Primary Action")
        .foregroundColor(.white)
        .padding()
        .background(Color.appPrimary)
        .cornerRadius(8)
}
```

### Card with Background Color
```swift
VStack {
    // content
}
.padding()
.background(Color.appBackground)
.cornerRadius(12)
```

### Text with Accent
```swift
Text("Important Info")
    .foregroundColor(.appAccent)
    .fontWeight(.bold)
```

### Text Editor with Muted Box
```swift
TextEditor(text: $comments)
    .frame(minHeight: 100)
    .padding(8)
    .background(Color.appMutedBox)
    .cornerRadius(8)
```

## Color Accessibility

All color schemes have been designed with:
- **High contrast** between text and backgrounds
- **WCAG AA compliance** for readability
- **Professional appearance** suitable for aviation apps
- **Complementary colors** that work well together

## Changing Colors

Colors automatically update throughout the app when user selects a different scheme in Settings.


---
name: add-feature-skill
description: >
  Guide for adding new features to PasteForge. Covers architecture,
  extension points, patterns, and build process.
---

## Overview

PasteForge is a macOS menu bar app that reads the current clipboard text and provides 37 one-click text transforms across 5 categories (Case, Encode, Format, Hash, Stats). Click a transform to see the result and copy it to the clipboard.

## Architecture

PasteForge is a single-file SwiftUI menu bar app (`PasteForge.swift`, ~744 lines). It uses the `@main` struct `PasteForgeApp` with a `MenuBarExtra(.window)` scene. One `@Observable` class owns all mutable state:

- **`ClipboardManager`** -- polls the clipboard every 1 second, tracks the current text, selected category, search query, selected transform, and result. Applies transforms and copies results back to the clipboard.

It is held as a `@State` property on `ContentView`.

## Key Types

| Type | Kind | Description |
|------|------|-------------|
| `PFTheme` | enum | Static color constants for the dark UI theme, including per-category colors |
| `TransformCategory` | enum | CaseIterable with 6 values: all, caseChange, encode, format, hash, stats. Each has a color and icon. |
| `Transform` | struct | Identifiable transform with name, icon, category, and `apply: (String) -> String` closure |
| `Transforms` | enum | Static `all` array containing all 37 transform definitions |
| `ClipboardManager` | @Observable class | All mutable state: clipboard text, polling timer, category filter, search, selected transform, result |
| `TransformRow` | View | Single row in the transform list with icon, name, and category badge |
| `CategoryChip` | View | Tappable filter chip with icon, label, and count |
| `ResultView` | View | Displays transform result with copy button and character count |
| `ContentView` | View | Root popup view with clipboard preview, search, category chips, transform list, and result |
| `PasteForgeApp` | @main App | MenuBarExtra with .window style and scissors icon |

## How to Add a Feature

### Adding a New Transform

This is the most common extension. Add a new `Transform(...)` entry to the `Transforms.all` array:

```swift
Transform(name: "My Transform", icon: "sf.symbol.name", category: .format) { input in
    // Pure function: String -> String
    return input.doSomething()
}
```

If the transform needs a helper function, add it as a `static func` on the `Transforms` enum.

### Adding a New Category

1. Add a case to `TransformCategory` with a `rawValue` label.
2. Add a color in the `color` computed property (and optionally add a `PFTheme.categoryX` constant).
3. Add an SF Symbol in the `icon` computed property.
4. Add transforms that use the new category to `Transforms.all`.

### Adding New State

Add properties to `ClipboardManager`. This is the single source of truth. Examples:
- Transform history --> add an array property, append on each apply
- Favorites --> add a `Set<String>` of transform names, persist with `@AppStorage`
- Clipboard history --> add an array, append in the polling timer callback

### Adding a New View Section

Insert in the `ContentView` `VStack` between existing sections. Use `PFTheme` colors for all styling. Separate sections with `Divider().overlay(PFTheme.border)`.

### Adding a New View Component

Create a new `struct MyView: View` following the pattern of `TransformRow`, `CategoryChip`, or `ResultView`. Pass data via init parameters or `@Binding`.

## Extension Points

- **New transforms** -- add entries to `Transforms.all` with a category, icon, and pure `(String) -> String` function
- **New categories** -- add to `TransformCategory` enum with color and icon
- **Transform chaining** -- add a queue/pipeline that applies multiple transforms in sequence
- **Clipboard history** -- extend the polling timer to maintain a history array
- **Favorites** -- add a favorites set, filter/sort by favorites, persist with `@AppStorage`
- **Custom transforms** -- add a UI for user-defined regex or string replacement transforms
- **Global hotkey** -- use the `KeyboardShortcuts` SPM package (requires graduating to Swift Package)

## Conventions

- **Theme**: All colors come from `PFTheme` static properties. Each category has its own color (e.g., `PFTheme.categoryCase`, `PFTheme.categoryEncode`). Use `PFTheme.bg` for backgrounds, `PFTheme.surface` for cards.
- **Pure transforms**: Every transform is a pure `(String) -> String` function with no side effects. This makes them trivially testable. Follow this pattern for all new transforms.
- **Category chips**: The horizontal chip row auto-counts transforms per category. Adding a new transform to a category automatically updates the chip count.
- **SF Symbols**: Used for all icons. Each transform has its own icon, and each category has a distinct icon.
- **Polling**: Clipboard is polled every 1 second via `Timer.scheduledTimer`. Changes are detected by comparing text content. Non-text clipboard returns nil gracefully.
- **Result display**: When a transform is selected, `ResultView` shows the output with a copy button. The result updates live if clipboard text changes.
- **CryptoKit**: Hash transforms use `Insecure.MD5`, `Insecure.SHA1`, and `SHA256` from CryptoKit (not deprecated CommonCrypto).

## Build & Test

```bash
bash build.sh             # Compiles PasteForge.swift and creates PasteForge.app bundle
open PasteForge.app       # Run the app (appears in menu bar)
swift test_transforms.swift  # Run transform unit tests (34 tests)
```

Requires macOS 14.0+ and Xcode command-line tools. The app runs as `LSUIElement` (no Dock icon).

## Homebrew Install

```bash
brew tap scasella/tap
brew install --cask pasteforge
```

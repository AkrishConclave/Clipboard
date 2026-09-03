## 2024-05-27 - Added Keyboard Shortcut to Login
**Learning:** Adding `.keyboardShortcut(.defaultAction)` to main primary buttons (like Login) drastically improves keyboard accessibility and aligns with expected macOS behaviors, without requiring extra custom logic or styling.
**Action:** When creating forms with primary submission buttons in SwiftUI, consider adding a `.defaultAction` keyboard shortcut to make it submit on Return/Enter.
## 2024-05-18 - Clipboard Action Feedback
**Learning:** Clipboard copy actions require explicit visual confirmation. Since the system pasteboard doesn't provide default feedback, users can be unsure if a click succeeded, leading to repeated clicks and degraded UX.
**Action:** Always provide inline, temporary visual feedback (e.g., checkmark icon + updated tooltip) immediately upon successful clipboard copy operations.
## 2024-11-26 - SwiftUI macOS Toolbar Buttons Consistency
**Learning:** For SwiftUI toolbar buttons on macOS, prefer using `Label` with system images and `.help()` modifiers over plain `Text`. This ensures the system can adapt the button display (icon, text, or both) based on user preferences and provides crucial context for screen readers and tooltips.
**Action:** Always check toolbar items for plain `Text` definitions and upgrade them to `Label` components with `.help()` tooltips to align with native macOS standards.
## 2026-09-03 - Accessible Icon-Only Buttons & Empty States in SwiftUI List Views
**Learning:** In macOS list views (and SwiftUI generally), using plain `Image(systemName:)` for icon-only buttons lacks semantic meaning for screen readers, even with a `.help()` tooltip. Additionally, basic text like "No items" feels unpolished and non-informative in a native macOS app.
**Action:** Consistently use `Label("Action", systemImage: "icon").labelStyle(.iconOnly)` for icon-only buttons to ensure they are fully accessible to VoiceOver. For list empty states, always use a visually polished `VStack` combining a relevant system icon and descriptive text.

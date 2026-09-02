## 2024-05-27 - Added Keyboard Shortcut to Login
**Learning:** Adding `.keyboardShortcut(.defaultAction)` to main primary buttons (like Login) drastically improves keyboard accessibility and aligns with expected macOS behaviors, without requiring extra custom logic or styling.
**Action:** When creating forms with primary submission buttons in SwiftUI, consider adding a `.defaultAction` keyboard shortcut to make it submit on Return/Enter.
## 2024-05-18 - Clipboard Action Feedback
**Learning:** Clipboard copy actions require explicit visual confirmation. Since the system pasteboard doesn't provide default feedback, users can be unsure if a click succeeded, leading to repeated clicks and degraded UX.
**Action:** Always provide inline, temporary visual feedback (e.g., checkmark icon + updated tooltip) immediately upon successful clipboard copy operations.

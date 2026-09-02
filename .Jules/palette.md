## 2024-05-27 - Added Keyboard Shortcut to Login
**Learning:** Adding `.keyboardShortcut(.defaultAction)` to main primary buttons (like Login) drastically improves keyboard accessibility and aligns with expected macOS behaviors, without requiring extra custom logic or styling.
**Action:** When creating forms with primary submission buttons in SwiftUI, consider adding a `.defaultAction` keyboard shortcut to make it submit on Return/Enter.

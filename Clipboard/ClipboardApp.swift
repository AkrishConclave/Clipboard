//
//  ClipboardApp.swift
//  Clipboard
//
//  Created by Ринат Панкратов on 24.11.2024.
//

import SwiftUI
import AppKit

@main
struct ClipboardManagerApp: App {
    @StateObject private var clipboardManager = ClipboardManager()
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
                    .environmentObject(clipboardManager)
                    .onAppear {
                        adjustWindowSize()
                    }
            } else {
                LoginView()
                    .onAppear {
                        adjustWindowSize()
                    }
            }
        }
    }

    private func adjustWindowSize() {
        // Получаем окно из приложения
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.setContentSize(NSSize(width: 300, height: 400)) // Устанавливаем размер окна
                window.minSize = NSSize(width: 300, height: 400)      // Минимальный размер
                window.maxSize = NSSize(width: 300, height: 400)      // Максимальный размер
            }
        }
    }
}

class ClipboardManager: ObservableObject {
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount = 0
    // Bolt Optimization: Work item for debouncing network syncs
    private var syncWorkItem: DispatchWorkItem?

    @Published var items: [String] = []
    @Published var pinnedItems: [String] = [] // Закреплённые элементы

    init() {
        monitorClipboard()
    }

    func monitorClipboard() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.pasteboard.changeCount != self.lastChangeCount {
                self.lastChangeCount = self.pasteboard.changeCount

                // 🛡️ Sentinel: Ignore sensitive clipboard data (passwords)
                if let types = self.pasteboard.types {
                    let sensitiveTypes: [NSPasteboard.PasteboardType] = [
                        .init("org.nspasteboard.ConcealedType"),
                        .init("org.nspasteboard.TransientType"),
                        .init("com.agilebits.onepassword")
                    ]

                    for type in sensitiveTypes {
                        if types.contains(type) {
                            return // Skip sensitive content
                        }
                    }
                }

                // ⚡ Bolt Optimization: Offload expensive NSPasteboard string extraction to a background queue
                // and use .utf16.count for O(1) length check instead of O(N) string bridging
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else { return }
                    if let content = self.pasteboard.string(forType: .string) {
                        // 🛡️ Sentinel: Prevent memory exhaustion / DoS from extremely large clipboard payloads
                        // A 5MB limit allows large code files and logs while preventing massive DoS vectors
                        let maxLength = 5_000_000
                        // ⚡ Bolt Optimization: Use O(1) .utf16.count for strings bridged from NSString
                        let sanitizedContent = content.utf16.count > maxLength ? String(content.prefix(maxLength)) + "...\n(Truncated due to extreme size limits)" : content

                        DispatchQueue.main.async {
                            self.addItem(sanitizedContent)
                        }
                    }
                }
            }
        }
    }

    func addItem(_ content: String) {
        // Не добавляем, если уже есть в списке или среди закрепленных
        guard !items.contains(content), !pinnedItems.contains(content) else { return }
        // Добавляем в начало списка
        items.insert(content, at: 0)
        // Удаляем лишний элемент, если превышен лимит
        if items.count > 20 {
            items.removeLast()
        }
        syncWithServer()
    }

    func syncWithServer(immediate: Bool = false) {
        syncWorkItem?.cancel()

        // Capture current state to avoid thread-safety issues during serialization
        let currentItems = self.items
        let currentPinnedItems = self.pinnedItems

        let workItem = DispatchWorkItem { [weak self] in
            self?.performSync(items: currentItems, pinnedItems: currentPinnedItems)
        }

        syncWorkItem = workItem

        // Dispatch network and serialization work to a background queue
        let queue = DispatchQueue.global(qos: .utility)
        if immediate {
            queue.async(execute: workItem)
        } else {
            queue.asyncAfter(deadline: .now() + 1.5, execute: workItem)
        }
    }

    private func performSync(items: [String], pinnedItems: [String]) {
        guard let url = URL(string: "https://example.com/api/sync") else { return }

        // Capture state on main thread before moving to background
        let payload: [String: Any] = [
            "items": items,
            "pinnedItems": pinnedItems
        ]

        let workItem = DispatchWorkItem { [weak self] in
            self?.performSync(payload: payload)
        }

        syncWorkItem = workItem

        if immediate {
            DispatchQueue.global(qos: .background).async(execute: workItem)
        } else {
            // Use 1.5s delay as in main, but run on background queue
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.5, execute: workItem)
        }
    }

    private func performSync(payload: [String: Any]) {
        guard let url = URL(string: "https://example.com/api/sync") else { return }

        // Bolt Optimization: Offload expensive JSON serialization to background thread
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка синхронизации: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Статус синхронизации: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }

    func pinItem(_ item: String) {
        // Убираем из обычного списка, если элемент там есть
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }

        // Если уже 5 закреплённых элемента, удаляем последний
        if pinnedItems.count >= 5 {
            items.insert(pinnedItems.last!, at: 0)
            pinnedItems.removeLast()
        }
        
        pinnedItems.insert(item, at: 0)
    }

    func unpinItem(_ item: String) {
        // Убираем из закрепленных
        if let index = pinnedItems.firstIndex(of: item) {
            pinnedItems.remove(at: index)
            addItem(item)
        }
    }

    /// ⚡ Bolt: copyToClipboard writes directly to NSPasteboard and immediately updates `lastChangeCount`.
    /// This short-circuits `monitorClipboard` and prevents an unnecessary redundant read event/re-render.
    func copyToClipboard(_ content: String) {
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        // Update lastChangeCount so the timer ignores this self-induced change
        lastChangeCount = pasteboard.changeCount
    }

    /// 🛡️ Sentinel: Securely wipes in-memory clipboard data on logout
    /// Prevents data leakage where the next authenticated user can view
    /// the previous user's clipboard history.
    func clearData() {
        items.removeAll()
        pinnedItems.removeAll()
    }
}



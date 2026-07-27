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

    @Published var items: [String] = []
    @Published var pinnedItems: [String] = [] // Закреплённые элементы

    init() {
        monitorClipboard()
    }

    func monitorClipboard() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.pasteboard.changeCount != self.lastChangeCount {
                self.lastChangeCount = self.pasteboard.changeCount
                if let content = self.pasteboard.string(forType: .string) {
                    self.addItem(content)
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

    func syncWithServer() {
        guard let url = URL(string: "https://example.com/api/sync") else { return }

        let payload: [String: Any] = [
            "items": items,
            "pinnedItems": pinnedItems
        ]

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
}



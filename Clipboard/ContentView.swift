//
//  ContentView.swift
//  Clipboard
//
//  Created by Ринат Панкратов on 24.11.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        NavigationStack {
            List {
                if !clipboardManager.pinnedItems.isEmpty {
                    Section(header: Text("Закрепленные")) {
                        ForEach(clipboardManager.pinnedItems, id: \.self) { item in
                            ClipboardRow(item: item, isPinned: true)
                        }
                    }
                }

                Section(header: Text("История")) {
                    if clipboardManager.items.count < 1 {
                        Text("Элементов нет")
                            .foregroundColor(.secondary)
                    }
                    ForEach(clipboardManager.items, id: \.self) { item in
                        ClipboardRow(item: item, isPinned: false)
                    }
                }
            }
            .listStyle(.inset)
            .navigationTitle("Буфер обмена")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        clipboardManager.syncWithServer(immediate: true)
                    }) {
                        Text("Синхронизация")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        isLoggedIn = false
                    }) {
                        Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .help("Выйти")
                }
                }
            }
        }
        .frame(width: 300, height: 400)
    }
}

struct ClipboardRow: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    let item: String
    let isPinned: Bool
    @State private var hasCopied = false

    var body: some View {
        HStack {
            Text(item)
                .lineLimit(1)
            Spacer()
            Button(action: {
                copyToClipboard(item)
                withAnimation {
                    hasCopied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        hasCopied = false
                    }
                }
            }) {
                Image(systemName: hasCopied ? "checkmark" : "doc.on.doc")
                    .foregroundColor(hasCopied ? .green : .primary)
            }
            .buttonStyle(BorderlessButtonStyle())
            .help(hasCopied ? "Скопировано!" : "Скопировать")

            if isPinned {
                Button(action: {
                    clipboardManager.unpinItem(item)
                }) {
                    Image(systemName: "pin.slash.fill")
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Открепить")
            } else {
                Button(action: {
                    clipboardManager.pinItem(item)
                }) {
                    Image(systemName: "pin.fill")
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Закрепить")
            }
        }
    }

    func copyToClipboard(_ content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
    }
}

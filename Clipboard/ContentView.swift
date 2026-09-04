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
                        ForEach(clipboardManager.pinnedItems) { item in
                            ClipboardRow(item: item, isPinned: true)
                        }
                    }
                }

                Section(header: Text("История")) {
                    if clipboardManager.items.count < 1 {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.on.clipboard")
                                .font(.largeTitle)
                            Text("Буфер обмена пуст")
                        }
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    ForEach(clipboardManager.items) { item in
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
                        Label("Синхронизация", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .help("Синхронизировать сейчас")
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        clipboardManager.clearData() // 🛡️ Sentinel: Clear sensitive clipboard history before logging out
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
    let item: ClipboardItem
    let isPinned: Bool
    @State private var hasCopied = false

    @State private var isCopied = false

    var body: some View {
        HStack {
            Text(item.content)
                .lineLimit(1)
                .help(item.count > 250 ? String(item.prefix(250)) + "..." : item)
            Spacer()
            Button(action: {
                clipboardManager.copyToClipboard(item.content)
                withAnimation {
                    isCopied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isCopied = false
                    }
                }
            }) {
                Label("Скопировать", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                    .foregroundColor(isCopied ? .green : .primary)
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(BorderlessButtonStyle())
            .help(isCopied ? "Скопировано!" : "Скопировать")

            if isPinned {
                Button(action: {
                    clipboardManager.unpinItem(item)
                }) {
                    Label("Открепить", systemImage: "pin.slash.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Открепить")
            } else {
                Button(action: {
                    clipboardManager.pinItem(item)
                }) {
                    Label("Закрепить", systemImage: "pin.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Закрепить")
            }
        }
    }
}

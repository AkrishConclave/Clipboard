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
                        Label("Синхронизация", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .help("Синхронизировать сейчас")
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

    @State private var isCopied = false

    var body: some View {
        HStack {
            Text(item)
                .lineLimit(1)
            Spacer()
            Button(action: {
                clipboardManager.copyToClipboard(item)
                withAnimation {
                    isCopied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isCopied = false
                    }
                }
            }) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .foregroundColor(isCopied ? .green : .primary)
            }
            .buttonStyle(BorderlessButtonStyle())
            .help(isCopied ? "Скопировано!" : "Скопировать")

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
}

//
//  ContentView.swift
//  Clipboard
//
//  Created by Ринат Панкратов on 24.11.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager

    var body: some View {
        VStack {
            Text("Последние 20 скопированных строк. До 5 строк можно закрепить.")
                .font(.headline)
                .padding()

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
                            .font(.footnote)
                    }
                    ForEach(clipboardManager.items, id: \.self) { item in
                        ClipboardRow(item: item, isPinned: false)
                    }
                }
            }
        }
        .frame(width: 300, height: 400) // Компактные размеры окна
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct ClipboardRow: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    let item: String
    let isPinned: Bool

    var body: some View {
        HStack {
            Text(item)
                .lineLimit(1)
            Spacer()
            Button(action: {
                copyToClipboard(item)
            }) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(BorderlessButtonStyle())
            .help("Скопировать")

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

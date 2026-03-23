import SwiftUI

@main
struct FrenApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: "Fren")
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "Show Fren", action: #selector(showWindow), keyEquivalent: "")
        menu.addItem(withTitle: "Recenter", action: #selector(recenterWindow), keyEquivalent: "r")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Fren", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        for item in menu.items where item.action != nil && item.action != #selector(NSApplication.terminate(_:)) {
            item.target = self
        }

        statusItem?.menu = menu
    }

    @objc private func showWindow() {
        NSApplication.shared.activate()
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }

    @objc private func recenterWindow() {
        NSApplication.shared.activate()
        if let window = NSApplication.shared.windows.first {
            window.center()
            window.makeKeyAndOrderFront(nil)
        }
    }
}

import Foundation

@MainActor
@Observable
final class ADBManager {
    var isConnected = false

    // Toggle states
    var isDarkMode = false
    var isWiFiOn = false
    var isBluetoothOn = false
    var isAutoRotateOn = false
    var isShowTapsOn = false
    var isStayAwakeOn = false
    var isDNDOn = false
    var isLocationOn = false
    var isShowLayoutBounds = false

    private var timer: Timer?

    private static let adbPath: String = {
        let candidates = [
            "/Users/endboss/Library/Android/sdk/platform-tools/adb",
            "/opt/homebrew/bin/adb",
            "/usr/local/bin/adb",
        ]
        return candidates.first { FileManager.default.isExecutableFile(atPath: $0) }
            ?? "adb"
    }()

    func poll() {
        refreshAll()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refreshAll() }
        }
    }

    // MARK: - Toggles

    func toggleDarkMode() {
        let mode = isDarkMode ? "no" : "yes"
        asyncADB("shell", "cmd", "uimode", "night", mode)
    }

    func toggleWiFi() {
        let cmd = isWiFiOn ? "disable" : "enable"
        asyncADB("shell", "svc", "wifi", cmd)
    }

    func toggleBluetooth() {
        let cmd = isBluetoothOn ? "disable" : "enable"
        asyncADB("shell", "svc", "bluetooth", cmd)
    }

    func toggleAutoRotate() {
        let val = isAutoRotateOn ? "0" : "1"
        asyncADB("shell", "settings", "put", "system", "accelerometer_rotation", val)
    }

    func toggleShowTaps() {
        let val = isShowTapsOn ? "0" : "1"
        asyncADB("shell", "settings", "put", "system", "show_touches", val)
    }

    func toggleStayAwake() {
        let val = isStayAwakeOn ? "0" : "3"
        asyncADB("shell", "settings", "put", "global", "stay_on_while_plugged_in", val)
    }

    func toggleDND() {
        let val = isDNDOn ? "0" : "1"
        asyncADB("shell", "settings", "put", "global", "zen_mode", val)
    }

    func toggleLocation() {
        let val = isLocationOn ? "0" : "3"
        asyncADB("shell", "settings", "put", "secure", "location_mode", val)
    }

    func toggleShowLayoutBounds() {
        let val = isShowLayoutBounds ? "false" : "true"
        let path = Self.adbPath
        Task.detached {
            ADBManager.runADB(path: path, "shell", "setprop", "debug.layout", val)
            ADBManager.runADB(path: path, "shell", "service", "call", "activity", "1599295570")
        }
        delayedRefresh()
    }

    // MARK: - Actions

    func takeScreenshot() {
        let desktop = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
            .appendingPathComponent("screenshot_\(timestamp()).png")
            .path
        let path = Self.adbPath
        Task.detached {
            let data = ADBManager.runADB(path: path, "exec-out", "screencap", "-p")
            try? data.write(toFile: desktop, atomically: true, encoding: .utf8)
        }
    }

    func takeScreenshotPNG() {
        let desktop = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
            .appendingPathComponent("screenshot_\(timestamp()).png")
        let path = Self.adbPath
        Task.detached {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = ["exec-out", "screencap", "-p"]
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = Pipe()
            try? process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            try? data.write(to: desktop)
        }
    }

    func pressHome() {
        asyncADB("shell", "input", "keyevent", "KEYCODE_HOME")
    }

    func pressBack() {
        asyncADB("shell", "input", "keyevent", "KEYCODE_BACK")
    }

    func pressRecents() {
        asyncADB("shell", "input", "keyevent", "KEYCODE_APP_SWITCH")
    }

    func lockScreen() {
        asyncADB("shell", "input", "keyevent", "KEYCODE_POWER")
    }

    func volumeUp() {
        asyncADB("shell", "input", "keyevent", "KEYCODE_VOLUME_UP")
    }

    func volumeDown() {
        asyncADB("shell", "input", "keyevent", "KEYCODE_VOLUME_DOWN")
    }

    func openSettings() {
        asyncADB("shell", "am", "start", "-a", "android.settings.SETTINGS")
    }

    func reboot() {
        asyncADB("reboot")
    }

    // MARK: - Internal

    private func refreshAll() {
        let path = Self.adbPath
        Task.detached { [weak self] in
            let dark = ADBManager.runADB(path: path, "shell", "settings", "get", "secure", "ui_night_mode")
            let wifi = ADBManager.runADB(path: path, "shell", "settings", "get", "global", "wifi_on")
            let bt = ADBManager.runADB(path: path, "shell", "settings", "get", "global", "bluetooth_on")
            let rotate = ADBManager.runADB(path: path, "shell", "settings", "get", "system", "accelerometer_rotation")
            let taps = ADBManager.runADB(path: path, "shell", "settings", "get", "system", "show_touches")
            let stay = ADBManager.runADB(path: path, "shell", "settings", "get", "global", "stay_on_while_plugged_in")
            let dnd = ADBManager.runADB(path: path, "shell", "settings", "get", "global", "zen_mode")
            let loc = ADBManager.runADB(path: path, "shell", "settings", "get", "secure", "location_mode")
            let layout = ADBManager.runADB(path: path, "shell", "getprop", "debug.layout")

            let darkVal = dark.trimmed
            let connected = !darkVal.isEmpty && darkVal != "error"
                && !darkVal.contains("no devices") && !darkVal.contains("daemon")

            await MainActor.run { [weak self] in
                self?.isConnected = connected
                guard connected else { return }
                self?.isDarkMode = darkVal == "2"
                self?.isWiFiOn = wifi.trimmed == "1"
                self?.isBluetoothOn = bt.trimmed == "1"
                self?.isAutoRotateOn = rotate.trimmed == "1"
                self?.isShowTapsOn = taps.trimmed == "1"
                self?.isStayAwakeOn = Int(stay.trimmed) ?? 0 > 0
                self?.isDNDOn = Int(dnd.trimmed) ?? 0 > 0
                self?.isLocationOn = Int(loc.trimmed) ?? 0 > 0
                self?.isShowLayoutBounds = layout.trimmed == "true"
            }
        }
    }

    private func asyncADB(_ args: String...) {
        let path = Self.adbPath
        let a = args
        Task.detached {
            ADBManager.runADB(path: path, args: a)
        }
        delayedRefresh()
    }

    private func delayedRefresh() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(600))
            self?.refreshAll()
        }
    }

    private func timestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd_HHmmss"
        return f.string(from: Date())
    }

    @discardableResult
    private nonisolated static func runADB(path: String, _ args: String...) -> String {
        runADB(path: path, args: args)
    }

    @discardableResult
    private nonisolated static func runADB(path: String, args: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

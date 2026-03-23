import SwiftUI

struct ContentView: View {
    @State private var adb = ADBManager()

    private let columns = Array(repeating: GridItem(.fixed(72), spacing: 10), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            DragBar()

            LazyVGrid(columns: columns, spacing: 10) {
                // Row 1: Connectivity & display
                ToggleTile(
                    icon: adb.isDarkMode ? "moon.fill" : "sun.max.fill",
                    tint: adb.isDarkMode ? .indigo : .orange,
                    isOn: adb.isDarkMode,
                    label: "Dark"
                ) { adb.toggleDarkMode() }

                ToggleTile(
                    icon: "wifi",
                    tint: .blue,
                    isOn: adb.isWiFiOn,
                    label: "Wi-Fi"
                ) { adb.toggleWiFi() }

                ToggleTile(
                    icon: "bluetooth",
                    tint: .blue,
                    isOn: adb.isBluetoothOn,
                    label: "BT"
                ) { adb.toggleBluetooth() }

                ToggleTile(
                    icon: "rotate.right",
                    tint: .purple,
                    isOn: adb.isAutoRotateOn,
                    label: "Rotate"
                ) { adb.toggleAutoRotate() }

                // Row 2: Developer & system
                ToggleTile(
                    icon: "hand.tap.fill",
                    tint: .mint,
                    isOn: adb.isShowTapsOn,
                    label: "Taps"
                ) { adb.toggleShowTaps() }

                ToggleTile(
                    icon: "bolt.fill",
                    tint: .yellow,
                    isOn: adb.isStayAwakeOn,
                    label: "Awake"
                ) { adb.toggleStayAwake() }

                ToggleTile(
                    icon: "moon.zzz.fill",
                    tint: .indigo,
                    isOn: adb.isDNDOn,
                    label: "DND"
                ) { adb.toggleDND() }

                ToggleTile(
                    icon: "location.fill",
                    tint: .blue,
                    isOn: adb.isLocationOn,
                    label: "Location"
                ) { adb.toggleLocation() }

                // Row 3: Layout + actions
                ToggleTile(
                    icon: "rectangle.dashed",
                    tint: .green,
                    isOn: adb.isShowLayoutBounds,
                    label: "Bounds"
                ) { adb.toggleShowLayoutBounds() }

                ActionTile(icon: "camera.fill", tint: .pink, label: "Shot") {
                    adb.takeScreenshotPNG()
                }

                ActionTile(icon: "gear", tint: .gray, label: "Settings") {
                    adb.openSettings()
                }

                ActionTile(icon: "lock.fill", tint: .red, label: "Lock") {
                    adb.lockScreen()
                }

                // Row 4: Navigation & volume
                ActionTile(icon: "house.fill", tint: .orange, label: "Home") {
                    adb.pressHome()
                }

                ActionTile(icon: "chevron.backward", tint: .gray, label: "Back") {
                    adb.pressBack()
                }

                ActionTile(icon: "square.stack.3d.up", tint: .purple, label: "Recents") {
                    adb.pressRecents()
                }

                ActionTile(icon: "arrow.counterclockwise", tint: .red, label: "Reboot") {
                    adb.reboot()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 8)
        }
        .opacity(adb.isConnected ? 1.0 : 0.4)
        .allowsHitTesting(adb.isConnected)
        .onAppear { adb.poll() }
    }
}

// MARK: - Toggle tile (has on/off state)

private struct ToggleTile: View {
    let icon: String
    let tint: Color
    let isOn: Bool
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isOn ? tint : .secondary)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 36, height: 36)
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(isOn ? .primary : .secondary)
            }
            .frame(width: 64, height: 58)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 14))
    }
}

// MARK: - Action tile (one-shot, no state)

private struct ActionTile: View {
    let icon: String
    let tint: Color
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 64, height: 58)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 14))
    }
}

// MARK: - Drag handle

private struct DragBar: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let container = WindowDragView()
        container.wantsLayer = true

        let pill = NSView()
        pill.wantsLayer = true
        pill.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.6).cgColor
        pill.layer?.cornerRadius = 2.5
        pill.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(pill)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 338),
            container.heightAnchor.constraint(equalToConstant: 36),
            pill.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            pill.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pill.widthAnchor.constraint(equalToConstant: 36),
            pill.heightAnchor.constraint(equalToConstant: 5),
        ])

        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class WindowDragView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

#Preview {
    ContentView()
}

import AppKit
import Carbon
import ServiceManagement

private let appName = "Plain Text Keeper"
private let hotKeySignature = OSType(UInt32(ascii: "PTKP"))
private let hotKeyID = UInt32(1)
private let hotKeyConfigDefaultsKey = "hotKeyConfig.v1"
private let launchHintDefaultsKey = "hasShownLaunchHint.v2"
private let showLaunchHintDefaultsKey = "showLaunchHint"

private extension UInt32 {
    init(ascii string: String) {
        var value: UInt32 = 0
        for scalar in string.unicodeScalars.prefix(4) {
            value = (value << 8) + UInt32(scalar.value)
        }
        self = value
    }
}

struct HotKeyConfig: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32

    static let `default` = HotKeyConfig(
        keyCode: UInt32(kVK_ANSI_V),
        modifiers: UInt32(cmdKey | optionKey | controlKey)
    )

    static func load() -> HotKeyConfig {
        guard
            let data = UserDefaults.standard.data(forKey: hotKeyConfigDefaultsKey),
            let config = try? JSONDecoder().decode(HotKeyConfig.self, from: data)
        else {
            return .default
        }
        return config
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: hotKeyConfigDefaultsKey)
        }
    }
}

private func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
    var modifiers: UInt32 = 0
    if flags.contains(.command) { modifiers |= UInt32(cmdKey) }
    if flags.contains(.option) { modifiers |= UInt32(optionKey) }
    if flags.contains(.control) { modifiers |= UInt32(controlKey) }
    if flags.contains(.shift) { modifiers |= UInt32(shiftKey) }
    return modifiers
}

private func displayString(for config: HotKeyConfig) -> String {
    var parts: [String] = []
    if config.modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
    if config.modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
    if config.modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
    if config.modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
    parts.append(keyName(for: config.keyCode))
    return parts.joined()
}

private func keyName(for keyCode: UInt32) -> String {
    let names: [UInt32: String] = [
        UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_B): "B", UInt32(kVK_ANSI_C): "C",
        UInt32(kVK_ANSI_D): "D", UInt32(kVK_ANSI_E): "E", UInt32(kVK_ANSI_F): "F",
        UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H", UInt32(kVK_ANSI_I): "I",
        UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
        UInt32(kVK_ANSI_M): "M", UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_O): "O",
        UInt32(kVK_ANSI_P): "P", UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_R): "R",
        UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_T): "T", UInt32(kVK_ANSI_U): "U",
        UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_X): "X",
        UInt32(kVK_ANSI_Y): "Y", UInt32(kVK_ANSI_Z): "Z",
        UInt32(kVK_ANSI_0): "0", UInt32(kVK_ANSI_1): "1", UInt32(kVK_ANSI_2): "2",
        UInt32(kVK_ANSI_3): "3", UInt32(kVK_ANSI_4): "4", UInt32(kVK_ANSI_5): "5",
        UInt32(kVK_ANSI_6): "6", UInt32(kVK_ANSI_7): "7", UInt32(kVK_ANSI_8): "8",
        UInt32(kVK_ANSI_9): "9",
        UInt32(kVK_Space): "Space", UInt32(kVK_Return): "Return", UInt32(kVK_Tab): "Tab",
        UInt32(kVK_Escape): "Esc", UInt32(kVK_Delete): "Delete",
        UInt32(kVK_LeftArrow): "←", UInt32(kVK_RightArrow): "→",
        UInt32(kVK_UpArrow): "↑", UInt32(kVK_DownArrow): "↓",
        UInt32(kVK_F1): "F1", UInt32(kVK_F2): "F2", UInt32(kVK_F3): "F3",
        UInt32(kVK_F4): "F4", UInt32(kVK_F5): "F5", UInt32(kVK_F6): "F6",
        UInt32(kVK_F7): "F7", UInt32(kVK_F8): "F8", UInt32(kVK_F9): "F9",
        UInt32(kVK_F10): "F10", UInt32(kVK_F11): "F11", UInt32(kVK_F12): "F12"
    ]
    return names[keyCode] ?? "Key \(keyCode)"
}

private func makeMenuBarTIcon() -> NSImage {
    let image = NSImage(size: NSSize(width: 18, height: 18))
    image.lockFocus()

    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: 18, height: 18).fill()

    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 17, weight: .black),
        .foregroundColor: NSColor.black,
        .kern: -0.4
    ]
    let glyph = NSString(string: "T")
    let glyphSize = glyph.size(withAttributes: attributes)
    let glyphRect = NSRect(
        x: (18 - glyphSize.width) / 2,
        y: (18 - glyphSize.height) / 2 - 1.0,
        width: glyphSize.width,
        height: glyphSize.height
    )
    glyph.draw(in: glyphRect, withAttributes: attributes)

    image.unlockFocus()
    image.isTemplate = true
    image.accessibilityDescription = appName
    return image
}

final class SquareGlassButton: NSButton {
    override func draw(_ dirtyRect: NSRect) {
        let rect = bounds.insetBy(dx: 0.5, dy: 0.5)
        let path = NSBezierPath(roundedRect: rect, xRadius: 12, yRadius: 12)
        (isHighlighted ? NSColor.controlAccentColor.blended(withFraction: 0.20, of: .black) ?? .controlAccentColor : NSColor.controlAccentColor).setFill()
        path.fill()
        NSColor.white.withAlphaComponent(0.35).setStroke()
        path.lineWidth = 1
        path.stroke()
        super.draw(dirtyRect)
    }
}

final class BlueGlassBackgroundView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        let colors = [
            NSColor(red: 0.96, green: 0.985, blue: 1.0, alpha: 1.0),
            NSColor(red: 0.88, green: 0.94, blue: 1.0, alpha: 1.0),
            NSColor(red: 0.98, green: 0.99, blue: 1.0, alpha: 1.0)
        ]
        NSGradient(colors: colors)?.draw(in: bounds, angle: -35)
    }
}

final class CoolGlassTileView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        let rect = bounds.insetBy(dx: 0.5, dy: 0.5)
        let path = NSBezierPath(roundedRect: rect, xRadius: 12, yRadius: 12)
        NSColor(red: 0.92, green: 0.965, blue: 1.0, alpha: 0.68).setFill()
        path.fill()
        NSColor.white.withAlphaComponent(0.58).setStroke()
        path.lineWidth = 1
        path.stroke()
    }
}

final class ShortcutGlyphView: NSView {
    var stringValue: String = "" {
        didSet { needsDisplay = true }
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: 88, height: 36)
    }

    override func draw(_ dirtyRect: NSRect) {
        let count = stringValue.count
        let fontSize: CGFloat = count <= 3 ? 30 : (count <= 5 ? 24 : 20)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: NSColor.labelColor
        ]
        let text = NSAttributedString(string: stringValue, attributes: attributes)
        let size = text.size()
        let x = (bounds.width - size.width) / 2
        let y = max(0, (bounds.height - size.height) / 2)
        text.draw(at: NSPoint(x: x, y: y))
    }
}

final class SettingsWindowController: NSWindowController {
    private weak var appDelegate: AppDelegate?
    private let shortcutLabel = ShortcutGlyphView()
    private let statusLabel = NSTextField(labelWithString: "")
    private let launchHintCheckbox = NSButton(checkboxWithTitle: "Show launch hint", target: nil, action: nil)
    private let launchAtLoginCheckbox = NSButton(checkboxWithTitle: "Launch at login", target: nil, action: nil)
    private var eventMonitor: Any?

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 318),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Plain Text Keeper Settings"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.appearance = NSAppearance(named: .aqua)
        window.center()
        super.init(window: window)
        buildUI()
        refresh()
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func showWindow(_ sender: Any?) {
        stopRecording()
        refresh()
        super.showWindow(sender)
        window?.center()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func buildUI() {
        guard let contentView = window?.contentView else { return }

        let background = BlueGlassBackgroundView()
        background.wantsLayer = true
        background.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(background)

        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            background.topAnchor.constraint(equalTo: contentView.topAnchor),
            background.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        let recordButton = makeSquareButton(title: "Record", action: #selector(recordShortcut))
        let resetButton = makeSquareButton(title: "Reset", action: #selector(resetShortcut))
        let cleanButton = makePrimaryButton(title: "Clean Now", action: #selector(cleanClipboardNow))
        let quitButton = makeDangerButton(title: "Quit App", action: #selector(quitApp))

        launchHintCheckbox.target = self
        launchHintCheckbox.action = #selector(toggleLaunchHint)
        launchAtLoginCheckbox.target = self
        launchAtLoginCheckbox.action = #selector(toggleLaunchAtLogin)

        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.alignment = .left
        statusLabel.lineBreakMode = .byWordWrapping
        statusLabel.maximumNumberOfLines = 1
        statusLabel.isHidden = true

        let shortcutActions = NSStackView(views: [shortcutLabel, recordButton, resetButton])
        shortcutActions.orientation = .horizontal
        shortcutActions.alignment = .centerY
        shortcutActions.distribution = .fill
        shortcutActions.spacing = 12

        let shortcutSection = makeShortcutSection(actions: shortcutActions)

        let behaviorContent = NSStackView(views: [
            makeToggleTile(control: launchAtLoginCheckbox, detail: "Start quietly at sign-in."),
            makeToggleTile(control: launchHintCheckbox, detail: "Show guidance at launch.")
        ])
        behaviorContent.orientation = .horizontal
        behaviorContent.alignment = .centerY
        behaviorContent.distribution = .fillEqually
        behaviorContent.spacing = 8

        let behaviorSection = makeSection(title: "Behavior", content: behaviorContent)

        let cards = NSStackView(views: [shortcutSection, behaviorSection])
        cards.orientation = .vertical
        cards.alignment = .width
        cards.spacing = 12

        let footerSpacer = NSView()
        let footer = NSStackView(views: [quitButton, footerSpacer, cleanButton])
        footer.orientation = .horizontal
        footer.alignment = .centerY
        footer.spacing = 12

        let stack = NSStackView(views: [cards, footer])
        stack.orientation = .vertical
        stack.alignment = .width
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        shortcutLabel.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        shortcutActions.translatesAutoresizingMaskIntoConstraints = false
        cards.translatesAutoresizingMaskIntoConstraints = false
        shortcutSection.translatesAutoresizingMaskIntoConstraints = false
        behaviorSection.translatesAutoresizingMaskIntoConstraints = false
        footer.translatesAutoresizingMaskIntoConstraints = false
        cleanButton.translatesAutoresizingMaskIntoConstraints = false
        quitButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 34),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),

            cards.widthAnchor.constraint(equalTo: stack.widthAnchor),
            shortcutSection.widthAnchor.constraint(equalTo: cards.widthAnchor),
            behaviorSection.widthAnchor.constraint(equalTo: cards.widthAnchor),
            footer.widthAnchor.constraint(equalTo: stack.widthAnchor),
            shortcutActions.heightAnchor.constraint(equalToConstant: 76),
            shortcutLabel.widthAnchor.constraint(equalToConstant: 88),
            shortcutLabel.heightAnchor.constraint(equalToConstant: 76),
            recordButton.widthAnchor.constraint(equalToConstant: 76),
            recordButton.heightAnchor.constraint(equalToConstant: 76),
            resetButton.widthAnchor.constraint(equalToConstant: 76),
            resetButton.heightAnchor.constraint(equalToConstant: 76),
            cleanButton.widthAnchor.constraint(equalToConstant: 88),
            quitButton.widthAnchor.constraint(equalToConstant: 92)
        ])
    }

    private func makeSection(title: String, content: NSView) -> NSView {
        let section = NSView()
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.isBezeled = false
        titleLabel.drawsBackground = false

        let stack = NSStackView(views: [titleLabel, content])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            stack.topAnchor.constraint(equalTo: section.topAnchor),
            stack.bottomAnchor.constraint(equalTo: section.bottomAnchor)
        ])

        return section
    }

    private func makeShortcutSection(actions: NSView) -> NSView {
        let section = NSView()
        let titleLabel = NSTextField(labelWithString: "Shortcut")
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.alignment = .left
        titleLabel.isBezeled = false
        titleLabel.drawsBackground = false

        let stack = NSStackView(views: [titleLabel, actions])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(stack)

        actions.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            stack.topAnchor.constraint(equalTo: section.topAnchor),
            stack.bottomAnchor.constraint(equalTo: section.bottomAnchor),
            actions.widthAnchor.constraint(equalTo: stack.widthAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])

        return section
    }

    private func makeToggleRow(control: NSButton, detail: String) -> NSView {
        let detailLabel = NSTextField(labelWithString: detail)
        detailLabel.font = .systemFont(ofSize: 11)
        detailLabel.textColor = .secondaryLabelColor

        let stack = NSStackView(views: [control, detailLabel])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        return stack
    }

    private func makeToggleTile(control: NSButton, detail: String) -> NSView {
        let titleText = control.title
        control.title = ""

        let titleLabel = NSTextField(wrappingLabelWithString: titleText)
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .labelColor
        titleLabel.maximumNumberOfLines = 2

        let detailLabel = NSTextField(wrappingLabelWithString: detail)
        detailLabel.font = .systemFont(ofSize: 11)
        detailLabel.textColor = .secondaryLabelColor
        detailLabel.maximumNumberOfLines = 2

        let textStack = NSStackView(views: [titleLabel, detailLabel])
        textStack.orientation = .vertical
        textStack.alignment = .leading
        textStack.spacing = 1

        let stack = NSStackView(views: [control, textStack])
        stack.orientation = .horizontal
        stack.alignment = .top
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false

        textStack.translatesAutoresizingMaskIntoConstraints = false
        control.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            control.widthAnchor.constraint(equalToConstant: 20),
            textStack.widthAnchor.constraint(lessThanOrEqualToConstant: 118)
        ])

        let tile = CoolGlassTileView()
        tile.wantsLayer = true
        tile.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: tile.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: tile.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: tile.bottomAnchor, constant: -10),
            tile.heightAnchor.constraint(equalToConstant: 72)
        ])

        return tile
    }

    private func makeDivider() -> NSView {
        let divider = NSBox()
        divider.boxType = .separator
        return divider
    }

    private func makePrimaryButton(title: String, action: Selector) -> NSButton {
        let button = NSButton(title: title, target: self, action: action)
        button.bezelStyle = .rounded
        button.keyEquivalent = title == "Clean Now" ? "\r" : ""
        button.controlSize = .large
        return button
    }

    private func makeSecondaryButton(title: String, action: Selector) -> NSButton {
        let button = NSButton(title: title, target: self, action: action)
        button.bezelStyle = .rounded
        button.controlSize = .large
        return button
    }

    private func makeSquareButton(title: String, action: Selector) -> NSButton {
        let button = SquareGlassButton(title: title, target: self, action: action)
        button.isBordered = false
        button.bezelStyle = .shadowlessSquare
        button.controlSize = .large
        button.font = .systemFont(ofSize: 12, weight: .medium)
        button.alignment = .center
        button.contentTintColor = .white
        return button
    }

    private func makeDangerButton(title: String, action: Selector) -> NSButton {
        let button = NSButton(title: title, target: self, action: action)
        button.bezelStyle = .rounded
        button.controlSize = .large
        button.contentTintColor = .systemRed
        return button
    }

    func refresh() {
        guard let appDelegate else { return }
        shortcutLabel.stringValue = displayString(for: appDelegate.hotKeyConfig)
        launchHintCheckbox.state = appDelegate.showLaunchHint ? .on : .off
        launchAtLoginCheckbox.state = appDelegate.isLaunchAtLoginEnabled ? .on : .off
        statusLabel.isHidden = true
    }

    @objc private func recordShortcut() {
        stopRecording()
        shortcutLabel.stringValue = "⌨"
        setStatus("Use at least one modifier key, such as Command, Option, Control, or Shift.")

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleShortcutEvent(event)
            return nil
        }
    }

    private func handleShortcutEvent(_ event: NSEvent) {
        guard let appDelegate else { return }
        let modifiers = carbonModifiers(from: event.modifierFlags)
        guard modifiers != 0 else {
            setStatus("Shortcut needs at least one modifier key.")
            NSSound.beep()
            return
        }

        let newConfig = HotKeyConfig(keyCode: UInt32(event.keyCode), modifiers: modifiers)
        stopRecording()
        if appDelegate.applyHotKeyConfig(newConfig, persist: true) {
            shortcutLabel.stringValue = displayString(for: newConfig)
            setStatus("Shortcut saved.")
        } else {
            refresh()
            setStatus("That shortcut is already used by another app. The previous shortcut is still active.")
        }
    }

    private func stopRecording() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }

    @objc private func resetShortcut() {
        stopRecording()
        if appDelegate?.applyHotKeyConfig(.default, persist: true) == true {
            refresh()
            setStatus("Shortcut reset to default.")
        } else {
            setStatus("Default shortcut could not be registered.")
        }
    }

    @objc private func toggleLaunchHint() {
        appDelegate?.showLaunchHint = launchHintCheckbox.state == .on
        setStatus("Launch hint preference updated.")
    }

    @objc private func toggleLaunchAtLogin() {
        appDelegate?.setLaunchAtLogin(launchAtLoginCheckbox.state == .on)
        refresh()
    }

    @objc private func cleanClipboardNow() {
        appDelegate?.cleanClipboard()
    }

    @objc private func quitApp() {
        appDelegate?.quit()
    }

    private func setStatus(_ text: String) {
        statusLabel.stringValue = text
        statusLabel.isHidden = true
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var launchAtLoginItem: NSMenuItem?
    private var shortcutMenuItem: NSMenuItem?
    private var settingsWindowController: SettingsWindowController?
    private(set) var hotKeyConfig = HotKeyConfig.load()

    var showLaunchHint: Bool {
        get {
            if UserDefaults.standard.object(forKey: showLaunchHintDefaultsKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: showLaunchHintDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: showLaunchHintDefaultsKey)
        }
    }

    var isLaunchAtLoginEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        installHotKeyHandler()
        _ = applyHotKeyConfig(hotKeyConfig, persist: false)

        if showLaunchHint && !UserDefaults.standard.bool(forKey: launchHintDefaultsKey) {
            UserDefaults.standard.set(true, forKey: launchHintDefaultsKey)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showStatusWindow()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        unregisterHotKey()
        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        .terminateNow
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings()
        return true
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = makeMenuBarTIcon()
            button.imagePosition = .imageOnly
            button.title = ""
            button.toolTip = "\(appName): clean clipboard formatting"
        }

        let menu = NSMenu()
        let cleanItem = NSMenuItem(title: "Clean Clipboard Now", action: #selector(cleanClipboardFromMenu), keyEquivalent: "")
        cleanItem.target = self
        menu.addItem(cleanItem)

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettingsFromMenu), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        shortcutMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        if let shortcutMenuItem {
            menu.addItem(shortcutMenuItem)
        }
        menu.addItem(NSMenuItem.separator())

        let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLoginFromMenu), keyEquivalent: "")
        loginItem.target = self
        launchAtLoginItem = loginItem
        menu.addItem(loginItem)

        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Quit Plain Text Keeper", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        item.menu = menu
        statusItem = item
        refreshMenuState()
    }

    private func refreshMenuState() {
        shortcutMenuItem?.title = "Shortcut: \(displayString(for: hotKeyConfig))"
        launchAtLoginItem?.state = isLaunchAtLoginEnabled ? .on : .off
        settingsWindowController?.refresh()
    }

    private func installHotKeyHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { _, event, userData in
            guard let userData else { return noErr }
            var hotKey = EventHotKeyID()
            let status = GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKey
            )
            guard status == noErr, hotKey.signature == hotKeySignature, hotKey.id == hotKeyID else {
                return noErr
            }

            let delegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
            delegate.cleanClipboard()
            return noErr
        }

        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            selfPointer,
            &eventHandler
        )

        if status != noErr {
            showAlert(title: "Shortcut Handler Failed", message: "Could not install the global shortcut handler. Error code: \(status)")
        }
    }

    @discardableResult
    func applyHotKeyConfig(_ config: HotKeyConfig, persist: Bool) -> Bool {
        let oldConfig = hotKeyConfig
        unregisterHotKey()

        let id = EventHotKeyID(signature: hotKeySignature, id: hotKeyID)
        let status = RegisterEventHotKey(
            config.keyCode,
            config.modifiers,
            id,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr else {
            if oldConfig != config {
                _ = applyHotKeyConfig(oldConfig, persist: false)
            }
            showAlert(
                title: "Shortcut Unavailable",
                message: "\(displayString(for: config)) may already be used by another app. The previous shortcut is still active."
            )
            return false
        }

        hotKeyConfig = config
        if persist {
            config.save()
        }
        refreshMenuState()
        return true
    }

    private func unregisterHotKey() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }

    @objc private func cleanClipboardFromMenu() {
        cleanClipboard()
    }

    func cleanClipboard() {
        let pasteboard = NSPasteboard.general
        guard let text = pasteboard.string(forType: .string) else {
            NSSound.beep()
            return
        }

        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        brieflyConfirm()
    }

    private func brieflyConfirm() {
        guard let button = statusItem?.button else { return }
        let oldTitle = button.title
        let oldImage = button.image

        button.image = NSImage(systemSymbolName: "checkmark", accessibilityDescription: "Cleaned")
        button.title = oldImage == nil ? "✓" : ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            button.image = oldImage
            button.title = oldTitle
        }
    }

    private func showStatusWindow() {
        let alert = NSAlert()
        alert.messageText = "Plain Text Keeper is running"
        alert.informativeText = "It stays in the menu bar. Copy formatted text, press \(displayString(for: hotKeyConfig)), then paste normally."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Settings")
        alert.addButton(withTitle: "Clean Clipboard Now")
        alert.addButton(withTitle: "OK")

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            showSettings()
        } else if response == .alertSecondButtonReturn {
            cleanClipboard()
        }
    }

    @objc private func showSettingsFromMenu() {
        showSettings()
    }

    func showSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(appDelegate: self)
        }
        settingsWindowController?.showWindow(nil)
    }

    @objc private func toggleLaunchAtLoginFromMenu() {
        setLaunchAtLogin(!isLaunchAtLoginEnabled)
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                showAlert(title: "Launch at Login Failed", message: error.localizedDescription)
            }
            refreshMenuState()
        } else {
            showAlert(title: "Unsupported macOS Version", message: "Launch at Login requires macOS 13 or newer.")
        }
    }

    @objc func quit() {
        unregisterHotKey()
        if let eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
        NSApp.terminate(nil)
    }

    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

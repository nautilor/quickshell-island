import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Io
import Quickshell.Wayland
import qs.modules.bar
import qs.modules.bar.components
import qs.modules.launcher

PanelWindow {
	id: bar
	focusable: false
	WlrLayershell.keyboardFocus: bar.launcherPanelOpen

	property bool quickPanelOpen: false
	property bool launcherPanelOpen: false
	property bool somethingOpen: quickPanelOpen || launcherPanelOpen

	readonly property int maxHeight: 700
	readonly property int maxWidth: 700

	readonly property int minHeight: 400

	readonly property int quickPanelHeight: 240
	readonly property int quickPanelWidth: 590

	readonly property int launcherPanelHeight: 285
	readonly property int launcherPanelWidth: 590

	readonly property int normalHeight: 45
	readonly property int normalWidth: 100

	readonly property int normalRadius: 50
	readonly property int openRadius: 24

	Colors {
		id: colors
	}

	readonly property int exclusiveZoneHeight: 45
	readonly property int shadowOffset: 2


	function panelHeight() {
		if (bar.quickPanelOpen) {
			return bar.quickPanelHeight
		} else if (bar.launcherPanelOpen) {
			return bar.launcherPanelHeight
		} else {
			return bar.normalHeight
		}
	}

	function panelWidth() {
		if (bar.quickPanelOpen) {
			return bar.quickPanelWidth
		} else if (bar.launcherPanelOpen) {
			return bar.launcherPanelWidth
		} else {
			return bar.normalWidth
		}
	}


	// ─────────────────────────────────────────────
	// Window
	// ─────────────────────────────────────────────

	anchors {
		top: true
	}

	margins {
		top: 10
	}

	exclusionMode: ExclusionMode.Normal
	exclusiveZone: exclusiveZoneHeight

	implicitHeight: maxHeight + shadowOffset
	implicitWidth: maxWidth + shadowOffset

	mask: Region {
		item: barContent
	}

	color: "transparent"

	// ─────────────────────────────────────────────
	// Shadow
	// ─────────────────────────────────────────────

	RectangularShadow {
		anchors.fill: barContent

		radius: bar.quickPanelOpen ? openRadius : normalRadius
		blur: 8
		spread: 0

		offset: Qt.point(0, 2)

		color: Qt.rgba(
			0,
			0,
			0,
			0.25
		)
	}

	// ─────────────────────────────────────────────
	// Bar
	// ─────────────────────────────────────────────

	Rectangle {
		id: barContent

		anchors.horizontalCenter: parent.horizontalCenter

		height: bar.panelHeight()
		width: bar.panelWidth()


		radius: bar.somethingOpen
		? openRadius
		: normalRadius

		color: colors.windowBackground

		MouseArea {
			anchors.fill: parent
			onClicked: {
				if (bar.launcherPanelOpen) {
					bar.launcherPanelOpen = false
					bar.focusable = false
				} else {
					bar.quickPanelOpen = !bar.quickPanelOpen
				}
			}
		}

		// ─────────────────────────────────────────
		// Content
		// ─────────────────────────────────────────

		Item {
			anchors.centerIn: parent
			width: clock.implicitWidth
			height: clock.implicitHeight
			visible: !bar.somethingOpen

			WorkspaceIndicator {
				anchors.right: clock.left
				anchors.rightMargin: 60
				anchors.verticalCenter: clock.verticalCenter
			}

			Clock {
				id: clock
				anchors.centerIn: parent
			}

			BatteryIndicator {
				anchors.left: clock.right
				anchors.leftMargin: 60
				anchors.verticalCenter: clock.verticalCenter
			}
		}

		Launcher {
			id: launcherPanel
			barWindow: bar
			opacity: bar.launcherPanelOpen ? 1 : 0
			visible: bar.launcherPanelOpen || opacity > 0
			anchors.fill: parent
			onCloseRequested: {
				bar.launcherPanelOpen = false
				bar.focusable = false
			}

			Behavior on opacity {
				NumberAnimation {
					duration: bar.launcherPanelOpen ? 150 : 250
					easing.type: bar.launcherPanelOpen
					? Easing.OutCubic
					: Easing.InCubic
				}
			}
		}

		QuickPanel {
			id: quickPanel
			barWindow: bar
			opacity: bar.quickPanelOpen ? 1 : 0
			visible: bar.quickPanelOpen || opacity > 0
			anchors.fill: parent
			onCloseRequested: bar.closeQuickPanel()

			Behavior on opacity {
				NumberAnimation {
					duration: bar.quickPanelOpen ? 150 : 250
					easing.type: bar.quickPanelOpen
					? Easing.OutCubic
					: Easing.InCubic
				}
			}
		}

		// ─────────────────────────────────────────
		// Animations
		// ─────────────────────────────────────────

		Behavior on width {
			NumberAnimation {
				duration: 250
				easing.type: bar.quickPanelOpen
				? Easing.OutCubic
				: Easing.InCubic
			}
		}

		Behavior on height {
			NumberAnimation {
				duration: 250
				easing.type: bar.quickPanelOpen
				? Easing.OutCubic
				: Easing.InCubic
			}
		}
	}

	IpcHandler {
		target: "launcher"
		function toggle() {
			bar.focusable = !bar.launcherPanelOpen
				bar.launcherPanelOpen = !bar.launcherPanelOpen
		}
	}
}

import Quickshell
import QtQuick
import QtQuick.Effects
import qs.modules.bar
import qs.modules.bar.components

PanelWindow {
	id: bar

	property bool quickPanelOpen: false



	readonly property int maxHeight: 700
	readonly property int maxWidth: 700

	readonly property int minHeight: 400

	readonly property int hoverHeight: 240
	readonly property int hoverWidth: 590

	readonly property int normalHeight: 45
	readonly property int normalWidth: 100

	readonly property int normalRadius: 50
	readonly property int hoverRadius: 24

	Colors {
		id: colors
	}

	readonly property int exclusiveZoneHeight: 45
	readonly property int shadowOffset: 2


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

		radius: bar.quickPanelOpen ? hoverRadius : normalRadius
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

		height: bar.quickPanelOpen
		? hoverHeight
		: normalHeight

		width: bar.quickPanelOpen
		? hoverWidth
		: normalWidth

		radius: bar.quickPanelOpen
		? hoverRadius
		: normalRadius

		color: colors.windowBackground

		MouseArea {
			anchors.fill: parent
			onClicked: {
				bar.quickPanelOpen = !bar.quickPanelOpen
			}
		}

		// ─────────────────────────────────────────
		// Content
		// ─────────────────────────────────────────

		Item {
			anchors.centerIn: parent
			width: clock.implicitWidth
			height: clock.implicitHeight
			visible: !bar.quickPanelOpen

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

		QuickPanel {
			barWindow: bar
			opacity: bar.quickPanelOpen ? 1 : 0
			visible: bar.quickPanelOpen || opacity > 0
			anchors.fill: parent
			onCloseRequested: bar.quickPanelOpen = false

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
}

import Quickshell
import QtQuick
import QtQuick.Effects
import qs.modules.bar.components

PanelWindow {
	id: bar

	readonly property int hoverHeight: 232
	readonly property int hoverWidth: 580

	readonly property int normalHeight: 45
	readonly property int normalWidth: 100

	readonly property int normalRadius: 16
	readonly property int hoverRadius: 32

	readonly property string backgroundColor: "#111014"
	readonly property string foregroundColor: "#FAEEF3"

	readonly property int exclusiveZoneHeight: 45
	readonly property int shadowOffset: 2

	// ─────────────────────────────────────────────
	// Window
	// ─────────────────────────────────────────────

	anchors {
		top: true
	}

	margins {
		top: 5
	}

	exclusionMode: ExclusionMode.Normal
	exclusiveZone: exclusiveZoneHeight

	implicitHeight: hoverHeight + shadowOffset
	implicitWidth: hoverWidth + shadowOffset

	mask: Region {
		item: barContent
	}

	color: "transparent"

	// ─────────────────────────────────────────────
	// Shadow
	// ─────────────────────────────────────────────

	RectangularShadow {
		anchors.fill: barContent

		radius: barContent.radius

		blur: 5
		spread: 0.2

		offset: Qt.point(0, shadowOffset)

		color: Qt.darker(
			backgroundColor,
			0.5
		)
	}

	// ─────────────────────────────────────────────
	// Bar
	// ─────────────────────────────────────────────

	Rectangle {
		id: barContent

		anchors.horizontalCenter: parent.horizontalCenter

		height: barMouseArea.containsMouse
		? hoverHeight
		: normalHeight

		width: barMouseArea.containsMouse
		? hoverWidth
		: normalWidth

		radius: barMouseArea.containsMouse
		? hoverRadius
		: normalRadius

		color: backgroundColor

		// ─────────────────────────────────────────
		// Content
		// ─────────────────────────────────────────

		Clock {
			visible: !barMouseArea.containsMouse

			anchors.centerIn: parent
		}

		QuickPanel {
			visible: barMouseArea.containsMouse
			anchors.fill: parent
			Behavior on scale {
				NumberAnimation {
					duration: 100
					easing.type: Easing.OutCubic
				}
			}
		}

		// ─────────────────────────────────────────
		// Animations
		// ─────────────────────────────────────────

		Behavior on width {
			NumberAnimation {
				duration: 100
				easing.type: barMouseArea.containsMouse
				? Easing.OutCubic
				: Easing.InCubic
			}
		}

		Behavior on height {
			NumberAnimation {
				duration: 100
				easing.type: barMouseArea.containsMouse
				? Easing.OutCubic
				: Easing.InCubic
			}
		}

		Behavior on radius {
			NumberAnimation {
				duration: 250
				easing.type: Easing.OutCubic
			}
		}

		// ─────────────────────────────────────────
		// Hover detection ONLY
		// ─────────────────────────────────────────

		MouseArea {
			id: barMouseArea

			anchors.fill: parent

			hoverEnabled: true

			acceptedButtons: Qt.NoButton
		}
	}
}

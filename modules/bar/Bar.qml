import Quickshell
import QtQuick
import QtQuick.Effects
import qs.modules.bar.components

PanelWindow {
	id: bar

	readonly property int maxHeight: 700
	readonly property int maxWidth: 700

	readonly property int minHeight: 400

	readonly property int hoverHeight: 162
	readonly property int hoverWidth: 580

	readonly property int normalHeight: 45
	readonly property int normalWidth: 100

	readonly property int normalRadius: 16
	readonly property int hoverRadius: 24

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
		radius: barArea.hovered ? hoverRadius : normalRadius
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

		height: barArea.hovered
		? hoverHeight
		: normalHeight

		width: barArea.hovered
		? hoverWidth
		: normalWidth

		radius: barArea.hovered
		? hoverRadius
		: normalRadius

		color: backgroundColor

		// ─────────────────────────────────────────
		// Content
		// ─────────────────────────────────────────

		Clock {
			visible: !barArea.hovered
			anchors.centerIn: parent
		}

		QuickPanel {
			visible: barArea.hovered
			anchors.fill: parent

			Behavior on visible {
				NumberAnimation {
					duration: barArea.hovered ? 150 : 250
					easing.type: barArea.hovered
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
				easing.type: barArea.hovered
				? Easing.OutCubic
				: Easing.InCubic
			}
		}

		Behavior on height {
			NumberAnimation {
				duration: 250
				easing.type: barArea.hovered
				? Easing.OutCubic
				: Easing.InCubic
			}
		}

		// ─────────────────────────────────────────
		// Hover detection ONLY
		// ─────────────────────────────────────────

		HoverHandler {
			id: barArea
		}
	}
}

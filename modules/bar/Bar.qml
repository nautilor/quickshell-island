import Quickshell
import QtQuick
import QtQuick.Effects

PanelWindow {
	id: bar

	readonly property int hoverHeight: 200
	readonly property int hoverWidth: 500
	readonly property int normalHeight: 45
	readonly property int normalWidth: 100
	readonly property int hoverRadius: 32
	readonly property int normalRadius: 16
	readonly property string backgroundColor: "#111014"
	readonly property string foregroundColor: "#FAEEF3"

	readonly property int exclusiveZoneHeight: 45
	readonly property int shadowOffset: 2

	anchors {
		top: true
	}
	margins {
		top: 5
	}

	exclusionMode: ExclusionMode.Normal
	exclusiveZone: exclusiveZoneHeight
	implicitHeight: hoverHeight + shadowOffset
	implicitWidth: hoverWidth
	mask: Region {
		item: barContent
	}
	color: "transparent"

	RectangularShadow {
		anchors.fill: barContent
		radius: barMouseArea.containsMouse ? hoverRadius : normalRadius
		blur: 5
		spread: 0.2
		offset: Qt.point(0, shadowOffset)
		color: Qt.DarkerColor(backgroundColor, 0.5)
	}

	Rectangle {
		id: barContent
		anchors.horizontalCenter: parent.horizontalCenter
		height: barMouseArea.containsMouse ? hoverHeight : normalHeight
		width: barMouseArea.containsMouse ? hoverWidth : normalWidth
		color: backgroundColor
		radius: barMouseArea.containsMouse ? hoverRadius : normalRadius

		Text {
			anchors.centerIn: parent
			text: Qt.formatDateTime(new Date(), "hh:mm:ss")
			Timer {
				interval: 1000
				repeat: true
				running: true
				onTriggered: {
					parent.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
				}
			}
			color: "white"
		}

		Behavior on width {
			NumberAnimation {
				duration: 200
				easing.type: Easing.InOutQuad
			}
		}

		Behavior on height {
			NumberAnimation {
				duration: 200
				easing.type: Easing.InOutQuad
			}
		}

		MouseArea {
			id: barMouseArea
			anchors.fill: parent
			hoverEnabled: true
			onClicked: {
				console.log("Bar clicked")
			}
		}
	}
}

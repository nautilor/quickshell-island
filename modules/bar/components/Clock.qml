import Quickshell
import QtQuick

Item {
	id: clock

	readonly property string foregroundColor: "#FAEEF3"
	property string time: Qt.formatDateTime(new Date(), "hh:mm")

	Text {
		id: clockText
		anchors.centerIn: parent
		text: clock.time
		color: clock.foregroundColor
	}

	Behavior {
		NumberAnimation {
			duration: 100
			easing.type: barMouseArea.containsMouse ? Easing.OutCubic : Easing.InCubic
		}
	}

	Timer {
		interval: 1000
		repeat: true
		running: true
		onTriggered: {
			clock.time = Qt.formatDateTime(new Date(), "hh:mm")
		}
	}
}

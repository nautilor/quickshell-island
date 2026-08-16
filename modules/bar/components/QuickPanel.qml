import Quickshell
import QtQuick

Item {
	id: quickPanel
	anchors.margins: 10

	Rectangle {
		id: quickPanelBackground
		anchors.fill: parent
		color: "#111014"

		Grid {
			id: quickPanelGrid
			anchors.fill: parent
			columns: 3
			rows: 3
			columnSpacing: 10
			rowSpacing: 10

			Bluetooth {
				width: 180
				height: 64
			}

			Wifi {
				width: 180
				height: 64
			}

			DoNotDisturb {
				width: 180
				height: 64
			}

			Microphone {
				width: 180
				height: 64
			}

			PowerProfiles {
				width: 180
				height: 64
			}

			Battery {
				width: 180
				height: 64
			}

			Caffeine {
				width: 180
				height: 64
			}
		}
	}
}

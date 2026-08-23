import Quickshell
import QtQuick
import qs.modules.bar
import qs.modules.bar.components.quickpanel

Item {
	id: quickPanel
	anchors.margins: 10

Colors {
	id: colors
}

Rectangle {
	id: quickPanelBackground
	anchors.fill: parent
	color: colors.quickPanelBackground

	Grid {
		anchors.fill: parent
		columns: 1
		rows: 2

		Grid {
			id: quickPanelGrid
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
}

import Quickshell
import QtQuick
import qs.modules.bar
import qs.modules.bar.components.quickpanel

Item {
	id: quickPanel
	signal closeRequested()
	anchors.margins: 10

Colors {
	id: colors
}

Rectangle {
	id: quickPanelBackground
	anchors.fill: parent
	color: colors.quickPanelBackground

	Column {
		anchors.fill: parent
		anchors.margins: 10
		spacing: 10

		Item {
			width: parent.width
			height: 24

			Rectangle {
				width: 24
				height: 24
				radius: 12
				anchors.right: parent.right
				color:closeButtonHoverHandler.hovered ? Qt.lighter(colors.quickToggleBackground, 1.50) : colors.quickToggleBackground
				Text {
					anchors.centerIn: parent
					text: "×"
					font.pixelSize: 16
					font.weight: Font.Medium
					color: colors.quickToggleForeground
				}

				MouseArea {
					anchors.fill: parent
					onClicked: quickPanel.closeRequested()
				}
				HoverHandler {
					id: closeButtonHoverHandler
				}
			}
		}

		Grid {
			id: quickPanelGrid
			columns: 3
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

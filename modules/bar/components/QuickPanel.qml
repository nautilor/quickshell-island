import Quickshell
import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.modules.bar
import qs.modules.bar.components.quickpanel

Item {
	id: quickPanel
	signal closeRequested()
	property var barWindow: null
	property string time: Qt.formatDateTime(new Date(), "h:mm")
	property string date: Qt.formatDateTime(new Date(), "ddd, MMM d")
	readonly property var trayItems: {
		const items = SystemTray.items.values || [];
		return items.filter(item => item && item.status !== Status.Passive);
	}

Colors {
	id: colors
}

Timer {
	interval: 1000
	repeat: true
	running: true
	onTriggered: {
		quickPanel.time = Qt.formatDateTime(new Date(), "h:mm")
		quickPanel.date = Qt.formatDateTime(new Date(), "ddd, MMM d")
	}
}

function trayItemClick(item, point, alternate) {
	if (!item)
		return;

	if (item.hasMenu) {
		item.display(barWindow, point.x, point.y);
		return;
	}

	if (alternate)
		item.secondaryActivate();
	else
		item.activate();
}

Rectangle {
	id: quickPanelBackground
	anchors.fill: parent
	anchors.margins: 10
	color: colors.quickPanelBackground
	radius: 24

	Item {
		id: content
		anchors.fill: parent
		anchors.margins: 10

		Column {
			anchors.fill: parent
			spacing: 20

			Item {
				width: parent.width
				height: 52

				Column {
					anchors.left: parent.left
					anchors.top: parent.top

					Text {
						text: quickPanel.time
						color: colors.windowForeground
						font.pixelSize: 38
						font.weight: Font.Medium
					}

					Text {
						text: quickPanel.date
						color: colors.windowForeground
						font.pixelSize: 13
						opacity: 0.85
					}
				}

				Rectangle {
					width: 28
					height: 28
					radius: 14
					anchors.right: parent.right
					color: closeButtonHoverHandler.hovered
					? Qt.lighter(colors.quickToggleBackground, 1.10)
					: colors.quickToggleBackground

					Text {
						anchors.centerIn: parent
						text: "×"
						font.pixelSize: 18
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

			Item {
				width: parent.width
				height: 24

				Row {
					id: trayRow
					anchors.right: parent.right
					spacing: 8

					Repeater {
						model: quickPanel.trayItems

						delegate: Item {
							required property var modelData

							implicitWidth: 24
							implicitHeight: 24

							Rectangle {
								anchors.fill: parent
								radius: width / 2
								color: trayMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
							}

							MouseArea {
								id: trayMouse
								anchors.fill: parent
								acceptedButtons: Qt.LeftButton | Qt.RightButton
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: function(mouse) {
									const point = mapToItem(content, 0, height);
									quickPanel.trayItemClick(modelData, point, mouse.button === Qt.RightButton);
								}
							}

							IconImage {
								anchors.centerIn: parent
								implicitSize: 18
								source: modelData.icon
							}
						}
					}
				}
			}
		}
	}
}
}

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules.colors

Item {
	id: root

	property string mode: "meter"
	property string title: ""
	property string subtitle: ""
	property string iconName: ""
	property string iconGlyph: ""
	property real level: 0
	property int percent: 0

	property color accentBackgroundColor: colors.quickToggleActiveBackground
	property color accentForegroundColor: colors.quickToggleActiveForeground

	Colors {
		id: colors
	}

	readonly property color bgPrimary: colors.windowBackground
	readonly property color bgSecondary: colors.quickToggleBackground
	readonly property color textPrimary: colors.windowForeground
	readonly property color textMuted: colors.foregroundMuted

	readonly property bool messageMode: mode === "message"
	readonly property int osdWidth: 340
	readonly property int osdHeight: 72
	readonly property int messageMaxWidth: 440
	readonly property int messageMinWidth: 240
	readonly property int messageIconSize: 30
	readonly property int messageBubbleSize: 40
	readonly property int messageSpacing: 12
	readonly property int messagePaddingX: 16
	readonly property int messagePaddingY: 12

	TextMetrics {
		id: titleMetrics
		text: root.title
		font.pixelSize: 14
		font.weight: Font.DemiBold
	}

	TextMetrics {
		id: subtitleMetrics
		text: root.subtitle
		font.pixelSize: 12
		font.weight: Font.Medium
	}

	TextMetrics {
		id: percentMetrics
		text: `${Math.max(0, Math.min(100, root.percent))}%`
		font.pixelSize: 14
		font.weight: Font.DemiBold
	}

	readonly property int messagePillWidth: {
		const textWidth = Math.max(titleMetrics.width || 0, subtitleMetrics.width || 0)
		const contentWidth = messageBubbleSize + messageSpacing + textWidth
		const width = Math.ceil(contentWidth + (messagePaddingX * 2))
		return Math.min(messageMaxWidth, Math.max(messageMinWidth, width))
	}

	implicitWidth: messageMode ? messagePillWidth : osdWidth
	implicitHeight: messageMode ? 76 : osdHeight

	Rectangle {
		anchors.fill: parent
		radius: height / 2
		color: bgSecondary
		opacity: 0.98
		border.width: 1
		clip: true

		Rectangle {
			anchors.fill: parent
			radius: parent.radius
			color: bgPrimary
		}

		Item {
			visible: !root.messageMode
			anchors.fill: parent

			RowLayout {
				anchors.fill: parent
				anchors.leftMargin: 16
				anchors.rightMargin: 16
				spacing: 12

				Item {
					implicitWidth: 40
					implicitHeight: 40

					Rectangle {
						anchors.fill: parent
						radius: width / 2
						color: Qt.alpha(root.accentBackgroundColor, 0.8)
						border.width: 1
						border.color: Qt.alpha(root.accentBackgroundColor, 0.28)
					}

					Text {
						anchors.fill: parent
						visible: root.iconGlyph !== ""
						text: root.iconGlyph
						color: root.accentForegroundColor
						font.pixelSize: 26
						font.weight: Font.DemiBold
						font.family: "JetBrainsMono Nerd Font Propo"
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}

					IconImage {
						anchors.fill: parent
						visible: root.iconGlyph === ""
						implicitSize: 26
						source: Quickshell.iconPath(root.iconName)
					}
				}

				Rectangle {
					Layout.fillWidth: true
					implicitHeight: 10
					radius: 20
					color: Qt.alpha(colors.quickToggleBackground, 0.8)

					Rectangle {
						anchors {
							left: parent.left
							top: parent.top
							bottom: parent.bottom
						}
						width: parent.width * Math.max(0, Math.min(1, root.level))
						radius: parent.radius
						color: root.accentBackgroundColor
					}
				}

				Rectangle {
					implicitWidth: percentMetrics.width + 18
					implicitHeight: 28
					radius: height / 2
					color: colors.quickToggleBackground

					Text {
						anchors.centerIn: parent
						text: `${Math.max(0, Math.min(100, root.percent))}%`
						color: colors.windowForeground
						font.pixelSize: 13
						font.weight: Font.DemiBold
					}
				}
			}
		}

		Item {
			visible: root.messageMode
			anchors.fill: parent

			RowLayout {
				anchors.fill: parent
				anchors.leftMargin: root.messagePaddingX
				anchors.rightMargin: root.messagePaddingX
				anchors.topMargin: root.messagePaddingY
				anchors.bottomMargin: root.messagePaddingY
				spacing: root.messageSpacing

				Item {
					Layout.preferredWidth: root.messageBubbleSize
					Layout.preferredHeight: root.messageBubbleSize

					Rectangle {
						anchors.fill: parent
						radius: width / 2
						color: Qt.alpha(root.accentBackgroundColor, 0.9)
						border.width: 1
					}

					Text {
						anchors.fill: parent
						visible: root.iconGlyph !== ""
						text: root.iconGlyph
						color: root.accentForegroundColor
						font.pixelSize: 20
						font.weight: Font.DemiBold
						font.family: "JetBrainsMono Nerd Font Propo"
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}

					IconImage {
						anchors.fill: parent
						visible: root.iconGlyph === ""
						implicitSize: root.messageIconSize
						source: Quickshell.iconPath(root.iconName)
					}
				}

				ColumnLayout {
					Layout.fillWidth: true
					Layout.alignment: Qt.AlignVCenter
					spacing: 1

					Text {
						Layout.fillWidth: true
						text: root.title
						color: colors.windowForeground
						font.pixelSize: 14
						font.weight: Font.DemiBold
						elide: Text.ElideRight
						maximumLineCount: 1
					}

					Text {
						Layout.fillWidth: true
						visible: root.subtitle !== ""
						text: root.subtitle
						color: colors.foregroundMuted
						font.pixelSize: 12
						font.weight: Font.Medium
						elide: Text.ElideRight
						maximumLineCount: 1
					}
				}
			}
		}
	}
}

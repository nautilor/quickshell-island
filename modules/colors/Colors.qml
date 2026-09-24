import Quickshell
import QtQuick

QtObject {
	readonly property color background: "#101017"
	readonly property color accentColor: "#6689D0"
	readonly property color foreground: "#99A1C5"
	readonly property color foregroundMuted: "#5C6370"
	readonly property color critical: "#E06C75"
	readonly property color warning: "#E5C07B"
	readonly property color success: "#98C379"
	readonly property color windowBackground: background
	readonly property color windowForeground: foreground

	readonly property color quickPanelBackground: windowBackground

	readonly property color quickToggleBackground: "#282C34"
	readonly property color quickToggleForeground: "#B8C3E5"
	readonly property color quickToggleActiveBackground: accentColor
	readonly property color quickToggleActiveForeground: "#D7DAE0"
}

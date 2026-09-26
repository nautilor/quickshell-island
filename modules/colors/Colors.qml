import Quickshell
import QtQuick

QtObject {
	readonly property color background: "#0B1020"
	readonly property color surface: "#12192B"
	readonly property color surfaceContainerLow: "#172036"
	readonly property color surfaceContainer: "#1D2942"
	readonly property color surfaceContainerHigh: "#25344F"
	readonly property color surfaceContainerHighest: "#2D3E5E"
	readonly property color surfaceVariant: "#344766"

	readonly property color primary: "#8FB4FF"
	readonly property color primaryForeground: "#0C1A33"
	readonly property color primaryContainer: "#23416F"
	readonly property color primaryContainerForeground: "#DCE8FF"

	readonly property color secondary: "#B5C8F7"
	readonly property color secondaryForeground: "#11233C"
	readonly property color secondaryContainer: "#22314B"
	readonly property color secondaryContainerForeground: "#DEE8FF"

	readonly property color tertiary: "#D3B7FF"
	readonly property color tertiaryForeground: "#29144D"
	readonly property color tertiaryContainer: "#413061"
	readonly property color tertiaryContainerForeground: "#F0E4FF"

	readonly property color surfaceForeground: "#E8EEFF"
	readonly property color surfaceVariantForeground: "#B6C1DD"
	readonly property color outline: "#667594"
	readonly property color outlineVariant: "#41506D"

	readonly property color error: "#FFB4AB"
	readonly property color errorContainer: "#693C3D"
	readonly property color errorContainerForeground: "#FFDAD6"

	readonly property color warning: "#EFCB72"
	readonly property color warningContainer: "#52431B"
	readonly property color warningContainerForeground: "#FFF0C2"

	readonly property color success: "#8FD7A7"
	readonly property color successContainer: "#1F4C36"
	readonly property color successContainerForeground: "#D9FFE4"

	readonly property int radiusNone: 0
	readonly property int radiusExtraSmall: 4
	readonly property int radiusSmall: 8
	readonly property int radiusMedium: 12
	readonly property int radiusLarge: 16
	readonly property int radiusLargeIncreased: 20
	readonly property int radiusExtraLarge: 28
	readonly property int radiusHero: 48
	readonly property int radiusFull: 999

	readonly property int sizeXs: 32
	readonly property int sizeSmall: 40
	readonly property int sizeMedium: 48
	readonly property int sizeLarge: 56
	readonly property int sizeExtraLarge: 64

	readonly property int displaySmall: 36
	readonly property int headlineSmall: 24
	readonly property int titleLarge: 22
	readonly property int titleMedium: 16
	readonly property int titleSmall: 14
	readonly property int bodyLarge: 16
	readonly property int bodyMedium: 14
	readonly property int bodySmall: 12
	readonly property int labelLarge: 14
	readonly property int labelMedium: 12
	readonly property int labelSmall: 11

	readonly property int spacing2: 2
	readonly property int spacing4: 4
	readonly property int spacing8: 8
	readonly property int spacing12: 12
	readonly property int spacing16: 16
	readonly property int spacing20: 20
	readonly property int spacing24: 24
	readonly property int spacing32: 32

	readonly property int effectsDuration: 180
	readonly property int spatialDuration: 280

	readonly property color windowBackground: background
	readonly property color windowForeground: surfaceForeground
	readonly property color foreground: surfaceForeground
	readonly property color foregroundMuted: surfaceVariantForeground
	readonly property color accentColor: primary
	readonly property color critical: error

	readonly property color quickPanelBackground: background
	readonly property color quickToggleBackground: surfaceContainer
	readonly property color quickToggleForeground: surfaceForeground
	readonly property color quickToggleActiveBackground: primaryContainer
	readonly property color quickToggleActiveForeground: primaryContainerForeground
}

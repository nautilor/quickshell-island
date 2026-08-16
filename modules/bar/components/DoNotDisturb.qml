import Quickshell
import QtQuick
import Quickshell.Services.Notifications

Item {
    id: root

    // ─────────────────────────────────────────────
    // State
    // ─────────────────────────────────────────────

    readonly property bool dndEnabled:
        NotificationServer.dnd

    // ─────────────────────────────────────────────
    // Toggle
    // ─────────────────────────────────────────────

    QuickToggle {
        id: toggle

        anchors.fill: parent

        checked: root.dndEnabled

        activeIcon: "󰂛"
        inactiveIcon: "󰂚"

        label: "Do Not Disturb"

        subLabel: root.dndEnabled
            ? "On"
            : "Off"

        onToggled: {
            NotificationServer.dnd = !NotificationServer.dnd
        }
    }
}

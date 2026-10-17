import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.colors

Item {
	id: root

	signal closeRequested()

	property var barWindow: null

	// "checking" | "no-client" | "logged-out" | "ready"
	property string authState: "checking"
	property string clientFile: "$HOME/.config/quickshell/gcal/client.json"
	property string errorText: ""
	property bool loading: false
	property bool loggingIn: false

	property date today: new Date()
	property int viewYear: today.getFullYear()
	property int viewMonth: today.getMonth()
	property date selected: new Date(today.getFullYear(), today.getMonth(), today.getDate())

	property var events: []
	property string loadedKey: ""
	property string requestedKey: ""

	readonly property string script: "$HOME/.config/quickshell/bin/gcal.py"
	readonly property var weekdayNames: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

	Colors {
		id: colors
	}

	readonly property color bgPrimary: colors.windowBackground
	readonly property color textPrimary: colors.windowForeground
	readonly property color textMuted: Qt.rgba(textPrimary.r, textPrimary.g, textPrimary.b, 0.65)
	readonly property color bgSecondary: colors.quickToggleBackground
	readonly property color accent: colors.quickToggleActiveBackground
	readonly property color accentForeground: colors.quickToggleActiveForeground
	readonly property color hoverFill: Qt.rgba(1, 1, 1, 0.06)

	// ─── date helpers ───────────────────────────────

	function startOfDay(d) {
		return new Date(d.getFullYear(), d.getMonth(), d.getDate())
	}

	function sameDay(a, b) {
		return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
	}

	function parseEventDate(str, allDay) {
		if (allDay) {
			const p = str.split("-")
			return new Date(parseInt(p[0]), parseInt(p[1]) - 1, parseInt(p[2]))
		}
		return new Date(str)
	}

	function gridStart() {
		const first = new Date(viewYear, viewMonth, 1)
		const offset = (first.getDay() + 6) % 7
		return new Date(viewYear, viewMonth, 1 - offset)
	}

	function dayAt(index) {
		const s = gridStart()
		return new Date(s.getFullYear(), s.getMonth(), s.getDate() + index)
	}

	function eventsOn(day) {
		const ds = startOfDay(day)
		const de = new Date(ds.getFullYear(), ds.getMonth(), ds.getDate() + 1)
		const result = []
		for (const ev of events) {
			const s = parseEventDate(ev.start, ev.allDay)
			const e = parseEventDate(ev.end, ev.allDay)
			if (s < de && (e > ds || (e.getTime() === s.getTime() && s >= ds)))
				result.push({ ev: ev, start: s, end: e })
		}
		result.sort((a, b) => (b.ev.allDay - a.ev.allDay) || (a.start - b.start))
		return result
	}

	readonly property real hourHeight: 48

	// lay out timed events of a day in side-by-side lanes (overlapping events share the width)
	function timedLayout(day) {
		const ds = startOfDay(day)
		const de = new Date(ds.getFullYear(), ds.getMonth(), ds.getDate() + 1)
		const items = []
		for (const it of eventsOn(day)) {
			if (it.ev.allDay)
				continue
			const s = it.start < ds ? ds : it.start
			const e = it.end > de ? de : it.end
			const sm = (s - ds) / 60000
			const em = Math.max((e - ds) / 60000, sm + 30)
			items.push({ ev: it.ev, start: it.start, end: it.end, sm: sm, em: em, lane: 0, lanes: 1 })
		}
		items.sort((a, b) => a.sm - b.sm || b.em - a.em)
		let cluster = [], clusterEnd = -1, laneEnds = []
		const flush = () => {
			for (const c of cluster)
				c.lanes = laneEnds.length
			cluster = []
			laneEnds = []
		}
		for (const it of items) {
			if (it.sm >= clusterEnd)
				flush()
			let lane = laneEnds.findIndex(end => end <= it.sm)
			if (lane < 0) {
				lane = laneEnds.length
				laneEnds.push(0)
			}
			laneEnds[lane] = it.em
			it.lane = lane
			cluster.push(it)
			clusterEnd = cluster.length === 1 ? it.em : Math.max(clusterEnd, it.em)
		}
		flush()
		return items
	}

	function allDayEvents(day) {
		return eventsOn(day).filter(it => it.ev.allDay)
	}

	function scrollTimeline() {
		let minute = 8 * 60
		const laid = timedLayout(selected)
		if (laid.length > 0)
			minute = laid[0].sm
		else if (sameDay(selected, today))
			minute = today.getHours() * 60
		const maxY = Math.max(0, timeline.contentHeight - timeline.height)
		timeline.contentY = Math.max(0, Math.min(maxY, minute / 60 * hourHeight - 12))
	}

	function timeLabel(item) {
		if (item.ev.allDay)
			return "All day"
		return Qt.formatTime(item.start, "hh:mm") + " – " + Qt.formatTime(item.end, "hh:mm")
	}

	function shiftMonth(delta) {
		const d = new Date(viewYear, viewMonth + delta, 1)
		viewYear = d.getFullYear()
		viewMonth = d.getMonth()
		refresh()
	}

	function goToday() {
		today = new Date()
		viewYear = today.getFullYear()
		viewMonth = today.getMonth()
		selected = startOfDay(today)
		refresh()
	}

	// ─── backend ────────────────────────────────────

	function checkStatus() {
		statusProcess.running = true
	}

	function refresh() {
		if (authState !== "ready")
			return
		const key = viewYear + "-" + viewMonth
		const from = gridStart()
		const to = dayAt(42)
		requestedKey = key
		loading = true
		eventsProcess.command = [
			"bash", "-lc",
			'python3 "' + script + '" events ' + Qt.formatDate(from, "yyyy-MM-dd") + " " + Qt.formatDate(to, "yyyy-MM-dd")
		]
		eventsProcess.running = true
	}

	Process {
		id: statusProcess
		command: ["bash", "-lc", 'python3 "' + root.script + '" status']

		stdout: StdioCollector {
			onStreamFinished: {
				try {
					const r = JSON.parse(this.text)
					root.authState = r.state
					if (r.clientFile)
						root.clientFile = r.clientFile
					if (r.state === "ready")
						root.refresh()
				} catch (e) {
					root.authState = "no-client"
				}
			}
		}
	}

	Process {
		id: eventsProcess

		stdout: StdioCollector {
			onStreamFinished: {
				root.loading = false
				try {
					const r = JSON.parse(this.text)
					if (r.error) {
						root.errorText = r.error === "auth" ? "Session expired. Sign in again."
							: r.error === "network" ? "Offline." : "Calendar error: " + r.error
						if (r.error === "auth")
							root.authState = "logged-out"
						return
					}
					root.errorText = ""
					root.events = r.events
					root.loadedKey = root.requestedKey
				} catch (e) {
					root.errorText = "Could not read calendar data."
				}
			}
		}
	}

	Process {
		id: loginProcess
		command: ["bash", "-lc", 'python3 "' + root.script + '" login']

		stdout: StdioCollector {
			onStreamFinished: {
				root.loggingIn = false
				try {
					const r = JSON.parse(this.text)
					root.errorText = r.error ? "Login failed (" + r.error + ")" : ""
				} catch (e) {
					root.errorText = "Login failed."
				}
				root.checkStatus()
			}
		}
	}

	Process {
		id: logoutProcess
		command: ["bash", "-lc", 'python3 "' + root.script + '" logout']
		onRunningChanged: if (!running) {
			root.events = []
			root.checkStatus()
		}
	}

	onVisibleChanged: {
		if (visible) {
			today = new Date()
			if (authState === "ready")
				refresh()
			else
				checkStatus()
		}
	}

	Timer {
		interval: 300000
		repeat: true
		running: root.visible && root.authState === "ready"
		onTriggered: root.refresh()
	}

	// ─── ui ─────────────────────────────────────────

	anchors.fill: parent

	Rectangle {
		anchors.fill: parent
		anchors.margins: 12
		color: root.bgPrimary
		radius: 24

		// message states (checking / no client / signed out)
		ColumnLayout {
			anchors.centerIn: parent
			width: parent.width - 80
			spacing: 14
			visible: root.authState !== "ready"

			Rectangle {
				Layout.alignment: Qt.AlignHCenter
				Layout.preferredWidth: 64
				Layout.preferredHeight: 64
				radius: 50
				color: root.hoverFill

				Text {
					anchors.centerIn: parent
					text: "󰃭"
					color: root.accent
					font.pixelSize: 30
					font.weight: Font.Medium
					font.family: "JetBrainsMono Nerd Font Propo"
				}
			}

			Text {
				Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.WordWrap
				color: root.textPrimary
				font.pixelSize: 14
				font.weight: Font.Medium
				text: root.authState === "checking" ? "Checking Google Calendar…"
					: root.authState === "no-client" ? "Google OAuth client missing"
					: "Sign in to see your events"
			}

			Text {
				Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.WrapAnywhere
				visible: root.authState === "no-client"
				color: root.textMuted
				font.pixelSize: 12
				text: "Save client_id / client_secret to " + root.clientFile
			}

			Text {
				Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.WordWrap
				visible: root.errorText !== ""
				text: root.errorText
				color: colors.error
				font.pixelSize: 12
			}

			Rectangle {
				Layout.alignment: Qt.AlignHCenter
				visible: root.authState === "logged-out" || root.authState === "no-client"
				implicitWidth: btnText.implicitWidth + 40
				implicitHeight: 44
				radius: 50
				color: signInArea.containsMouse ? Qt.lighter(root.accent, 1.12) : root.accent
				opacity: root.loggingIn ? 0.6 : 1

				Behavior on color {
					ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
				}

				Text {
					id: btnText
					anchors.centerIn: parent
					text: root.authState === "no-client" ? "Re-check" : root.loggingIn ? "Waiting for browser…" : "Sign in with Google"
					color: root.accentForeground
					font.pixelSize: 14
					font.weight: Font.Medium
				}

				MouseArea {
					id: signInArea
					anchors.fill: parent
					hoverEnabled: true
					enabled: !root.loggingIn
					cursorShape: Qt.PointingHandCursor
					onClicked: {
						if (root.authState === "no-client") {
							root.checkStatus()
						} else {
							root.loggingIn = true
							loginProcess.running = true
						}
					}
				}
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 12
			spacing: 12
			visible: root.authState === "ready"

			// header pill (same shape as launcher search)
			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 50
				radius: 50
				color: root.bgSecondary

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 14
					anchors.rightMargin: 8
					spacing: 10

					Text {
						Layout.fillWidth: true
						text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
						color: root.textPrimary
						font.pixelSize: 16
						font.weight: Font.Medium
						elide: Text.ElideRight
					}

					Repeater {
						model: [
							{ g: "󰅁", act: "prev" },
							{ g: "󰅂", act: "next" },
						]

						Rectangle {
							id: hdrBtn
							required property var modelData
							Layout.preferredWidth: 34
							Layout.preferredHeight: 34
							radius: 50
							color: hdrArea.containsMouse ? root.hoverFill : "transparent"

							Behavior on color {
								ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
							}

							Text {
								anchors.centerIn: parent
								text: hdrBtn.modelData.g
								color: hdrBtn.modelData.act === "today" ? root.accent : root.textPrimary
								font.pixelSize: 18
								font.weight: Font.Medium
								font.family: "JetBrainsMono Nerd Font Propo"
							}

							MouseArea {
								id: hdrArea
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: {
									const a = hdrBtn.modelData.act
									if (a === "prev") root.shiftMonth(-1)
									else if (a === "next") root.shiftMonth(1)
									else if (a === "today") root.goToday()
									else logoutProcess.running = true
								}
							}
						}
					}
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				spacing: 16

				// month grid
				ColumnLayout {
					Layout.preferredWidth: 280
					Layout.fillHeight: true
					spacing: 4

					Row {
						Repeater {
							model: root.weekdayNames

							Text {
								required property string modelData
								width: 280 / 7
								horizontalAlignment: Text.AlignHCenter
								text: modelData
								color: root.textMuted
								font.pixelSize: 11
								font.weight: Font.Medium
							}
						}
					}

					Grid {
						id: dayGrid
						columns: 7
						readonly property real cell: 280 / 7

						Repeater {
							model: 42

							Item {
								id: cellItem
								required property int index
								readonly property date day: root.dayAt(index)
								readonly property bool inMonth: day.getMonth() === root.viewMonth
								readonly property bool isToday: root.sameDay(day, root.today)
								readonly property bool isSelected: root.sameDay(day, root.selected)

								width: dayGrid.cell
								height: 40

								Rectangle {
									anchors.centerIn: parent
									width: 36
									height: 36
									radius: 12
									color: cellItem.isSelected ? root.accent
										: cellItem.isToday ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.20)
										: cellArea.containsMouse ? root.hoverFill : "transparent"

									Behavior on color {
										ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
									}

									Text {
										anchors.centerIn: parent
										text: cellItem.day.getDate()
										color: cellItem.isSelected ? root.accentForeground
											: cellItem.isToday ? root.accent : root.textPrimary
										opacity: cellItem.inMonth || cellItem.isSelected ? 1 : 0.4
										font.pixelSize: 13
										font.weight: Font.Medium
									}
								}

								MouseArea {
									id: cellArea
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: Qt.PointingHandCursor
									onClicked: {
										root.selected = root.startOfDay(cellItem.day)
										if (!cellItem.inMonth)
											root.shiftMonth(cellItem.day < new Date(root.viewYear, root.viewMonth, 1) ? -1 : 1)
									}
								}
							}
						}
					}

					Item { Layout.fillHeight: true }
				}

				// events for selected day
				ColumnLayout {
					Layout.fillWidth: true
					Layout.fillHeight: true
					spacing: 8

					RowLayout {
						Layout.fillWidth: true

						Text {
							Layout.fillWidth: true
							text: Qt.formatDate(root.selected, "dddd, MMM d")
							color: root.textPrimary
							font.pixelSize: 14
							font.weight: Font.Medium
							elide: Text.ElideRight
						}

						Text {
							visible: root.loading
							text: "Syncing…"
							color: root.textMuted
							font.pixelSize: 12
						}
					}

					Text {
						Layout.fillWidth: true
						visible: root.errorText !== ""
						text: root.errorText
						color: colors.error
						font.pixelSize: 12
						wrapMode: Text.WordWrap
					}

					// all-day events
					Flow {
						Layout.fillWidth: true
						spacing: 6
						visible: allDayRepeater.count > 0

						Repeater {
							id: allDayRepeater
							model: (root.events, root.allDayEvents(root.selected))

							Rectangle {
								required property var modelData
								height: 24
								width: Math.min(chipText.implicitWidth + 20, 340)
								radius: 12
								color: Qt.alpha(modelData.ev.color, 0.30)

								Text {
									id: chipText
									anchors.fill: parent
									anchors.leftMargin: 10
									anchors.rightMargin: 10
									verticalAlignment: Text.AlignVCenter
									text: parent.modelData.ev.title
									color: root.textPrimary
									font.pixelSize: 12
									font.weight: Font.Medium
									elide: Text.ElideRight
								}
							}
						}
					}

					// day timeline
					Flickable {
						id: timeline
						Layout.fillWidth: true
						Layout.fillHeight: true
						clip: true
						contentWidth: width
						contentHeight: 24 * root.hourHeight + 16
						boundsBehavior: Flickable.StopAtBounds

						Connections {
							target: root
							function onSelectedChanged() { root.scrollTimeline() }
							function onLoadedKeyChanged() { root.scrollTimeline() }
							function onVisibleChanged() { if (root.visible) root.scrollTimeline() }
						}

						Repeater {
							model: 24

							Item {
								required property int index
								y: index * root.hourHeight + 8
								width: timeline.width
								height: root.hourHeight

								Text {
									x: 0
									y: -7
									width: 36
									text: Qt.formatTime(new Date(2000, 0, 1, parent.index, 0), "hh:mm")
									color: root.textMuted
									font.pixelSize: 10
								}

								Rectangle {
									x: 42
									width: parent.width - 42
									height: 1
									color: Qt.rgba(1, 1, 1, 0.08)
								}
							}
						}

						Item {
							id: lanesArea
							x: 46
							y: 8
							width: timeline.width - 46
							height: 24 * root.hourHeight

							Repeater {
								model: (root.events, root.timedLayout(root.selected))

								Rectangle {
									id: block
									required property var modelData
									readonly property real laneWidth: lanesArea.width / modelData.lanes
									x: modelData.lane * laneWidth
									y: modelData.sm / 60 * root.hourHeight + 1
									width: laneWidth - 2 + (modelData.lane < modelData.lanes - 1 ? 8 : 0)
									z: modelData.lane
									height: Math.max(20, (modelData.em - modelData.sm) / 60 * root.hourHeight - 2)
									radius: 8
									color: Qt.tint(root.bgPrimary, Qt.alpha(modelData.ev.color, 0.38))
									border.width: 1
									border.color: Qt.alpha(modelData.ev.color, 0.9)
									clip: true

									Column {
										anchors.fill: parent
										anchors.margins: 5
										anchors.leftMargin: 7
										spacing: 0

										Text {
											width: parent.width
											text: block.modelData.ev.title
											color: root.textPrimary
											font.pixelSize: 12
											font.weight: Font.Medium
											elide: Text.ElideRight
										}

										Text {
											width: parent.width
											visible: block.height >= 40
											text: root.timeLabel(block.modelData)
											color: root.textMuted
											font.pixelSize: 11
											elide: Text.ElideRight
										}
									}
								}
							}
						}

						// current time
						Rectangle {
							visible: root.sameDay(root.selected, root.today)
							x: 42
							y: 8 + (root.today.getHours() * 60 + root.today.getMinutes()) / 60 * root.hourHeight
							width: timeline.width - 42
							height: 2
							radius: 1
							color: colors.error
							z: 10
						}
					}
				}
			}
		}
	}
}

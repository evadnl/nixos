import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property string shutdown: "qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown."
    readonly property string firmware: "busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager SetRebootToFirmwareSetup b true"

    function run(cmd) {
        root.expanded = false;
        executable.connectSource(cmd);
    }

    preferredRepresentation: compactRepresentation
    toolTipMainText: "Power"

    P5Support.DataSource {
        id: executable
        engine: "executable"
        onNewData: (source, data) => disconnectSource(source)
    }

    compactRepresentation: Kirigami.Icon {
        source: "system-shutdown"
        active: mouseArea.containsMouse

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: ColumnLayout {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        spacing: 0

        PlasmaComponents.ItemDelegate {
            Layout.fillWidth: true
            icon.name: "system-reboot"
            text: "Restart"
            onClicked: root.run(root.shutdown + "logoutAndReboot")
        }

        PlasmaComponents.ItemDelegate {
            Layout.fillWidth: true
            icon.name: "system-shutdown"
            text: "Shut Down"
            onClicked: root.run(root.shutdown + "logoutAndShutdown")
        }

        PlasmaComponents.ItemDelegate {
            Layout.fillWidth: true
            icon.name: "cpu"
            text: "Restart to UEFI Setup"
            onClicked: root.run(root.firmware + " && " + root.shutdown + "logoutAndReboot")
        }
    }
}

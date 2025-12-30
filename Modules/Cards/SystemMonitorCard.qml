import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Services.System
import qs.Services.UI
import qs.Widgets

NBox {
  id: root
  width: Math.round(100 * Style.uiScaleRatio)
  height: Math.round(100 * Style.uiScaleRatio)

  property real scaleFactor: 1.0

  Behavior on scaleFactor {
    NumberAnimation {
      duration: 400
      easing.type: Easing.InOutQuad
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: root.scaleFactor = 2.8
    onExited: root.scaleFactor = 1.0
  }

  // Get diskPath from bar's SystemMonitor widget if available, otherwise use settings
  readonly property string diskPath: {
    const sysMonWidget = BarService.lookupWidget("SystemMonitor");
    if (sysMonWidget && sysMonWidget.diskPath) {
      return sysMonWidget.diskPath;
    }
    return Settings.data.systemMonitor.diskPath || "/";
  }

  readonly property real contentScale: 0.95 * Style.uiScaleRatio

  Item {
    id: stage
    anchors.fill: parent
    anchors.margins: Style.marginXS

    function speedFromValue(v, minSec, maxSec) {
      const val = Math.max(0, Math.min(1, v));
      return maxSec - val * (maxSec - minSec);
    }

    Repeater {
      model: [
        {
          r: Math.round(25 * Style.uiScaleRatio),
          color: Color.mPrimary
        },
        {
          r: Math.round(33 * Style.uiScaleRatio),
          color: Color.mTertiary
        },
        {
          r: Math.round(42 * Style.uiScaleRatio),
          color: Color.mSecondary
        },
        {
          r: Math.round(51 * Style.uiScaleRatio),
          color: Color.mOnSurfaceVariant
        }
      ]
      Rectangle {
        width: modelData.r * 2 * root.scaleFactor
        height: modelData.r * 2 * root.scaleFactor
        radius: width / 2
        anchors.centerIn: parent
        color: "transparent"
        border.color: Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.4)
        border.width: 1
      }
    }

    Component {
      id: planetDelegate
      Item {
        id: planet
        property real orbitRadius: 25
        property color orbitColor: "steelblue"
        property string iconName: ""
        property string valueText: "N/A"
        property real speedSec: 15
        property real angle: Math.random() * 360
        width: Math.round(8 * Style.uiScaleRatio) * root.scaleFactor
        height: Math.round(8 * Style.uiScaleRatio) * root.scaleFactor

        Rectangle {
          id: body
          width: Math.round(8 * Style.uiScaleRatio) * root.scaleFactor
          height: Math.round(8 * Style.uiScaleRatio) * root.scaleFactor
          radius: width / 2
          color: orbitColor
          border.color: Qt.rgba(0, 0, 0, 0.15)
          border.width: 1
          x: (stage.width / 2) + Math.cos(planet.angle * Math.PI / 180) * (planet.orbitRadius * root.scaleFactor) - width / 2
          y: (stage.height / 2) + Math.sin(planet.angle * Math.PI / 180) * (planet.orbitRadius * root.scaleFactor) - height / 2

          NIcon {
            anchors.centerIn: parent
            icon: planet.iconName
            color: Color.mOnPrimary
            pointSize: Style.fontSizeTiny * root.scaleFactor
            visible: root.scaleFactor > 1.5
          }

          NText {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            text: planet.valueText
            color: Color.mOnSurfaceVariant
            pointSize: Style.fontSizeTiny * root.scaleFactor
            visible: root.scaleFactor > 1.5
          }
        }

        Timer {
          interval: 40
          repeat: true
          running: true
          onTriggered: {
            const delta = 360 * (interval / (planet.speedSec * 1000));
            planet.angle = (planet.angle + delta) % 360;
          }
        }
      }
    }

    Loader {
      id: cpu
      sourceComponent: planetDelegate
      onLoaded: {
        item.orbitRadius = Math.round(25 * Style.uiScaleRatio);
        item.orbitColor = Color.mPrimary;
        item.iconName = "cpu-usage";
        const v = (SystemStatService?.cpuUsage ?? 0) / 100;
        item.valueText = SystemStatService ? `${Math.round(SystemStatService.cpuUsage)}%` : "N/A";
        item.speedSec = stage.speedFromValue(v, 4, 30);
      }
      Connections {
        target: SystemStatService
        function onCpuUsageChanged() {
          if (!cpu.item)
            return;
          const v = (SystemStatService.cpuUsage ?? 0) / 100;
          cpu.item.valueText = `${Math.round(SystemStatService.cpuUsage)}%`;
          cpu.item.speedSec = stage.speedFromValue(v, 4, 30);
        }
      }
    }

    Loader {
      id: temp
      sourceComponent: planetDelegate
      onLoaded: {
        item.orbitRadius = Math.round(33 * Style.uiScaleRatio);
        item.orbitColor = Color.mTertiary;
        item.iconName = "cpu-temperature";
        const v = (SystemStatService?.cpuTemp ?? 0) / 100;
        item.valueText = SystemStatService ? `${Math.round(SystemStatService.cpuTemp)}°C` : "N/A";
        item.speedSec = stage.speedFromValue(v, 4, 30);
      }
      Connections {
        target: SystemStatService
        function onCpuTempChanged() {
          if (!temp.item)
            return;
          const v = (SystemStatService.cpuTemp ?? 0) / 100;
          temp.item.valueText = `${Math.round(SystemStatService.cpuTemp)}°C`;
          temp.item.speedSec = stage.speedFromValue(v, 4, 30);
        }
      }
    }

    Loader {
      id: mem
      sourceComponent: planetDelegate
      onLoaded: {
        item.orbitRadius = Math.round(42 * Style.uiScaleRatio);
        item.orbitColor = Color.mSecondary;
        item.iconName = "memory";
        const v = (SystemStatService?.memPercent ?? 0) / 100;
        item.valueText = SystemStatService ? `${Math.round(SystemStatService.memPercent)}%` : "NA";
        item.speedSec = stage.speedFromValue(v, 4, 30);
      }
      Connections {
        target: SystemStatService
        function onMemPercentChanged() {
          if (!mem.item)
            return;
          const v = (SystemStatService.memPercent ?? 0) / 100;
          mem.item.valueText = `${Math.round(SystemStatService.memPercent)}%`;
          mem.item.speedSec = stage.speedFromValue(v, 4, 30);
        }
      }
    }

    Loader {
      id: disk
      sourceComponent: planetDelegate
      onLoaded: {
        item.orbitRadius = Math.round(51 * Style.uiScaleRatio);
        item.orbitColor = Color.mOnSurfaceVariant;
        item.iconName = "storage";
        const d = (SystemStatService?.diskPercents?.[root.diskPath] ?? 0) / 100;
        item.valueText = SystemStatService?.diskPercents?.[root.diskPath] ? `${Math.round(SystemStatService.diskPercents[root.diskPath])}%` : "N/A";
        item.speedSec = stage.speedFromValue(d, 4, 30);
      }
      Connections {
        target: SystemStatService
        function onDiskPercentsChanged() {
          if (!disk.item)
            return;
          const d = (SystemStatService.diskPercents?.[root.diskPath] ?? 0) / 100;
          disk.item.valueText = `${Math.round(SystemStatService.diskPercents?.[root.diskPath] ?? 0)}%`;
          disk.item.speedSec = stage.speedFromValue(d, 4, 30);
        }
      }
    }
  }
}

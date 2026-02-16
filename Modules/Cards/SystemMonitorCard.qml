import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import qs.Commons
import qs.Services.System
import qs.Services.UI
import qs.Widgets

NBox {
  id: root
  width: Math.round(100 * Style.uiScaleRatio)
  height: Math.round(100 * Style.uiScaleRatio)

  // Simplified scale factor for visual enhancement only
  property real scaleFactor: 1.0

  Behavior on scaleFactor {
    NumberAnimation {
      duration: 200
      easing.type: Easing.InOutQuad
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: root.scaleFactor = 1.03  // Subtle hover effect
    onExited: root.scaleFactor = 1.0
  }

  Component.onCompleted: SystemStatService.registerComponent("card-sysmonitor")
  Component.onDestruction: SystemStatService.unregisterComponent("card-sysmonitor")

  readonly property string diskPath: Settings.data.controlCenter.diskPath || "/"

  // Data values normalized to 0-1 range - moved to root level to be accessible in Shape
  readonly property var values: [
    (SystemStatService?.cpuUsage !== undefined ? SystemStatService.cpuUsage / 100 : 0.5),
    (SystemStatService?.cpuTemp !== undefined ? SystemStatService.cpuTemp / 100 : 0.3),
    (SystemStatService?.memPercent !== undefined ? SystemStatService.memPercent / 100 : 0.7),
    (SystemStatService?.diskPercents?.[root.diskPath] !== undefined ? SystemStatService.diskPercents[root.diskPath] / 100 : 0.2),
    (function() {
      if (SystemStatService?.networkActivity !== undefined) return SystemStatService.networkActivity / 100;
      if (SystemStatService?.networkUsage !== undefined) return SystemStatService.networkUsage / 100;
      return 0.4;
    })(),
    (function() {
      if (SystemStatService?.gpuUsage !== undefined) return SystemStatService.gpuUsage / 100;
      if (SystemStatService?.swapUsage !== undefined) return SystemStatService.swapUsage / 100;
      return 0.6;
    })()
  ]

  Item {
    id: stage
    anchors.fill: parent
    anchors.margins: Style.marginXS

    // Central position
    readonly property real centerX: width / 2
    readonly property real centerY: height / 2

    // Fixed maximum radius (50% of shortest dimension, nearly filling the box)
    readonly property real maxRadius: Math.min(width, height) * 0.50

    // Function to calculate point on radar chart - along radial axes
    function point(index, factor) {
      // Calculate angles for the 6 radial axes (every 60 degrees: 0°, 60°, 120°, 180°, 240°, 300°)
      const angle = (Math.PI / 3) * index; // 60 degree increments: 0, π/3, 2π/3, π, 4π/3, 5π/3
      return Qt.point(
        centerX + Math.cos(angle) * maxRadius * factor,
        centerY + Math.sin(angle) * maxRadius * factor
      );
    }

    // Main shape containing all visual elements
    Shape {
      anchors.fill: parent
      antialiasing: true

      // Background concentric hexagons (fixed, not affected by data)
      ShapePath {
        strokeWidth: 1
        strokeColor: Qt.alpha(Color.mOnSurfaceVariant, 0.2)
        fillColor: "transparent"

        PathMove {
          x: stage.centerX + Math.cos(0) * stage.maxRadius * 0.3
          y: stage.centerY + Math.sin(0) * stage.maxRadius * 0.3
        }
        PathLine {
          x: stage.centerX + Math.cos(Math.PI/3) * stage.maxRadius * 0.3
          y: stage.centerY + Math.sin(Math.PI/3) * stage.maxRadius * 0.3
        }
        PathLine {
          x: stage.centerX + Math.cos(2*Math.PI/3) * stage.maxRadius * 0.3
          y: stage.centerY + Math.sin(2*Math.PI/3) * stage.maxRadius * 0.3
        }
        PathLine {
          x: stage.centerX + Math.cos(Math.PI) * stage.maxRadius * 0.3
          y: stage.centerY + Math.sin(Math.PI) * stage.maxRadius * 0.3
        }
        PathLine {
          x: stage.centerX + Math.cos(4*Math.PI/3) * stage.maxRadius * 0.3
          y: stage.centerY + Math.sin(4*Math.PI/3) * stage.maxRadius * 0.3
        }
        PathLine {
          x: stage.centerX + Math.cos(5*Math.PI/3) * stage.maxRadius * 0.3
          y: stage.centerY + Math.sin(5*Math.PI/3) * stage.maxRadius * 0.3
        }
        PathLine {
          x: stage.centerX + Math.cos(0) * stage.maxRadius * 0.3
          y: stage.centerY + Math.sin(0) * stage.maxRadius * 0.3
        }
      }
      ShapePath {
        strokeWidth: 1
        strokeColor: Qt.alpha(Color.mOnSurfaceVariant, 0.3)
        fillColor: "transparent"

        PathMove {
          x: stage.centerX + Math.cos(0) * stage.maxRadius * 0.6
          y: stage.centerY + Math.sin(0) * stage.maxRadius * 0.6
        }
        PathLine {
          x: stage.centerX + Math.cos(Math.PI/3) * stage.maxRadius * 0.6
          y: stage.centerY + Math.sin(Math.PI/3) * stage.maxRadius * 0.6
        }
        PathLine {
          x: stage.centerX + Math.cos(2*Math.PI/3) * stage.maxRadius * 0.6
          y: stage.centerY + Math.sin(2*Math.PI/3) * stage.maxRadius * 0.6
        }
        PathLine {
          x: stage.centerX + Math.cos(Math.PI) * stage.maxRadius * 0.6
          y: stage.centerY + Math.sin(Math.PI) * stage.maxRadius * 0.6
        }
        PathLine {
          x: stage.centerX + Math.cos(4*Math.PI/3) * stage.maxRadius * 0.6
          y: stage.centerY + Math.sin(4*Math.PI/3) * stage.maxRadius * 0.6
        }
        PathLine {
          x: stage.centerX + Math.cos(5*Math.PI/3) * stage.maxRadius * 0.6
          y: stage.centerY + Math.sin(5*Math.PI/3) * stage.maxRadius * 0.6
        }
        PathLine {
          x: stage.centerX + Math.cos(0) * stage.maxRadius * 0.6
          y: stage.centerY + Math.sin(0) * stage.maxRadius * 0.6
        }
      }
      ShapePath {
        strokeWidth: 1.5
        strokeColor: Qt.alpha(Color.mOnSurfaceVariant, 0.4)
        fillColor: "transparent"

        PathMove {
          x: stage.centerX + Math.cos(0) * stage.maxRadius
          y: stage.centerY + Math.sin(0) * stage.maxRadius
        }
        PathLine {
          x: stage.centerX + Math.cos(Math.PI/3) * stage.maxRadius
          y: stage.centerY + Math.sin(Math.PI/3) * stage.maxRadius
        }
        PathLine {
          x: stage.centerX + Math.cos(2*Math.PI/3) * stage.maxRadius
          y: stage.centerY + Math.sin(2*Math.PI/3) * stage.maxRadius
        }
        PathLine {
          x: stage.centerX + Math.cos(Math.PI) * stage.maxRadius
          y: stage.centerY + Math.sin(Math.PI) * stage.maxRadius
        }
        PathLine {
          x: stage.centerX + Math.cos(4*Math.PI/3) * stage.maxRadius
          y: stage.centerY + Math.sin(4*Math.PI/3) * stage.maxRadius
        }
        PathLine {
          x: stage.centerX + Math.cos(5*Math.PI/3) * stage.maxRadius
          y: stage.centerY + Math.sin(5*Math.PI/3) * stage.maxRadius
        }
        PathLine {
          x: stage.centerX + Math.cos(0) * stage.maxRadius
          y: stage.centerY + Math.sin(0) * stage.maxRadius
        }
      }

      // Radial axis lines (from center to max radius) - 6 lines to each vertex
      ShapePath {
        strokeWidth: 1
        strokeColor: Qt.alpha(Color.mOnSurfaceVariant, 0.25)
        fillColor: "transparent"

        PathMove { x: stage.centerX; y: stage.centerY }
        PathLine {
          x: stage.centerX + Math.cos(0) * stage.maxRadius
          y: stage.centerY + Math.sin(0) * stage.maxRadius
        }
      }
      ShapePath {
        strokeWidth: 1
        strokeColor: Qt.alpha(Color.mOnSurfaceVariant, 0.25)
        fillColor: "transparent"

        PathMove { x: stage.centerX; y: stage.centerY }
        PathLine {
          x: stage.centerX + Math.cos(Math.PI/3) * stage.maxRadius
          y: stage.centerY + Math.sin(Math.PI/3) * stage.maxRadius
        }
      }
      ShapePath {
        strokeWidth: 1
        strokeColor: Qt.alpha(Color.mOnSurfaceVariant, 0.25)
        fillColor: "transparent"

        PathMove { x: stage.centerX; y: stage.centerY }
        PathLine {
          x: stage.centerX + Math.cos(2*Math.PI/3) * stage.maxRadius
          y: stage.centerY + Math.sin(2*Math.PI/3) * stage.maxRadius
        }
      }
      ShapePath {
        strokeWidth: 1
        strokeColor: Qt.alpha(Color.mOnSurfaceVariant, 0.25)
        fillColor: "transparent"

        PathMove { x: stage.centerX; y: stage.centerY }
        PathLine {
          x: stage.centerX + Math.cos(Math.PI) * stage.maxRadius
          y: stage.centerY + Math.sin(Math.PI) * stage.maxRadius
        }
      }
      ShapePath {
        strokeWidth: 1
        strokeColor: Qt.alpha(Color.mOnSurfaceVariant, 0.25)
        fillColor: "transparent"

        PathMove { x: stage.centerX; y: stage.centerY }
        PathLine {
          x: stage.centerX + Math.cos(4*Math.PI/3) * stage.maxRadius
          y: stage.centerY + Math.sin(4*Math.PI/3) * stage.maxRadius
        }
      }
      ShapePath {
        strokeWidth: 1
        strokeColor: Qt.alpha(Color.mOnSurfaceVariant, 0.25)
        fillColor: "transparent"

        PathMove { x: stage.centerX; y: stage.centerY }
        PathLine {
          x: stage.centerX + Math.cos(5*Math.PI/3) * stage.maxRadius
          y: stage.centerY + Math.sin(5*Math.PI/3) * stage.maxRadius
        }
      }

      // Main data polygon (the radar chart itself)
      ShapePath {
        id: dataPolygon
        strokeWidth: 2
        strokeColor: Qt.alpha(Color.mPrimary, 0.8)
        fillColor: Qt.alpha(Color.mPrimary, 0.2)

        // Calculate all points once and draw the polygon
        PathMove {
          x: stage.point(0, root.values[0]).x
          y: stage.point(0, root.values[0]).y
        }
        PathLine {
          x: stage.point(1, root.values[1]).x
          y: stage.point(1, root.values[1]).y
        }
        PathLine {
          x: stage.point(2, root.values[2]).x
          y: stage.point(2, root.values[2]).y
        }
        PathLine {
          x: stage.point(3, root.values[3]).x
          y: stage.point(3, root.values[3]).y
        }
        PathLine {
          x: stage.point(4, root.values[4]).x
          y: stage.point(4, root.values[4]).y
        }
        PathLine {
          x: stage.point(5, root.values[5]).x
          y: stage.point(5, root.values[5]).y
        }
        PathLine {  // Close the polygon back to the first point
          x: stage.point(0, root.values[0]).x
          y: stage.point(0, root.values[0]).y
        }
      }
    }

    // Optional: Small dots at data points
    Repeater {
      model: 6
      Rectangle {
        x: stage.point(model.index, root.values[model.index]).x - 2
        y: stage.point(model.index, root.values[model.index]).y - 2
        width: 4
        height: 4
        radius: 2
        color: {
          switch(model.index) {
            case 0: return Qt.alpha(Color.mPrimary, 0.9);
            case 1: return Qt.alpha(Color.mTertiary, 0.9);
            case 2: return Qt.alpha(Color.mSecondary, 0.9);
            case 3: return Qt.alpha(Color.mOnSurfaceVariant, 0.9);
            case 4: return Qt.alpha(Color.mError, 0.9);
            case 5: return Qt.alpha(Color.mSuccess, 0.9);
            default: return Qt.rgba(0.5, 0.5, 0.5, 0.9);
          }
        }
        visible: root.scaleFactor > 1.01  // Only show on hover
      }
    }

    // Connections to update when system stats change
    Connections {
      target: SystemStatService
      function onCpuUsageChanged() { }
      function onCpuTempChanged() { }
      function onMemPercentChanged() { }
      function onDiskPercentsChanged() { }
      // Additional connections will be triggered automatically due to property bindings
    }
  }
}

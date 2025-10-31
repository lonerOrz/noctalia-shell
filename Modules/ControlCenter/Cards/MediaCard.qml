import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.Modules.Audio
import qs.Commons
import qs.Services
import qs.Widgets

NBox {
  id: root
  implicitWidth: 0
  implicitHeight: 0

  // Wrapper - rounded rect clipper for background
  Item {
    anchors.fill: parent
    layer.enabled: true
    layer.effect: MultiEffect {
      maskEnabled: true
      maskThresholdMin: 0.5
      maskSpreadAtMin: 0.0
      maskSource: ShaderEffectSource {
        sourceItem: Rectangle {
          width: root.width
          height: root.height
          radius: Style.radiusM
          color: "white"
        }
      }
    }

    // Background image that covers everything
    Image {
      readonly property int dim: Math.round(256 * Style.uiScaleRatio)
      id: bgImage
      anchors.fill: parent
      source: MediaService.trackArtUrl || WallpaperService.getWallpaper(Screen.name)
      sourceSize: Qt.size(dim, dim)
      fillMode: Image.PreserveAspectCrop

      layer.enabled: true
      layer.effect: MultiEffect {
        blurEnabled: true
        blur: 0.25
        blurMax: 16
      }
    }

    // Dark overlay for readability
    Rectangle {
      anchors.fill: parent
      color: Color.mSurfaceVariant
      opacity: 0.85
      radius: Style.radiusM
    }

    // Border
    Rectangle {
      anchors.fill: parent
      color: Color.transparent
      border.color: Color.mOutline
      border.width: 1
      radius: Style.radiusM
    }

    // Background visualizer on top of the artwork (Keep this as per previous structure)
    Loader {
      anchors.fill: parent
      active: Settings.data.audio.visualizerType !== "" && Settings.data.audio.visualizerType !== "none"

      sourceComponent: {
        switch (Settings.data.audio.visualizerType) {
        case "linear":
          return linearComponent
        case "mirrored":
          return mirroredComponent
        case "wave":
          return waveComponent
        default:
          return null
        }
      }

      Component {
        id: linearComponent
        LinearSpectrum {
          anchors.fill: parent
          values: CavaService.values
          fillColor: Color.mPrimary
          opacity: 0.5
        }
      }

      Component {
        id: mirroredComponent
        MirroredSpectrum {
          anchors.fill: parent
          values: CavaService.values
          fillColor: Color.mPrimary
          opacity: 0.5
        }
      }

      Component {
        id: waveComponent
        WaveSpectrum {
          anchors.fill: parent
          values: CavaService.values
          fillColor: Color.mPrimary
          opacity: 0.5
        }
      }
    }
  }

  // Centered disc icon for fallback view when no media is playing
  NIcon {
    anchors.centerIn: parent
    icon: "disc"
    pointSize: Style.fontSizeXXXL * 2
    color: Color.mOnSurfaceVariant
    visible: !MediaService.currentPlayer || !MediaService.canPlay

    RotationAnimator on rotation {
      from: 0
      to: 360
      duration: 8000
      loops: Animation.Infinite
      running: parent.visible
    }
  }

  // Title text in the top-left corner when media is playing
  NText {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.margins: Style.marginM
    width: parent.width - (anchors.margins * 2)

    visible: MediaService.currentPlayer && MediaService.trackTitle !== ""

    text: MediaService.trackTitle
    pointSize: Style.fontSizeXS // Small font size as requested
    font.weight: Style.fontWeightBold
    elide: Text.ElideRight
    wrapMode: Text.NoWrap
    color: Color.mOnSurface
  }

  // Player selector (top-right) - now using NIcon + MouseArea
  Item {
    id: playerSelectorContainer
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: Style.marginS
    width: Style.fontSizeL + Style.marginS // Size the container based on icon size
    height: Style.fontSizeL + Style.marginS
    visible: MediaService.getAvailablePlayers().length > 1

    NIcon {
      anchors.centerIn: parent
      icon: "dots"
      pointSize: Style.fontSizeL // Use a reasonable size for the icon
      color: Color.mOnSurfaceVariant
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor

      onClicked: {
        var menuItems = []
        var players = MediaService.getAvailablePlayers()
        for (var i = 0; i < players.length; i++) {
          menuItems.push({
                           "label": players[i].identity,
                           "action": i.toString(),
                           "icon": "disc",
                           "enabled": true,
                           "visible": true
                         })
        }
        playerContextMenu.model = menuItems
        // Open the menu below the button (container)
        playerContextMenu.openAtItem(playerSelectorContainer, 0, playerSelectorContainer.height)
      }
    }
  }

  NContextMenu {
    id: playerContextMenu
    parent: root
    width: 200

    onTriggered: function (action) {
      var index = parseInt(action)
      if (!isNaN(index)) {
        MediaService.switchToPlayer(index)
      }
    }
  }
}

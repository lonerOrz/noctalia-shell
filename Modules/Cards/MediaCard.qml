import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Media
import qs.Services.UI
import qs.Widgets
import qs.Widgets.AudioSpectrum

NBox {
  id: root

  // Track whether we have an active media player
  readonly property bool hasActivePlayer: MediaService.currentPlayer && MediaService.canPlay

  // CavaService registration for visualizer
  readonly property bool needsCava: Settings.data.audio.visualizerType !== "" && Settings.data.audio.visualizerType !== "none"

  onNeedsCavaChanged: {
    if (root.needsCava) {
      CavaService.registerComponent("mediacard");
    } else {
      CavaService.unregisterComponent("mediacard");
    }
  }

  Component.onCompleted: {
    if (root.needsCava) {
      CavaService.registerComponent("mediacard");
    }
    updateCachedWallpaper();
  }

  Component.onDestruction: {
    CavaService.unregisterComponent("mediacard");
  }

  property string wallpaper: WallpaperService.getWallpaper(screen.name)
  property string cachedWallpaper: ""

  // External state management
  Connections {
    target: WallpaperService
    function onWallpaperChanged(screenName, path) {
      if (screenName === screen.name) {
        wallpaper = path;
        updateCachedWallpaper();
      }
    }
  }

  function updateCachedWallpaper() {
    // Handle solid color mode - no wallpaper to cache
    if (Settings.data.wallpaper.useSolidColor || WallpaperService.isSolidColorPath(wallpaper)) {
      cachedWallpaper = "";
      return;
    }

    if (!wallpaper) {
      cachedWallpaper = "";
      return;
    }

    if (!ImageCacheService.initialized) {
      cachedWallpaper = wallpaper;
      return;
    }

    ImageCacheService.getThumbnail(wallpaper, function (cachedPath, success) {
      if (!root)
        return;
      cachedWallpaper = success ? cachedPath : wallpaper;
    });
  }

  // Wrapper - rounded rect clipper
  Item {
    anchors.fill: parent
    layer.enabled: true
    layer.smooth: true
    layer.effect: MultiEffect {
      maskEnabled: true
      maskThresholdMin: 0.95
      maskSpreadAtMin: 0.15
      maskSource: ShaderEffectSource {
        sourceItem: Rectangle {
          width: root.width
          height: root.height
          radius: Style.radiusM
          color: "white"
        }
      }
    }

    // Solid color background (always present as base layer)
    Rectangle {
      anchors.fill: parent
      color: Settings.data.wallpaper.useSolidColor ? Settings.data.wallpaper.solidColor : Color.mSurface
    }

    // Background image that covers everything
    Image {
      id: bgImage
      readonly property int dim: Math.round(256 * Style.uiScaleRatio)
      anchors.fill: parent
      visible: source.toString() !== ""
      source: MediaService.trackArtUrl || (Settings.data.wallpaper.enabled && !Settings.data.wallpaper.useSolidColor ? root.cachedWallpaper : "")
      sourceSize: Qt.size(dim, dim)
      fillMode: Image.PreserveAspectCrop
      layer.enabled: true
      layer.smooth: true
      layer.effect: MultiEffect {
        blurEnabled: true
        blurMax: 8
        blur: 0.33
      }
    }

    // Dark overlay for readability
    Rectangle {
      anchors.fill: parent
      color: Color.mSurface
      opacity: 0.65
      radius: Style.radiusM
    }

    // Border
    Rectangle {
      anchors.fill: parent
      color: "transparent"
      border.color: Style.boxBorderColor
      border.width: Style.borderS
      radius: Style.radiusM
    }

    // Background visualizer on top of the artwork
    Loader {
      anchors.fill: parent
      active: Settings.data.audio.visualizerType !== "" && Settings.data.audio.visualizerType !== "none"

      sourceComponent: {
        switch (Settings.data.audio.visualizerType) {
        case "linear":
          return linearComponent;
        case "mirrored":
          return mirroredComponent;
        case "wave":
          return waveComponent;
        default:
          return null;
        }
      }

      Component {
        id: linearComponent
        NLinearSpectrum {
          anchors.fill: parent
          values: CavaService.values
          fillColor: Color.mPrimary
          opacity: 0.8
        }
      }

      Component {
        id: mirroredComponent
        NMirroredSpectrum {
          anchors.fill: parent
          values: CavaService.values
          fillColor: Color.mPrimary
          opacity: 0.8
        }
      }

      Component {
        id: waveComponent
        NWaveSpectrum {
          anchors.fill: parent
          values: CavaService.values
          fillColor: Color.mPrimary
          opacity: 0.8
        }
      }
    }
  }

  // Player selector
  Rectangle {
    id: playerSelectorButton
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.topMargin: Style.marginXS / 2
    anchors.leftMargin: Style.marginM
    anchors.rightMargin: Style.marginM
    height: Style.barHeight * 0.6
    visible: MediaService.getAvailablePlayers().length > 1
    radius: Style.radiusM
    color: "transparent"

    property var currentPlayer: MediaService.getAvailablePlayers()[MediaService.selectedPlayerIndex]

    RowLayout {
      anchors.fill: parent
      spacing: Style.marginS

      NIcon {
        icon: "access-point"
        pointSize: Style.fontSizeXS
        color: Color.mOnSurfaceVariant
      }

      NText {
        text: playerSelectorButton.currentPlayer ? playerSelectorButton.currentPlayer.identity : ""
        pointSize: Style.fontSizeXXS / 1.5
        color: Color.mOnSurfaceVariant
        Layout.fillWidth: true
      }
    }

    MouseArea {
      id: playerSelectorMouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor

      onClicked: {
        var menuItems = [];
        var players = MediaService.getAvailablePlayers();
        for (var i = 0; i < players.length; i++) {
          menuItems.push({
                           "label": players[i].identity,
                           "action": i.toString(),
                           "icon": "disc",
                           "enabled": true,
                           "visible": true
                         });
        }
        playerContextMenu.model = menuItems;
        playerContextMenu.openAtItem(playerSelectorButton, 0, playerSelectorButton.height + Style.marginXS);
      }
    }

    NContextMenu {
      id: playerContextMenu
      parent: root
      width: 120
      itemHeight: 26
      itemPadding: Style.marginXS
      padding: Style.marginXS
      verticalPolicy: ScrollBar.AlwaysOff

      onTriggered: function (action) {
        var index = parseInt(action);
        if (!isNaN(index)) {
          MediaService.switchToPlayer(index);
        }
      }
    }
  }

  // Content container that adjusts for player selector
  ColumnLayout {
    anchors.fill: parent
    anchors.topMargin: playerSelectorButton.visible ? (playerSelectorButton.height + Style.marginXS) : 0
    anchors.leftMargin: Style.marginS
    anchors.rightMargin: Style.marginS
    anchors.bottomMargin: Style.marginS
    spacing: Style.marginXS

    // No media player detected - centered disc icon
    NIcon {
      Layout.alignment: Qt.AlignCenter
      visible: false
      icon: "disc"
      pointSize: Style.fontSizeM * 2
      color: Color.mOnSurfaceVariant
      opacity: 1.0
    }

    // MediaPlayer Main Content - use Loader for performance
    Loader {
      id: mainLoader
      Layout.fillWidth: true
      Layout.fillHeight: true
      active: root.hasActivePlayer

      sourceComponent: Item {
        id: mainContent
        anchors.fill: parent

        NDropShadow {
          anchors.fill: mainContent
          source: mainContent
          autoPaddingEnabled: true
          shadowBlur: 0.5
          shadowOpacity: 0.9
          shadowHorizontalOffset: 0
          shadowVerticalOffset: 0
        }

        ColumnLayout {
          anchors.fill: parent
          spacing: Style.marginXS

          // Metadata
          ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginXS / 2

            NText {
              visible: MediaService.trackTitle !== ""
              text: MediaService.trackTitle
              pointSize: Style.fontSizeS
              font.weight: Style.fontWeightBold
              elide: Text.ElideRight
              wrapMode: Text.Wrap
              maximumLineCount: 2
              Layout.fillWidth: true
            }

            NText {
              visible: MediaService.trackArtist !== ""
              text: MediaService.trackArtist
              color: Color.mSecondary
              pointSize: Style.fontSizeXS
              elide: Text.ElideRight
              Layout.fillWidth: true
            }

            NText {
              visible: MediaService.trackAlbum !== ""
              text: MediaService.trackAlbum
              color: Color.mOnSurfaceVariant
              pointSize: Style.fontSizeXXS
              elide: Text.ElideRight
              Layout.fillWidth: true
            }
          }

          // Progress slider
          Item {
            id: progressWrapper
            visible: (MediaService.currentPlayer && MediaService.trackLength > 0)
            Layout.fillWidth: true
            height: Style.baseWidgetSize * 0.25

            property real localSeekRatio: -1
            property real lastSentSeekRatio: -1
            property real seekEpsilon: 0.01
            property real progressRatio: {
              if (!MediaService.currentPlayer || MediaService.trackLength <= 0)
                return 0;
              const r = MediaService.currentPosition / MediaService.trackLength;
              if (isNaN(r) || !isFinite(r))
                return 0;
              return Math.max(0, Math.min(1, r));
            }
            property real effectiveRatio: (MediaService.isSeeking && localSeekRatio >= 0) ? Math.max(0, Math.min(1, localSeekRatio)) : progressRatio

            Timer {
              id: seekDebounce
              interval: 75
              repeat: false
              onTriggered: {
                if (MediaService.isSeeking && progressWrapper.localSeekRatio >= 0) {
                  const next = Math.max(0, Math.min(1, progressWrapper.localSeekRatio));
                  if (progressWrapper.lastSentSeekRatio < 0 || Math.abs(next - progressWrapper.lastSentSeekRatio) >= progressWrapper.seekEpsilon) {
                    MediaService.seekByRatio(next);
                    progressWrapper.lastSentSeekRatio = next;
                  }
                }
              }
            }

            NSlider {
              id: progressSlider
              anchors.fill: parent
              from: 0
              to: 1
              stepSize: 0
              snapAlways: false
              enabled: MediaService.trackLength > 0 && MediaService.canSeek
              heightRatio: 0.3

              onMoved: {
                progressWrapper.localSeekRatio = value;
                seekDebounce.restart();
              }
              onPressedChanged: {
                if (pressed) {
                  MediaService.isSeeking = true;
                  progressWrapper.localSeekRatio = value;
                  MediaService.seekByRatio(value);
                  progressWrapper.lastSentSeekRatio = value;
                } else {
                  seekDebounce.stop();
                  MediaService.seekByRatio(value);
                  MediaService.isSeeking = false;
                  progressWrapper.localSeekRatio = -1;
                  progressWrapper.lastSentSeekRatio = -1;
                }
              }
            }

            Binding {
              target: progressSlider
              property: "value"
              value: progressWrapper.progressRatio
              when: !MediaService.isSeeking
            }
          }

          // Media controls
          RowLayout {
            spacing: Style.marginXS
            Layout.alignment: Qt.AlignHCenter

            NIconButton {
              icon: "media-prev"
              visible: MediaService.canGoPrevious
              baseSize: Style.baseWidgetSize * 0.6
              onClicked: MediaService.canGoPrevious ? MediaService.previous() : {}
            }

            NIconButton {
              icon: MediaService.isPlaying ? "media-pause" : "media-play"
              visible: (MediaService.canPlay || MediaService.canPause)
              baseSize: Style.baseWidgetSize * 0.6
              onClicked: (MediaService.canPlay || MediaService.canPause) ? MediaService.playPause() : {}
            }

            NIconButton {
              icon: "media-next"
              visible: MediaService.canGoNext
              baseSize: Style.baseWidgetSize * 0.6
              onClicked: MediaService.canGoNext ? MediaService.next() : {}
            }
          }
        }
      }
    }
  }
}

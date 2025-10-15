import QtQuick                                                                                                 
import Quickshell                                                                                              
import qs.Commons                                                                                              
import qs.Services                                                                                             
import qs.Widgets                                                                                              
                                                                                                               
Row {                                                                                                          
    id: root                                                                                                   
    property ShellScreen screen                                                                                
    property real scaling: 1.0                                                                                 
                                                                                                               
    anchors.verticalCenter: parent.verticalCenter                                                              
    spacing: Style.marginS * scaling                                                                           
    visible: LyricsService.hasLyrics                                                                           
                                                                                                               
    Rectangle {                                                                                                
        id: capsule                                                                                            
        width: lyricsContainer.width + Style.marginM * 2 * scaling                                             
        height: Math.round(Style.capsuleHeight * scaling)                                                      
        radius: Math.round(Style.radiusM * scaling)                                                            
        color: Color.mSurfaceVariant                                                                           
        anchors.verticalCenter: parent.verticalCenter                                                          
                                                                                                               
        Item {                                                                                                 
            id: lyricsContainer                                                                                
            width: 200                                                                                         
            height: parent.height                                                                              
            anchors.centerIn: parent                                                                           
            clip: true                                                                                         
                                                                                                               
            NText {                                                                                            
                id: lyricsText                                                                                 
                text: LyricsService.lyrics                                                                     
                font.pointSize: Style.fontSizeS * scaling                                                      
                font.weight: Style.fontWeightMedium                                                            
                color: Color.mSecondary                                                                        
                anchors.verticalCenter: parent.verticalCenter                                                  
                horizontalAlignment: Text.AlignLeft                                                            
                                                                                                               
                property real posX: 0                                                                          
                property bool isPaused: true                                                                   
                                                                                                               
                Timer {                                                                                        
                    id: pauseTimer                                                                             
                    interval: 1500                                                                             
                    repeat: false                                                                              
                    running: true                                                                              
                    onTriggered: {                                                                             
                        lyricsText.isPaused = false                                                            
                    }                                                                                          
                }                                                                                              
                                                                                                               
                Timer {                                                                                        
                    id: scrollTimer                                                                            
                    interval: 16                                                                               
                    repeat: true                                                                               
                    running: true                                                                              
                    onTriggered: {                                                                             
                        var realWidth = lyricsText.contentWidth || lyricsText.implicitWidth                    
                        var scrollLength = realWidth - lyricsContainer.width                                   
                                                                                                               
                        if (scrollLength <= 0) {                                                               
                            // 短歌词，居中显示，不滚动                                                        
                            lyricsText.x = (lyricsContainer.width - realWidth) / 2                             
                            lyricsText.posX = 0                                                                
                            return                                                                             
                        }                                                                                      
                                                                                                               
                        if (lyricsText.isPaused) return                                                        
                                                                                                               
                        // 滚动逻辑                                                                            
                        lyricsText.posX += 0.5                                                                 
                        if (lyricsText.posX > scrollLength) {                                                  
                            lyricsText.posX = 0                                                                
                            lyricsText.isPaused = true                                                         
                            pauseTimer.start()  // 循环前再次停顿                                              
                        }                                                                                      
                        lyricsText.x = -lyricsText.posX                                                        
                    }                                                                                          
                }                                                                                              
                                                                                                               
                onTextChanged: {                                                                               
                    lyricsText.posX = 0                                                                        
                    lyricsText.isPaused = true                                                                 
                    pauseTimer.start()                                                                         
                                                                                                               
                    // 初始左对齐                                                                              
                    var realWidth = lyricsText.contentWidth || lyricsText.implicitWidth                        
                    if (realWidth <= lyricsContainer.width)                                                    
                        lyricsText.x = (lyricsContainer.width - realWidth) / 2                                 
                    else                                                                                       
                        lyricsText.x = 0                                                                       
                }                                                                                              
                                                                                                               
                Component.onCompleted: {                                                                       
                    lyricsText.posX = 0                                                                        
                    lyricsText.isPaused = true                                                                 
                    pauseTimer.start()                                                                         
                }                                                                                              
            }                                                                                                  
        }                                                                                                      
    }                                                                                                          
}
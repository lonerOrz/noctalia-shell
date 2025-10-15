pragma Singleton                                                                                               
                                                                                                               
import QtQuick                                                                                                 
import Quickshell                                                                                              
import Quickshell.Io                                                                                           
import qs.Commons                                                                                              
                                                                                                               
Singleton {                                                                                                    
  id: root                                                                                                     
                                                                                                               
  property string lyrics: ""                                                                                   
  readonly property bool hasLyrics: lyrics.trim() !== ""                                                       
  property bool enabled: {                                                                                     
    const widgets = Settings.data.bar.widgets;                                                                 
    if (!widgets) return false;                                                                                
    const allWidgets = (widgets.left || []).concat(widgets.center || []).concat(widgets.right || []);          
    return allWidgets.some(widget => widget.id === "Lyrics");                                                  
  }                                                                                                            
                                                                                                               
  Component.onCompleted: {                                                                                     
    Logger.log("LyricsService", "Service started");                                                            
  }                                                                                                            
                                                                                                               
  Process {                                                                                                    
    id: process                                                                                                
    running: root.enabled                                                                                      
    command: ["sh", "-c", "stdbuf -oL lrcsnc -c ~/.config/lrcsnc/config.yaml"]                                 
                                                                                                               
    onStarted: {                                                                                               
      Logger.log("LyricsService", "Process started");                                                          
      root.lyrics = ""                                                                                         
    }                                                                                                          
                                                                                                               
    onExited: (exitCode, exitStatus) => {                                                                      
      Logger.warn("LyricsService", "Process exited with code:", exitCode, "status:", exitStatus);              
      root.lyrics = ""                                                                                         
    }                                                                                                          
                                                                                                               
    stdout: SplitParser {                                                                                      
      onRead: data => {                                                                                        
        root.lyrics = data                                                                                     
      }                                                                                                        
    }                                                                                                          
                                                                                                               
    stderr: SplitParser {                                                                                      
      onRead: data => {                                                                                        
        Logger.error("LyricsService", "stderr:", data);                                                        
      }                                                                                                        
    }                                                                                                          
  }                                                                                                            
}
//
//  JotFilesInteractor.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class JotFilesInteractor: NSObject {
    
    
    static func saveDrawing(for page: Paper, in project: DeskProject){
        let temp = PathLocator.getTempFolder()
        let projectFolderPath = "/" + project.getName()
        let pageFolderPath = "/page" + String(page.getPageNumber())
        
        let inkLocation   = pageFolderPath+"/ink.png"
        let stateLocation = pageFolderPath+"/state.plist"
        let thumbLocation = pageFolderPath+"/thumb.png"
        
        func doNothing(ink: UIImage? , thumb: UIImage?, state : JotViewImmutableState?) -> Void{
            return;
        }
        
        let drawingState = page.getDrawingState()
        page.drawingView.exportImage(to: temp+projectFolderPath+inkLocation, andThumbnailTo: temp+projectFolderPath+thumbLocation, andStateTo: temp+projectFolderPath+stateLocation, andJotState: drawingState, withThumbnailScale: 1.0, onComplete: doNothing)
        //page.jotViewStateInkPath = inkLocation
       // page.jotViewStatePlistPath = stateLocation
    }
 
}

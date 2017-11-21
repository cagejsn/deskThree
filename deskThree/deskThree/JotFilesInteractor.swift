//
//  JotFilesInteractor.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class JotFilesInteractor: NSObject {
    
    // Used by saveAsView to save drawingStates
    static func archiveJotView(forPage page: Paper, in project: DeskProject){
        let projectName = project.getName()
        let pageFolder = "/"+projectName+"/page"+String(page.getPageNumber())
        page.saveDrawing(at: pageFolder)
    }
    
    static func saveDrawing(for page: Paper, in project: DeskProject){
        let temp = PathLocator.getTempFolder()
        let projectFolderPath = temp + "/" + project.getName()
        let pageFolderPath = projectFolderPath + "/page" + String(page.getPageNumber())
        
        let inkLocation   = pageFolderPath+"/ink.png"
        let stateLocation = pageFolderPath+"/state.plist"
        let thumbLocation = pageFolderPath+"/thumb.png"
        
        func doNothing(ink: UIImage? , thumb: UIImage?, state : JotViewImmutableState?) -> Void{
            return;
        }
        
        let drawingState = page
        page.drawingView.exportImage(to: inkLocation, andThumbnailTo: thumbLocation, andStateTo: stateLocation, andJotState: page.getDrawingState(), withThumbnailScale: 1.0, onComplete: doNothing)
   //     jotViewStateInkPath = inkLocation
   //     jotViewStatePlistPath = stateLocation
    }
 
}

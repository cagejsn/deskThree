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
    
    func saveDrawing(at path: String){
        let temp = PathLocator.getTempFolder()
        do {
            try FileManager.default.createDirectory(atPath: temp+path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        let inkLocation   = path+"/ink.png"
        let stateLocation = path+"/state.plist"
        let thumbLocation = path+"/thumb.png"
        
        func doNothing(ink: UIImage? , thumb: UIImage?, state : JotViewImmutableState?) -> Void{
            return;
        }
     //   drawingView.exportImage(to: temp+inkLocation, andThumbnailTo: temp+thumbLocation, andStateTo: temp+stateLocation, andJotState: drawingState, withThumbnailScale: 1.0, onComplete: doNothing)
   //     jotViewStateInkPath = inkLocation
   //     jotViewStatePlistPath = stateLocation
    }
 
}

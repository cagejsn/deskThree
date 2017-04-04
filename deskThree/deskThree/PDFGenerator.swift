//
//  PdfGenerator.swift
//  deskThree
//
//  Created by Arjun Nagineni on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit

class PDFGenerator: NSObject {
    

    
   static func createPdfFromView(workView: WorkView, saveToDocumentsWithFileName fileName: String) -> String
    {
        let imageReadySema = DispatchSemaphore(value: 0)

        var pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, workView.currentPage.bounds, nil)
        
        
        for page in workView.pages {
            let rect = page.bounds
            
            UIGraphicsBeginPDFPageWithInfo(rect, nil)
            guard var pdfContext = UIGraphicsGetCurrentContext() else { return "no"}
            page.isHidden = false

            page.drawingState.isForgetful = false
            page.drawingView.exportToImage(onComplete: {[page] (imageV: UIImage?) in
                let useful: UIImageView = UIImageView (image: imageV)
                page.addSubview(useful)
                page.setNeedsDisplay()
                imageReadySema.signal()}
                , withScale: 1.66667)
            
            // Wait till the onComplete block is done
            imageReadySema.wait()
            page.drawingState.isForgetful = true
            page.layer.render(in: pdfContext)
            page.isHidden = (page != workView.currentPage) ? true : false
        }
        
        UIGraphicsEndPDFContext()

        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            print(documentsFileName)
            pdfData.write(toFile: documentsFileName, atomically: true)
            return documentsFileName
        }
        return "no"
    }
}

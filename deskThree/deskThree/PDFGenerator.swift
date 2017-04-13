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

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, workView.currentPage.bounds, nil)
        
        
        for page in workView.pages {
            let rect = page.bounds
            UIGraphicsBeginPDFPageWithInfo(rect, nil)
            guard let pdfContext = UIGraphicsGetCurrentContext() else { return "no"}

            page.drawingView.exportToImage(onComplete: {[page] (imageV: UIImage?) in
                page.isHidden = false
                let useful: UIImageView = UIImageView (image: imageV)
                page.addSubview(useful)
                page.setNeedsDisplay()
                // Render the page contents into the PDF Context
                page.layer.render(in: pdfContext)
                page.isHidden = (page != workView.currentPage) ? true : false
                useful.removeFromSuperview()
                // Signal that the onComplete block is done executing
                imageReadySema.signal()}
                , withScale: 1.66667)
            
            // Wait till the onComplete block is done
            imageReadySema.wait()
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

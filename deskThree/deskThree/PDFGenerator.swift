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
        
        var pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, workView.currentPage.bounds, nil)
        
        
        for page in workView.pages {
            let rect = page.bounds
            
            UIGraphicsBeginPDFPageWithInfo(rect, nil)
            guard var pdfContext = UIGraphicsGetCurrentContext() else { return "no"}

            page.isHidden = false
            page.layer.render(in: pdfContext)
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

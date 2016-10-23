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
    
   static func createPdfFromView(aView: UIView, saveToDocumentsWithFileName fileName: String) -> String
    {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return "no"}
        
        aView.layer.render(in: pdfContext)
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

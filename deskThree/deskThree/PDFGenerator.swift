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
    

    
   static func createPdfFromView(workViewPresenter: WorkViewPresenter, saveToDocumentsWithFileName fileName: String) -> String
    {

        let pdfData = NSMutableData()
        
        if !workViewPresenter.exportPDF(to: pdfData) {return "no"}
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            print(documentsFileName)
            pdfData.write(toFile: documentsFileName, atomically: true)
            return documentsFileName
        }
        return "no"
    }
}

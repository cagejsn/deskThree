//
//  Mosaic.swift
//  EngineeringDesk
//
//  Created by Cage Johnson on 8/2/15.
//  Copyright (c) 2015 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit

protocol InputObjectDelegate{
    func didCompleteMove(_movedView: UIView)
    func didIncrementMove(_movedView: UIView)
    func hideTrash()
    func unhideTrash()
}

class InputObject: UIView, OutputAreaDelegate {
    
    //MARK: Variables
    var delegate: InputObjectDelegate?
    var viewController: DeskViewController?
    
    func receiveElement(_ element: Any){
        
    }
    
    
    //MARK: OutputArea Delegate
    func outputAreaCreatedBlock(){
        delegate!.unhideTrash()
    }

    func outputAreaDidPassIncrementalMove(movedView: UIView) {
        self.delegate!.didIncrementMove(_movedView: movedView)
    }
    
    func outputAreaDidPassBlock(lastBlock: Block) {
        delegate!.hideTrash()
        self.delegate!.didCompleteMove(_movedView: lastBlock)
    }
}


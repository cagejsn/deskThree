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
    func didBeginMove(movedView: UIView)
    func didCompleteMove(movedView: UIView)
    func didIncrementMove(movedView: UIView)
}

class InputObject: UIView, OutputAreaDelegate {
    
    //MARK: Variables
    var delegate: InputObjectDelegate?
    var viewController: DeskViewController?
    
    func receiveElement(_ element: Any){
    }
    
    //MARK: OutputArea Delegate
    func outputAreaCreatedBlock(newBlock: Block){
        delegate!.didBeginMove(movedView: newBlock)
    }

    func outputAreaDidPassIncrementalMove(movedView: UIView) {
        self.delegate!.didIncrementMove(movedView: movedView)
    }
    
    func outputAreaDidPassBlock(lastBlock: Block) {
        self.delegate!.didCompleteMove(movedView: lastBlock)
    }
}


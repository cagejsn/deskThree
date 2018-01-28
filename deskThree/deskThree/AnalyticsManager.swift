//
//  AnalyticsManager.swift
//  deskThree
//
//  Created by Cage Johnson on 1/25/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation
import Crashlytics
import Fabric
import FBSDKCoreKit

enum AnalyticsEvent {
    
    //HamburgerMenuViewController
    case NewProjectHVC //
    case OpenFileExplorer //
    case PrintProject //
    case ChangePenSize(Float) //
    case ChangePenColor(String) //
    case ChangeProjectBackground(String) // 
    case ImportPhoto //
    case ClearProject //
    case SendFeedback //
    
    //DVC_UIToolBar
    case UndoStroke //
    case RedoStroke //
    case RenameProjectDVC //
    case PageLeft //
    case PageRight //
    
    //WorkView
    case TogglePenEraser(String) //
    case MagicWand //

    //FEVC
    case RenameProjectFEVC //
    case MoveProject // 
    case DeleteProject // 
    case ShareProject //
    
    case NewProjectFEVC // 
    case ProjectSelected //
    
    //Paper
    case FinishedStroke(Int) //
    case MathBlockMoved // 
    case ImageBlockAdded //
    
    //MathBlock
    case MathBlockCreatedFromLasso(String) //
    case MathBlockLongPress //
    case MathBlockWRQuery(String) //
    case MathBlockEquals //
    
    //WorkView
    case ToggleCalculatorDrag //
    case ToggleCalculatorTap //
    
    //MathView
    case WolframButtonInMathView(String) //
    case UndoInMathView //
    case RedoInMathView //
    case ClearMathView //
    case EditLinkedBlock //
    case ToggleMathViewDrag //
    case ToggleMathViewTap //
    
    //Calculator
    case Equals(String) //
    case Input(String) //
    
}


class AnalyticsManager {
    
    static func track(_ event: AnalyticsEvent){
        
        var eventName = String(describing: event)
        var attachedData: [String:Any]? = nil
        
        eventName = eventName.components(separatedBy: "(").first!
        switch event {
            
            case .TogglePenEraser(let choice):
                attachedData = ["chosenWritingTool":choice]
                break
            //HamburgerMenuViewController
            case .ChangePenSize(let penSize):
                attachedData = ["penSize":penSize]
                break
            case .ChangePenColor(let penColor):
                attachedData = ["penColor":penColor]
                break
            case .ChangeProjectBackground(let pageBackground):
                attachedData = ["pageBackground":pageBackground]
                break
            
            //Paper
            case .FinishedStroke(let strokeNumber):
                attachedData = ["strokeNumber":strokeNumber]

            //MathBlock
            case .MathBlockCreatedFromLasso(let mathBlockContents):
                attachedData = ["mathBlockContents":mathBlockContents]
                break
            case .MathBlockWRQuery(let query):
                attachedData = ["WRQueryString":query]
                break
            
            //MathView
            case .WolframButtonInMathView(let query):
                attachedData = ["WRQueryString":query]
                break
            
            //Calculator
            case .Equals(let input):
                attachedData = ["calculatorInput":input]
                break
            case .Input(let input):
                attachedData = ["calcInput":input]
                break
        
            default:
                break
        }
        
        Answers.logCustomEvent(withName: eventName, customAttributes: attachedData)
        FBSDKAppEvents.logEvent(eventName, parameters: attachedData)
    }
    
    
    static func log(_ error: Error){
        
    }
    
    
    
}


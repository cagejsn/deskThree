//
//  PaperToJotManager.swift
//  deskThree
//
//  Created by Cage Johnson on 1/13/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation


class DrawingSession: NSObject {
    
    var drawingState: JotViewStateProxy!
    var drawingView: JotView!
    
    weak var delegate: JotViewStateProxyDelegate!
    weak var owningPaper: Paper!
    
    func endSession(){
        endView()
        endState()
    }
    
    func endView(){
        drawingView.deleteAssets()
        drawingView.invalidate()
        drawingView = nil
    }
    
    func endState(){
        drawingState.isForgetful = true
        drawingState.unload()
        drawingState = nil
    }
    
    func setupDrawingView(){
        
        drawingState = JotViewStateProxy.init(delegate: delegate as! NSObjectProtocol & JotViewStateProxyDelegate)
        drawingView = JotView(frame: CGRect(x: 0, y: 0, width: 1275, height: 1650))
        
        drawingView.isUserInteractionEnabled = true
//     createcage
//        drawingView
        
        // jotView's currentPage property is set which is used for hitTesting
        drawingView.currentPage = owningPaper
        // Loading drawingState onto drawingView
        drawingState.loadJotStateAsynchronously(false, with: drawingView.bounds.size, andScale: drawingView.scale, andContext: drawingView.context, andBufferManager: JotBufferManager.sharedInstance())
        drawingView.loadState(drawingState)
        drawingView.isUserInteractionEnabled = true
        drawingView.speedUpFPS()
        drawingView.transform = drawingView.transform.scaledBy(x: 0.6, y: 0.6)
    }
    
    func subviewDrawingView() {
        owningPaper.superview?.superview?.insertSubview(drawingView, at: 1)
        drawingView.delegate = owningPaper.superview as! WorkView!
    }
    
    func clearDrawing() {
        // The backing texture does not get updated when we clear the JotViewGLContext. Hence,
        // We just load up a whole new state to get a cleared backing texture. I know, it is
        // hacky. I challenge you to find a cleaner way to do it in JotViewState's background Texture itself
        drawingState.isForgetful = true
        drawingState = JotViewStateProxy()
        drawingState.loadJotStateAsynchronously(false, with: drawingView.bounds.size, andScale: drawingView.scale, andContext: drawingView.context, andBufferManager: JotBufferManager.sharedInstance())
        drawingView.loadState(drawingState)
        drawingView.clear(true)
    }
    
    func connectNewDrawingViewToPage(){
        drawingView.currentPage = owningPaper
    }
    
    func setup(){
        setupDrawingView()
        subviewDrawingView()
    }
    
    init(_ jotViewStateProxyDelegate : JotViewStateProxyDelegate ,_ paper: Paper){
        delegate = jotViewStateProxyDelegate
        owningPaper = paper
    }    
}

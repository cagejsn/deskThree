//
//  BlockExpression.swift
//  deskThree
//
//  Created by test on 3/5/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class BlockExpression: Expression{
    
    private var isDisplayingSpots: Bool = false
    private var dummyViews: [Block] = []
    private var longPressGR: UILongPressGestureRecognizer!
    // Make this private soon
    var rootBlock: Block!
    

    func getDummyViews() -> [Block]{
        return dummyViews
    }
    
    static func makeBlock(blockLocation: CGPoint, blockType: Int, blockData: String) -> Block {
        let blockWidth: CGFloat = evaluateStringWidth(textToEvaluate: blockData)
        var newBlock: Block!
        switch blockType {
        case 1:
            newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2), y:blockLocation.y - 50, width:blockWidth, height: Constants.block.height))
            newBlock?.setColor(color: Constants.block.colors.green)
            newBlock?.precedence = Precedence.Number.rawValue
        case 2:
            newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2), y:blockLocation.y - 50, width:blockWidth, height:Constants.block.height))
            newBlock?.setColor(color: Constants.block.colors.blue)
            
            switch blockData {
            case "+":
                newBlock?.precedence = Precedence.Plus.rawValue
                break
            case "-":
                newBlock?.precedence = Precedence.Minus.rawValue
                break
            case "x":
                newBlock?.precedence = Precedence.Multiply.rawValue
                break
            case "÷":
                newBlock?.precedence = Precedence.Divide.rawValue
                break
            case "√":
                newBlock?.precedence = Precedence.Multiply.rawValue
                break
            case "^":
                newBlock?.precedence = Precedence.Multiply.rawValue
                break
            default:
                break
            }
        case 3:
            newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2),y:blockLocation.y - 50, width:blockWidth, height: Constants.block.height))
            newBlock?.setColor(color: Constants.block.colors.gray)
        default:
            newBlock = Block()
            
        }
        newBlock!.text = blockData
        newBlock!.font = UIFont.boldSystemFont(ofSize: Constants.block.fontSize)
        newBlock!.textColor = UIColor.white
        newBlock!.type = blockType
        newBlock?.forBaselineLayout().clipsToBounds = true
        newBlock?.forBaselineLayout().layer.cornerRadius = Constants.block.cornerRadius
        return newBlock!
    }

    
    func handleLongPress(){
        delegate?.elementWantsSendToInputObject(element: self)
    }
    
    /// tells is one block is close to another
    func isNear(incomingFrame: CGRect) -> Bool{
        if(self.frame.insetBy(dx: -60, dy: -60).intersects(incomingFrame)){
            return true
        }
        return false
    }
    
    //this function has a long way to go
    func findAndShowAvailableSpots(_movedView: UIView){
        //first find out what kind of View it is
        if let block = _movedView as? Block {
            dummyViews = self.rootBlock.makeAListOfSpotsBelowMe(aBlockToAccomodate: block)
        }
        if let expression = _movedView as? BlockExpression {
            dummyViews = self.rootBlock.makeAListOfSpotsBelowMe(aBlockToAccomodate: ETree.getLeftestNode(root: expression.rootBlock))
            
            dummyViews.append(contentsOf: self.rootBlock.makeAListOfSpotsBelowMe(aBlockToAccomodate: ETree.getRightestNode(root: expression.rootBlock)))
        }
        
        for dummy in dummyViews {
            addSubview(dummy)
            dummy.isHidden = false
            dummy.layer.borderWidth = 1.0
        }
        isDisplayingSpots = true
    }
    
    func hideSpots(){
        self.rootBlock.removeDummyBlocks() //set revert to nil for real block
        self.dummyViews.removeAll() //clearout global dummy list
        isDisplayingSpots = false
    }
    
    func mergeExpressions(incomingExpression: BlockExpression, side: String) {
        
        var incomingRootBlock = incomingExpression.rootBlock
        
        switch (side) {
            
        case "left":
            ETree.addLeft(persistentBlock: rootBlock, lesserBlock: incomingRootBlock)
            break
        case "right":
            ETree.addRight(lastingBlock: rootBlock, lesserBlock: incomingRootBlock)
            break
        case "inner":
            break
            
        default:
            break
        }
        
        
        //if the incoming expression is of a higher precedence, then make its root the new root.
        //the ETree should have been rearranged properly in the previous functions
        if(incomingExpression.rootBlock.precedence! > rootBlock.precedence!){
            self.rootBlock = incomingExpression.rootBlock
        }
        ETree.setParentGroup(node: self.rootBlock, parentGroup: self)
        ETree.printCurrentTree(root: self.rootBlock)
        
        //Expressions aren't ready because they number blocks don't have a
        //Double Value yet
        /*
         
         if(ETree.canBeEvaluated(self.rootBlock)){
         print( ETree.evaluate(self.rootBlock))
         }
         
         */
        setExpressionString()
        
    }
    
    func setExpressionString() {
        expressionString = ""
        setExpressionStringHelper(root: self.rootBlock)
    }
    
    /* in order traversal of tree, printing each value along the way */
    private func setExpressionStringHelper (root : Block) {
        if(root.leftChild != nil){
            setExpressionStringHelper(root: root.leftChild!)
        }
        expressionString += root.getValue()
        if (root.rightChild != nil){
            setExpressionStringHelper(root: root.rightChild!)
        }
    }

    func getIsDisplayingSpots() -> Bool{
        return isDisplayingSpots
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(isDisplayingSpots)
        aCoder.encode(dummyViews)
        aCoder.encode(rootBlock)
    }

    
    init(firstVal: Block){
        rootBlock = firstVal
        let newFrame: CGRect = CGRect(origin: firstVal.frame.origin, size: firstVal.frame.size)
        super.init(frame: newFrame)
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(BlockExpression.handleLongPress))
        longPressGR.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGR)
    }
    
    required init?(coder unarchiver: NSCoder) {
        super.init(coder: unarchiver)
        self.isDisplayingSpots = unarchiver.decodeObject() as! Bool
        self.dummyViews = unarchiver.decodeObject() as! [Block]!
        self.rootBlock = unarchiver.decodeObject() as! Block!
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(BlockExpression.handleLongPress))
        longPressGR.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGR)
    }
    
}

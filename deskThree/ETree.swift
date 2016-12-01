//
//  ETree.swift
//  EngineeringDesk
//
//  Created by Alejandro Silveyra on 10/31/15.
//  Copyright © 2015 Cage Johnson. All rights reserved.
//

import Foundation

class ETree {
    
    /********************************* public methods ******************************/
    /* returns block which is to the right of input node in the equation */
    static func getSuccessor(node : Block) -> Block{
        if(node.rightChild != nil){
            return  minValue(node: node.rightChild!)
        }
        var parent : Block? = node.parent
        var n : Block = node
        while(parent != nil && n == parent!.rightChild){
            n = parent!
            parent = parent!.parent!
        }
        return parent!
    }
    
    /* returns block which is to the left of input node in the equation */
    static func getPredecessor(node : Block) -> Block {
        if(node.leftChild != nil){
            return  maxValue(node: node.leftChild!)
        }
        var parent : Block? = node.parent
        var n : Block = node
        while(parent != nil && n == parent!.leftChild){
            n = parent!;
            parent = parent!.parent!;
        }
        return parent!;
    }

    /* returns true if node is a left child, false otherwise */
    static func isLeftChild (node : Block) -> Bool {
        if (node.parent!.leftChild == node) {
            return true
        }
        else {
            return false
        }
    }
    
    /* in order traversal of tree, printing each value along the way */
    static func printCurrentTree (root : Block) {
        if(root.leftChild != nil){
            printCurrentTree(root: root.leftChild!)
        }
        print(root.getValue(), terminator: "")
        if (root.rightChild != nil){
            printCurrentTree(root: root.rightChild!)
        }
    }
    
    /* returns false if node has no children, true otherwise */
    static func doesGroupHaveMultipleMembers(node : Block) -> Bool {
        return (node.leftChild != nil || node.rightChild != nil)

    }
    
    static func getLeftestNode(root : Block) -> Block {
        var current : Block = root
        while(true){
            if (current.leftChild != nil){
                current = current.leftChild!
                continue
            }
            else {
                return current
            }
        }
    }

    static func getRightestNode(root : Block) -> Block {
        var current : Block = root
        while(true) {
            if (current.rightChild != nil){
                current = current.rightChild!
                continue
            }
            else {
                return current
            }
        }
    }
    
    static func addRight(lastingBlock : Block?, lesserBlock : Block?) {
        if(lastingBlock == nil || lesserBlock == nil){
            return
        }
        var current : Block? = lastingBlock
        let precedenceOfBlockToAdd = lesserBlock?.precedence
        if((current?.precedence)! < precedenceOfBlockToAdd!){
            addLeft(persistentBlock: lesserBlock, lesserBlock: lastingBlock)
            return
        }
        while(current!.rightChild != nil && (current!.rightChild?.precedence)! >= precedenceOfBlockToAdd!){
            current = lastingBlock!.rightChild
        }
     
        let temp : Block? = current!.rightChild
        current!.rightChild = lesserBlock
        lesserBlock!.parent = current
        addLeft(persistentBlock: lesserBlock, lesserBlock: temp)
    }
 
    
    static func addLeft(persistentBlock : Block?, lesserBlock : Block?) {
        if(persistentBlock == nil || lesserBlock == nil){
            return
        }
        var current : Block? = persistentBlock
        let precedenceOfBlockToAdd = lesserBlock?.precedence
        if((current?.precedence)! < precedenceOfBlockToAdd!){
            addRight(lastingBlock: lesserBlock, lesserBlock: persistentBlock)
            return
        }
        while(current!.leftChild != nil && (current!.leftChild?.precedence)! >= precedenceOfBlockToAdd!){
            current = persistentBlock!.leftChild
        }
        let temp : Block? = current!.leftChild
        current!.leftChild = lesserBlock
        lesserBlock!.parent = current
        addRight(lastingBlock: lesserBlock, lesserBlock: temp)
    }
    
    static func addInner(persistentBlock : Block?, lesserBlock : Block?){
        if(persistentBlock == nil || lesserBlock == nil){
            return
        }
        persistentBlock?.innerChild = lesserBlock
    }

    static func setParentGroup(node: Block, parentGroup : Expression) {
        node.parentExpression = parentGroup
        if(node.leftChild != nil){
            setParentGroup(node: node.leftChild!, parentGroup: parentGroup);
        }
        if(node.rightChild != nil){
            setParentGroup(node: node.rightChild!, parentGroup: parentGroup);
        }
    }
    
    /* could check type to make sure block is glow? */
    static func removeGlowNode(glow : Block) {
        if (glow.type == TypeOfBlock.Glow.rawValue) {
            if(glow.parent!.leftChild == glow){
                glow.parent!.leftChild = nil
            }
            if(glow.parent!.rightChild == glow){
                glow.parent!.rightChild = nil
            }
        } else {
            print("not a glow block")
        }
    }


    static func canBeEvaluated(node : Block) -> Bool {
        /*
        * in order to be solveable
        *  -any node without children must be a number
        *  -must be no nodes with only one child
        */
        if((node.leftChild != nil && node.rightChild == nil) ||
            (node.leftChild == nil && node.rightChild != nil)) {
                return false
        }
        if(node.leftChild == nil && node.rightChild == nil){
            if(node.precedence == Precedence.Number.rawValue && node.parent != nil){    //if parent is null then group is a single number which doesnt need to be evaluated
                return true
            }
            else {
                return false
            }
        }
        let leftCheck = canBeEvaluated(node: node.leftChild!)
        let rightCheck = canBeEvaluated(node: node.rightChild!)
        return leftCheck && rightCheck;
    }

    
    static func evaluate(node : Block) -> Double {
        if(node.leftChild != nil && node.rightChild != nil) {
            let leftVal = evaluate(node: node.leftChild!)
            let rightVal = evaluate(node: node.rightChild!)
            let val : Double
            //find operation
            switch(node.getValue()){
                case "+":
                    val = leftVal + rightVal
                case "-":
                    val = leftVal - rightVal
                case "x":
                    val = leftVal * rightVal
                case "÷":
                    val = leftVal / rightVal
                default:
                    val = 0.0
            }
            return val
        }
        else {
            //return value of node
            return Double(node.getValue())!
        }
    }

    static func areNeighbors(block1 : Block, block2 : Block) -> Bool {
        var b : Block = getPredecessor(node: block1)
        if(b == block2) {
            return true
        }
        b = getSuccessor(node: block1);
        if(b == block2) {
            return true
        }
        return false
    }

    /******************************** private methods *******************************/
    /* returns smalled node for a given root */
    static func minValue(node : Block) -> Block {
        var current : Block = node
        while(current.leftChild != nil){
            current = current.leftChild!
        }
        return current
    }

    /* returns largest node for a given root */
    static func maxValue (node : Block) -> Block {
        var current : Block = node
        while(current.rightChild != nil){
            current = current.rightChild!
        }
        return current
    }

}

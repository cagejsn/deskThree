//
//  AllPad.swift
//  EngineeringDesk
//
//  Created by Cage Johnson on 11/24/15.
//  Copyright © 2015 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit

class AllPad: InputObject, MathEntryAreaDelegate {
    
    //MARK: Variables
    var numEntryAreaText: String = ""

    @IBOutlet var view: UIView!
    @IBOutlet weak var numEntryArea: MathEntryArea!
    
    @IBOutlet weak var button0: OutputArea!
    @IBOutlet weak var button1: OutputArea!
    @IBOutlet weak var button2: OutputArea!
    @IBOutlet weak var button3: OutputArea!
    @IBOutlet weak var button4: OutputArea!
    @IBOutlet weak var button5: OutputArea!
    @IBOutlet weak var button6: OutputArea!
    @IBOutlet weak var button7: OutputArea!
    @IBOutlet weak var button8: OutputArea!
    @IBOutlet weak var button9: OutputArea!
    @IBOutlet weak var buttonDot: UIButton!
    @IBOutlet weak var buttonEquals: UIButton!
    @IBOutlet weak var buttonE: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!

    @IBOutlet weak var buttonPlus: OutputArea!
    @IBOutlet weak var buttonMinus: OutputArea!
    @IBOutlet weak var buttonMultiply: OutputArea!
    @IBOutlet weak var buttonDivide: OutputArea!
    @IBOutlet weak var buttonExponent: OutputArea!
    @IBOutlet weak var buttonSQRT: OutputArea!
    
    @IBOutlet weak var buttonPi: OutputArea!
    @IBOutlet weak var buttonSin: OutputArea!
    @IBOutlet weak var buttonCos: OutputArea!
    @IBOutlet weak var buttonTan: OutputArea!
    @IBOutlet weak var buttonLn: OutputArea!
    @IBOutlet weak var buttonExp: OutputArea!
    @IBOutlet weak var buttonX: OutputArea!
    @IBOutlet weak var buttonRightParen: OutputArea!
    @IBOutlet weak var buttonLeftParen: OutputArea!
    @IBOutlet weak var buttonSum: OutputArea!
    @IBOutlet weak var buttonZ: OutputArea!
    
    @IBOutlet weak var buttonArccos: OutputArea!
    @IBOutlet weak var buttonLog: OutputArea!
    @IBOutlet weak var buttonY: OutputArea!
    
    @IBOutlet weak var buttonArcsin: OutputArea!
    
    @IBOutlet weak var buttonArctan: OutputArea!
    
    override func receiveElement(_ element: Any) {
        
        if let express = element as? Expression {
            numEntryArea.setTitle(ETree.printCurrentTree(root: express.rootBlock), for: .normal)
        }
    }
    
    
    init(viewController : DeskViewController){
        super.init(frame:CGRect(x: UIScreen.main.bounds.width - Constants.dimensions.AllPad.width, y:UIScreen.main.bounds.height - Constants.dimensions.AllPad.height - 44 , width: Constants.dimensions.AllPad.width , height: Constants.dimensions.AllPad.height))
        xibSetup()
        numEntryArea.delegate = self
        numEntryArea.typeOfOutputArea = 1
        
        //storing reference to view controller in case we want to raise an error
        
    //number buttons
        button0.delegate = self
        button0.typeOfOutputArea = 1
        
        button1.delegate = self
        button1.typeOfOutputArea = 1
        
        button2.delegate = self
        button2.typeOfOutputArea = 1
        
        button3.delegate = self
        button3.typeOfOutputArea = 1
        
        button4.delegate = self
        button4.typeOfOutputArea = 1
        
        button5.delegate = self
        button5.typeOfOutputArea = 1
        
        button6.delegate = self
        button6.typeOfOutputArea = 1
        
        button7.delegate = self
        button7.typeOfOutputArea = 1
        
        button8.delegate = self
        button8.typeOfOutputArea = 1
        
        button9.delegate = self
        button9.typeOfOutputArea = 1
        
        
    //operators
        buttonPlus.delegate = self
        buttonPlus.typeOfOutputArea = 2
        
        buttonMinus.delegate = self
        buttonMinus.typeOfOutputArea = 2
        
        buttonMultiply.delegate = self
        buttonMultiply.typeOfOutputArea = 2
        
        buttonDivide.delegate = self
        buttonDivide.typeOfOutputArea = 2
        
        buttonExponent.delegate = self
        buttonExponent.typeOfOutputArea = 2
        
        buttonSQRT.delegate = self
        buttonSQRT.typeOfOutputArea = 2
        
        buttonPi.delegate = self
        buttonPi.typeOfOutputArea = 3
        
        buttonSin.delegate = self
        buttonSin.typeOfOutputArea = 3
        
        buttonCos.delegate = self
        buttonCos.typeOfOutputArea = 3
        
        buttonTan.delegate = self
        buttonTan.typeOfOutputArea = 3
        
        buttonLn.delegate  = self
        buttonLn.typeOfOutputArea = 3
        
        buttonExp.delegate = self
        buttonExp.typeOfOutputArea = 3
        
        buttonX.delegate = self
        buttonX.typeOfOutputArea = 3
        
        buttonRightParen.delegate = self
        buttonRightParen.typeOfOutputArea = 3
        
        buttonLeftParen.delegate = self
        buttonLeftParen.typeOfOutputArea = 3
        
        buttonSum.delegate = self
        buttonSum.typeOfOutputArea = 3
        
        buttonZ.delegate = self
        buttonZ.typeOfOutputArea = 3
        
        buttonArccos.delegate = self
        buttonArccos.typeOfOutputArea = 3
        
        buttonLog.delegate = self
        buttonLog.typeOfOutputArea = 3
        
        buttonY.delegate = self
        buttonY.typeOfOutputArea = 3
        
        buttonArcsin.delegate = self
        buttonArcsin.typeOfOutputArea = 3
        
        buttonArctan.delegate = self
        buttonArctan.typeOfOutputArea = 3
        
    }
    
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        numEntryArea.delegate = self
        numEntryArea.typeOfOutputArea = 1
        
        button0.delegate = self
        button0.typeOfOutputArea = 1
        
        button1.delegate = self
        button1.typeOfOutputArea = 1
        
        button2.delegate = self
        button2.typeOfOutputArea = 1
        
        button3.delegate = self
        button3.typeOfOutputArea = 1
        
        button4.delegate = self
        button4.typeOfOutputArea = 1
        
        button5.delegate = self
        button5.typeOfOutputArea = 1
        
        button6.delegate = self
        button6.typeOfOutputArea = 1
        
        button7.delegate = self
        button7.typeOfOutputArea = 1
        
        button8.delegate = self
        button8.typeOfOutputArea = 1
        
        button9.delegate = self
        button9.typeOfOutputArea = 1
        
        
        buttonPlus.delegate = self
        buttonPlus.typeOfOutputArea = 2
        
        buttonMinus.delegate = self
        buttonMinus.typeOfOutputArea = 2
        
        buttonMultiply.delegate = self
        buttonMultiply.typeOfOutputArea = 2
        
        buttonDivide.delegate = self
        buttonDivide.typeOfOutputArea = 2
        
        buttonExponent.delegate = self
        buttonExponent.typeOfOutputArea = 2
        
        buttonSQRT.delegate = self
        buttonSQRT.typeOfOutputArea = 2
        
        buttonPi.delegate = self
        buttonPi.typeOfOutputArea = 3
        
        buttonSin.delegate = self
        buttonSin.typeOfOutputArea = 3
        
        buttonCos.delegate = self
        buttonCos.typeOfOutputArea = 3
        
        buttonTan.delegate = self
        buttonTan.typeOfOutputArea = 3
        
        buttonLn.delegate  = self
        buttonLn.typeOfOutputArea = 3
        
        buttonExp.delegate = self
        buttonExp.typeOfOutputArea = 3
        
        buttonX.delegate = self
        buttonX.typeOfOutputArea = 3
        
        buttonRightParen.delegate = self
        buttonRightParen.typeOfOutputArea = 3
        
        buttonLeftParen.delegate = self
        buttonLeftParen.typeOfOutputArea = 3
        
        buttonSum.delegate = self
        buttonSum.typeOfOutputArea = 3
        
        buttonZ.delegate = self
        buttonZ.typeOfOutputArea = 3
        
        buttonArccos.delegate = self
        buttonArccos.typeOfOutputArea = 3
        
        buttonLog.delegate = self
        buttonLog.typeOfOutputArea = 3
        
        buttonY.delegate = self
        buttonY.typeOfOutputArea = 3
        
        buttonArcsin.delegate = self
        buttonArcsin.typeOfOutputArea = 3
        
        buttonArctan.delegate = self
        buttonArctan.typeOfOutputArea = 3
        
    }
    
    func reassignOutputAreasDelegate(delegate: OutputAreaDelegate){
        numEntryArea.delegate = delegate
        
        
        button0.delegate = delegate
        button1.delegate = delegate
        button2.delegate = delegate
        button3.delegate = delegate
        button4.delegate = delegate
        button5.delegate = delegate
        button6.delegate = delegate
        button7.delegate = delegate
        button8.delegate = delegate
        button9.delegate = delegate

        
        
        buttonPlus.delegate = delegate
        
        buttonMinus.delegate = delegate
        
        buttonMultiply.delegate = delegate
        
        buttonDivide.delegate = delegate
        
        buttonExponent.delegate = delegate
        
        buttonSQRT.delegate = delegate
        
        buttonPi.delegate = delegate
        
        buttonSin.delegate = delegate
        
        buttonCos.delegate = delegate
        
        buttonTan.delegate = delegate
        
        buttonLn.delegate  = delegate
        
        buttonExp.delegate = delegate
        
        buttonX.delegate = delegate
        
        buttonRightParen.delegate = delegate
        
        buttonLeftParen.delegate = delegate
        
        buttonSum.delegate = delegate
        
        buttonZ.delegate = delegate
        
        buttonArccos.delegate = delegate
        
        buttonLog.delegate = delegate
        
        buttonY.delegate = delegate
        
        buttonArcsin.delegate = delegate
        
        buttonArctan.delegate = delegate
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.backgroundColor = Constants.pad.colors.grayBlue    
        // use bounds not frame or it'll be offset
        view.frame = bounds
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        numEntryArea.titleLabel!.numberOfLines = 1
        numEntryArea.titleLabel!.adjustsFontSizeToFitWidth = true
        numEntryArea.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        view.layer.cornerRadius = 15;
        for element in view.subviews {
            element.layer.cornerRadius = 10;
        }
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName:"AllPad", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    //MARK: MathEntryAreaDelegate
    func didProduceBlockFromMath(){
        numEntryAreaText = ""
    }
    
    //MARK: Events
    
    @IBAction func deleteTextFromEntryArea(_ sender: AnyObject) {
        if (numEntryAreaText.characters.count > 0) {
            numEntryAreaText.remove(at: numEntryAreaText.index(before: numEntryAreaText.endIndex))
            UIView.setAnimationsEnabled(false)
            numEntryArea.setTitle(numEntryAreaText, for: UIControlState.normal)
            numEntryArea.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    // Closes the calculator
    @IBAction func rightSwipeGestureRecognizer(_ sender: AnyObject) {
        self.removeFromSuperview()
    }
    
    @IBAction func addSqrtToEntryArea( _ sender: UIButton) {
        numEntryAreaText += "sqrt("
        UIView.performWithoutAnimation({
            self.numEntryArea.setTitle(self.numEntryAreaText, for: UIControlState.normal);
            self.numEntryArea.layoutIfNeeded()
        })
    }

    @IBAction func addTextAndParenthesisToEntryArea( _ sender: UIButton) {
        numEntryAreaText += sender.titleLabel!.text! + "("
        UIView.performWithoutAnimation({
            self.numEntryArea.setTitle(self.numEntryAreaText, for: UIControlState.normal);
            self.numEntryArea.layoutIfNeeded()
        })
    }
    @IBAction func addTextToEntryArea( _ sender: UIButton) {
        numEntryAreaText += sender.titleLabel!.text!
        UIView.performWithoutAnimation({
            self.numEntryArea.setTitle(self.numEntryAreaText, for: UIControlState.normal);
            self.numEntryArea.layoutIfNeeded()
        })
    }
    @IBAction func equalsButtonPushed( _ sender: UIButton){
        let parser: Parser = Parser(functionString: (self.numEntryArea.titleLabel?.text)!)
        do {
            try parser.parserPlot(start: 1, end: 2, totalSteps: 3)
        } catch MathError.missingOperand {
            print("Missing operand, abort")
        } catch MathError.unmatchedParenthesis {
            print("Missing parenthesis, abort")
        }
        catch let error {
            print(error.localizedDescription)
        }
        if(parser.getError() == ""){
            deleteTextFromEntryArea(self)
            let answer: Float64 = parser.getY()[0]
            numEntryAreaText = String(answer)
            UIView.performWithoutAnimation({
                self.numEntryArea.setTitle(self.numEntryAreaText, for: UIControlState.normal);
                self.numEntryArea.layoutIfNeeded()
            })
        }else{
            print(parser.getError())
            super.viewController?.displayErrorInViewController(title: "Check Your Input", description: parser.getError())
        }
    }
    
}
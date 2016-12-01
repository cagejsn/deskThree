//
//  AllPad.swift
//  EngineeringDesk
//
//  Created by Cage Johnson on 11/24/15.
//  Copyright © 2015 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit

class AllPad: InputObject {
    
    //MARK: Variables
    var numEntryAreaText: String = ""
    @IBOutlet var view: UIView!
    @IBOutlet weak var numEntryArea: OutputArea!
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var buttonDot: UIButton!
    @IBOutlet weak var buttonNeg: UIButton!
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
    @IBOutlet weak var buttonEquals: OutputArea!
    @IBOutlet weak var buttonParens: OutputArea!
    @IBOutlet weak var buttonSum: OutputArea!
    @IBOutlet weak var buttonZ: OutputArea!
    
    @IBOutlet weak var buttonArccos: OutputArea!
    @IBOutlet weak var buttonLog: OutputArea!
    @IBOutlet weak var buttonY: OutputArea!
    
    @IBOutlet weak var buttonArcsin: OutputArea!
    
    @IBOutlet weak var buttonArctan: OutputArea!
    
    
    
    
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        numEntryArea.delegate = self
        numEntryArea.typeOfInputObject = 1
        
        buttonPlus.delegate = self
        buttonPlus.typeOfInputObject = 2
        
        buttonMinus.delegate = self
        buttonMinus.typeOfInputObject = 2
        
        buttonMultiply.delegate = self
        buttonMultiply.typeOfInputObject = 2
        
        buttonDivide.delegate = self
        buttonDivide.typeOfInputObject = 2
        
        buttonExponent.delegate = self
        buttonExponent.typeOfInputObject = 2
        
        buttonSQRT.delegate = self
        buttonSQRT.typeOfInputObject = 2
        
        buttonPi.delegate = self
        buttonPi.typeOfInputObject = 3
        
        buttonSin.delegate = self
        buttonSin.typeOfInputObject = 3
        
        buttonCos.delegate = self
        buttonCos.typeOfInputObject = 3
        
        buttonTan.delegate = self
        buttonTan.typeOfInputObject = 3
        
        buttonLn.delegate  = self
        buttonLn.typeOfInputObject = 3
        
        buttonExp.delegate = self
        buttonExp.typeOfInputObject = 3
        
        buttonX.delegate = self
        buttonX.typeOfInputObject = 3
        
        buttonEquals.delegate = self
        buttonEquals.typeOfInputObject = 3
        
        buttonParens.delegate = self
        buttonParens.typeOfInputObject = 3
        
        buttonSum.delegate = self
        buttonSum.typeOfInputObject = 3
        
        buttonZ.delegate = self
        buttonZ.typeOfInputObject = 3
        
        buttonArccos.delegate = self
        buttonArccos.typeOfInputObject = 3
        
        buttonLog.delegate = self
        buttonLog.typeOfInputObject = 3
        
        buttonY.delegate = self
        buttonY.typeOfInputObject = 3
        
        buttonArcsin.delegate = self
        buttonArcsin.typeOfInputObject = 3
        
        buttonArctan.delegate = self
        buttonArctan.typeOfInputObject = 3
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.backgroundColor = Constants.pad.colors.gray
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        numEntryArea.titleLabel!.numberOfLines = 1
        numEntryArea.titleLabel!.adjustsFontSizeToFitWidth = true
        numEntryArea.titleLabel!.lineBreakMode = NSLineBreakMode.ByClipping
        view.layer.cornerRadius = 15;
        
        for element in view.subviews {
            element.layer.cornerRadius = 10;
        }
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName:"AllPad", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    
    
    
    //MARK: Events
    @IBAction func deleteTextFromEntryArea(sender: AnyObject) {
        if (numEntryAreaText.characters.count > 0) {
            numEntryAreaText.removeAtIndex(numEntryAreaText.endIndex.predecessor())
            UIView.setAnimationsEnabled(false)
            numEntryArea.setTitle(numEntryAreaText, forState: UIControlState.Normal)
            numEntryArea.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    
    @IBAction func addTextToEntryArea(sender: UIButton) {
        numEntryAreaText += sender.titleLabel!.text!
        UIView.performWithoutAnimation({
            self.numEntryArea.setTitle(self.numEntryAreaText, forState: UIControlState.Normal);
            self.numEntryArea.layoutIfNeeded()
        })
    }
    
}

//
//  NewCollectionViewCell.swift
//  deskThree
//
//  Created by Cage Johnson on 12/6/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class NewCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var translucentView: ILTranslucentView!
    
    @IBOutlet var marchingAntsOnBorderView: UIView!
    
    @IBOutlet weak var newProjectThumbnail: UIImageView!
    var viewBorder: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        translucentView.translucentAlpha = 0.8;
        translucentView.translucentStyle = .default
        translucentView.translucentTintColor = UIColor.init(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
        translucentView.backgroundColor = UIColor.clear
        
//        newProjectThumbnail.image = #imageLiteral(resourceName: "apple")
        self.backgroundColor = FileExplorerColors.LightGrey
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupMarchingAntsBorder()
    }
    
    func setupMarchingAntsBorder(){
        if(viewBorder == nil){
            viewBorder = CAShapeLayer()
        } else { return }
        
        viewBorder.strokeColor = UIColor.black.cgColor
        viewBorder.lineDashPattern = [5, 5]
//        viewBorder.frame = marchingAntsOnBorderView.bounds
        viewBorder.fillColor = nil
        var path = UIBezierPath()
        path.move(to: CGPoint(x: 1, y: marchingAntsOnBorderView.bounds.height))
        path.addLine(to: CGPoint(x: 1, y: 1))
        path.addLine(to: CGPoint(x: marchingAntsOnBorderView.bounds.width - 1, y:1))
        path.addLine(to: CGPoint(x: marchingAntsOnBorderView.bounds.width - 1, y:marchingAntsOnBorderView.bounds.height))
        viewBorder.path = path.cgPath
        viewBorder.lineWidth = 1
        
        var marchingAntsAnimation = {()->CABasicAnimation in
            var anm = CABasicAnimation(keyPath: "lineDashPhase")
            anm.duration = 0.8
            anm.fromValue = NSNumber(value: 0.0)
            anm.toValue = NSNumber(value: 10.0)
            anm.repeatCount = .infinity
            return anm
        }()
        viewBorder.add(marchingAntsAnimation, forKey: "marchingTheAnts")
        
        marchingAntsOnBorderView.layer.addSublayer(viewBorder)
       
        
    
    }
    
    
    
    
}

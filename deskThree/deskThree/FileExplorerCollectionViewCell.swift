//
//  FileExplorerCollectionViewCell.swift
//  deskThree
//
//  Created by Cage Johnson on 10/1/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class FileExplorerCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet  fileprivate var fileImage: UIImageView?
    @IBOutlet   fileprivate var fileName: UILabel!
    @IBOutlet  fileprivate var newIconView: UIView!
    @IBOutlet  fileprivate var gradeLabel: UILabel!
    @IBOutlet   fileprivate var dueDateView: UILabel?
    
    @IBOutlet var infoContainerView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        fileImage?.image = #imageLiteral(resourceName: "docsIcon")
        fileImage?.contentMode = .scaleAspectFit
        
        dueDateView?.backgroundColor = UIColor.clear
        dueDateView?.text = "09/10/18"
        dueDateView?.textColor = UIColor.white
        
        
        //newIconView.backgroundColor = UIColor.lightGray
       // newIconView?.layer.cornerRadius = newIconView/2
        stylizeNewIconView()
        
        //info container view
        infoContainerView.layer.backgroundColor = UIColor.darkGray.cgColor
        infoContainerView.alpha = 0.4
        infoContainerView.layer.cornerRadius = infoContainerView.frame.height / 6
        
        
        
        
    }
    
    
    func stylizeNewIconView(){
        newIconView.backgroundColor = UIColor.clear
        let margins = newIconView.layoutMarginsGuide
        var newIcon = UIView()
        newIcon.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        newIcon.backgroundColor = UIColor.cyan
        newIconView.addSubview(newIcon)
        newIcon.translatesAutoresizingMaskIntoConstraints = false
        newIcon.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        newIcon.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        newIcon.widthAnchor.constraint(equalToConstant: 10).isActive = true
        newIcon.heightAnchor.constraint(equalToConstant: 10).isActive = true
        newIcon.layer.cornerRadius = 5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()  
        infoContainerView.layer.cornerRadius = infoContainerView.frame.height / 2

    
    
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
      
        
       // fatalError("init(coder:) has not been implemented")
    }
}

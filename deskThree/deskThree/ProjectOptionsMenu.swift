//
//  ProjectOptionsMenu.swift
//  deskThree
//
//  Created by Cage Johnson on 12/3/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

protocol ProjectOptionsMenuDelegate {
    func onRenameTapped()
    func onMoveTapped()
    func onDeleteTapped()
    func onShareTapped()
    
}

class ProjectOptionsMenu: ILTranslucentView {
    
    var renameButton: UIButton!
    var moveButton: UIButton!
    var deleteButton: UIButton!
    var shareButton: UIButton!
    
    var delegate: ProjectOptionsMenuDelegate!
    
    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.alpha = 0.0
        
        setupButtons()
        setupConstraintsForButtons()
        stylize()
    }
    
    func onRenameTapped(){
        delegate.onRenameTapped()
    }
    
    func onMoveTapped(){
        delegate.onMoveTapped()
    }
    
    func onDeleteTapped(){
        delegate.onDeleteTapped()
    }
    
    func onShareTapped(){
        delegate.onShareTapped()
    }
    
    func removeBorders(){
        for border in borders {
            border.removeFromSuperlayer()
        }
        borders.removeAll()
    }
    
    var borders: [CALayer] = [CALayer]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        removeBorders()
        borders.append(renameButton.addAndReturnBottomBorder(color: FileExplorerColors.FaintlyDarkLightGrey, width: 1))
        borders.append(moveButton.addAndReturnBottomBorder(color: FileExplorerColors.FaintlyDarkLightGrey, width: 1))
        borders.append(deleteButton.addAndReturnBottomBorder(color: FileExplorerColors.FaintlyDarkLightGrey, width: 1))
    }
    
    func setupButtons(){
        renameButton = UIButton(type: .custom)
        moveButton = UIButton(type: .custom)
        deleteButton = UIButton(type: .custom)
        shareButton = UIButton(type: .custom)
        
      
//        shareButton = UIButton(type: .custom)
        
        renameButton.addTarget(self, action: #selector(ProjectOptionsMenu.onRenameTapped), for: .touchUpInside)
        moveButton.addTarget(self, action: #selector(ProjectOptionsMenu.onMoveTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(ProjectOptionsMenu.onDeleteTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(ProjectOptionsMenu.onShareTapped), for: .touchUpInside)
        
        renameButton.setTitleColor(FileExplorerColors.DarkGrey, for: .normal)
        moveButton.setTitleColor(FileExplorerColors.DarkGrey, for: .normal)
        deleteButton.setTitleColor(UIColor.red, for: .normal)
        shareButton.setTitleColor(FileExplorerColors.DeskBlue, for: .normal)
        
        renameButton.translatesAutoresizingMaskIntoConstraints = false
        moveButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        renameButton.setTitle("Rename", for: .normal)
        moveButton.setTitle("Move", for: .normal)
        deleteButton.setTitle("Delete", for: .normal)
        shareButton.setTitle("Share", for: .normal)
        
        self.addSubview(renameButton)
        self.addSubview(moveButton)
        self.addSubview(deleteButton)
        self.addSubview(shareButton)
        
    }
    
    func setupConstraintsForButtons(){
        NSLayoutConstraint.activate([ renameButton.topAnchor.constraint(equalTo: topAnchor),
                                      
                                      //left edges
                                      renameButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                                      moveButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                                      deleteButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                                      shareButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                                      
                                      //right edges
                                      renameButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                                      moveButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                                      deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                                      shareButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                                      
                                      shareButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                                      
                                      //borders
                                      renameButton.bottomAnchor.constraint(equalTo: moveButton.topAnchor),
                                      moveButton.bottomAnchor.constraint(equalTo: deleteButton.topAnchor),
                                      deleteButton.bottomAnchor.constraint(equalTo: shareButton.topAnchor),
                                      
                                      //height
                                      renameButton.heightAnchor.constraint(equalToConstant: frame.height / 4 ),
                                      moveButton.heightAnchor.constraint(equalTo: renameButton.heightAnchor),
                                      deleteButton.heightAnchor.constraint(equalTo: renameButton.heightAnchor),
                                      shareButton.heightAnchor.constraint(equalTo: renameButton.heightAnchor)
                                      ])
        
    }
    
    func stylize(){
        self.translucentAlpha = 0.9;
        self.translucentStyle = .default
        self.translucentTintColor = FileExplorerColors.LightGrey
        self.backgroundColor = UIColor.clear
    }
    
}

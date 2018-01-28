//
//  FileExplorerCollectionViewCell.swift
//  deskThree
//
//  Created by Cage Johnson on 10/1/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

protocol FECVEDelegate {
    func renameTappedForCell(_ cell: FileExplorerCollectionViewCell)
    func onMoveTapped(_ cell: FileExplorerCollectionViewCell)
    func onDeleteTapped(_ cell: FileExplorerCollectionViewCell)
    func onShareTapped(_ cell: FileExplorerCollectionViewCell)
}

class FileExplorerCollectionViewCell: UICollectionViewCell, ProjectOptionsMenuDelegate{
    
    var project: DeskProject!
    
    @IBOutlet  fileprivate var fileThumbnail: FileThumbnailButton?
    
    @IBOutlet var projectNameLabel: UILabel!
    
    @IBOutlet var lastModifiedLabel: UILabel!
    
    @IBOutlet var projectOptionsButton: ProjectOptionsButton!
    
    @IBOutlet var fauxToolbarView: ILTranslucentView!
    
    @IBOutlet var projectOptionsMenu: ProjectOptionsMenu!
    
    var delegate: FECVEDelegate!
    
    var projectOptionsVisible: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    
        
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if projectOptionsVisible {
            quickHideProjectOptions()
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = FileExplorerColors.LightGrey
        
        fauxToolbarView.translucentAlpha = 0.8;
        fauxToolbarView.translucentStyle = .default
        fauxToolbarView.translucentTintColor = DeskColors.DeskBlueBarColor
        fauxToolbarView.backgroundColor = UIColor.clear
        
        projectOptionsMenu.delegate = self
        
    }
    
    func readInData( project: DeskProject){
        self.project = project
        projectNameLabel.text = project.getName()
        lastModifiedLabel.text = project.getName()
    }
    
    
    func stylizeNewIconView(){

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()  
    
    }
    
    
    func onRenameTapped() {
        delegate.renameTappedForCell(self)
    }
    
    func onMoveTapped() {
        delegate.onMoveTapped(self)
    }
    
    func onDeleteTapped() {
        delegate.onDeleteTapped(self)
    }
    
    func onShareTapped() {
        delegate.onShareTapped(self)
    }
    
    @IBAction func onProjectOptionsTapped(_ sender: Any) {
        
        !projectOptionsVisible ?  showProjectOptions() : hideProjectOptions()
        
    }
    
    func showProjectOptions(){
        self.bringSubview(toFront: projectOptionsMenu)
        UIView.animate(withDuration: 0.7, delay: 0.0, animations: {
            self.projectOptionsMenu.alpha = 1.0 })
        projectOptionsVisible = true
    }
    
    func hideProjectOptions(){
    
        UIView.animate(withDuration: 0.7, delay: 0.0, animations: {
            self.projectOptionsMenu.alpha = 0.0
        })
        projectOptionsVisible = false
    }
    
    func quickHideProjectOptions(){
        projectOptionsMenu.alpha = 0.0
        projectOptionsVisible = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var convertedPointForOptionsMenu = self.convert(point, to: projectOptionsMenu)
        if(projectOptionsMenu.point(inside: convertedPointForOptionsMenu, with: event)){
            return projectOptionsMenu.hitTest(convertedPointForOptionsMenu,with:event)
        }
        
        var convertedPointForOptionsButton = self.convert(point, to: projectOptionsButton)
        if(projectOptionsButton.point(inside: convertedPointForOptionsButton, with: event)){
            return projectOptionsButton
        }
        return super.hitTest(point, with: event)
    }
}

//
//  TutorialVideoViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 4/16/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class TutorialVideoViewController: UIViewController {
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadYoutube(videoID: "VUwfoC7I1Pk")
    }
    
    func loadYoutube(videoID:String) {
        guard
            let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)")
            else { return }
        webView.loadRequest( URLRequest(url: youtubeURL) )
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
}

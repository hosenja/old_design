//
//  VideoExampleViewController.swift
//  Snapgroup
//
//  Created by snapmac on 06/12/2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoExampleViewController: UIViewController {
    var moviePlayer : MPMoviePlayerController?
    override func viewDidLoad() {
        super.viewDidLoad()
        playVideo()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func playVideo() {
        let path = "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8"
        if let url = NSURL(string: path),
            let moviePlayer = MPMoviePlayerController(contentURL: url as URL) {
            self.moviePlayer = moviePlayer
            moviePlayer.view.frame = self.view.bounds
            moviePlayer.prepareToPlay()
            moviePlayer.scalingMode = .aspectFill
            self.view.addSubview(moviePlayer.view)
        } else {
            debugPrint("Ops, something wrong when playing .m3u8 file")
        }
    }
    
}

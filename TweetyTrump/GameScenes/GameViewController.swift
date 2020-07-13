//
//  GameViewController.swift
//  TweetyTrump
//
//  Created by Kaden Storrs on 7/12/20.
//  Copyright © 2020 Kaden Storrs. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
class GameViewController: UIViewController {
    @IBOutlet weak var tweetView: UIView!
    @IBOutlet weak var trumpImageView: UIImageView!
    @IBOutlet weak var trumpNameLabel: UILabel!
    @IBOutlet weak var verifyImageView: UIImageView!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var tweet: Tweet?
    let tweetController: TrumpTweetController = TrumpTweetNetworkController()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tweetController.getTweet { (result) in
            DispatchQueue.main.async {
            let timer = Timer(timeInterval: 7, repeats: true) { (timer) in
                    switch result {
                    case .success(let tweet):
                        print(tweet)
                        self.tweet = tweet
                        self.tweetLabel.text = tweet.value
                        self.dateLabel.text = tweet.created_at
                    case .failure:
                        let alert = UIAlertController(title: "Error", message: "Failed ot load data", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    }
                    timer.isValid
                }
                timer.fire()
            }
        }
  
        
       let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = false
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//
//  GameViewController.swift
//  Triangle Flip
//
//  Created by Nelson Tejeda on 7/24/17.
//  Copyright © 2017 Nu Seble Games. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController,GADBannerViewDelegate {
    @IBOutlet weak var myBanner: GADBannerView!
    
    func handleSwipes(sender: UISwipeGestureRecognizer)
    {
        if(sender.direction == .down)
        {
            print("it worked")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //request 
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        //set up add
        myBanner.adUnitID = "ca-app-pub-1780411186396609/9751459371"
        myBanner.rootViewController = self
        myBanner.delegate = self
        myBanner.load(request)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
        
        
       
    }

    override var shouldAutorotate: Bool {
        return true
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
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

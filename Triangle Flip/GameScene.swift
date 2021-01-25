//
//  GameScene.swift
//  Triangle Flip
//
//  Created by Nelson Tejeda on 7/24/17.
//  Copyright © 2017 Nu Seble Games. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import AudioToolbox

struct PhysicsCatagory{
    static let player : UInt32 = 0x1 << 1
    static let Wall : UInt32 = 0x1 << 2
    static let score: UInt32 = 0x1 << 3
    static let floor : UInt32 = 0x1 << 4
    static let bombs : UInt32 = 0x1 << 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Sprites
    
    var player: SKSpriteNode?
    var wallPair = SKNode()
    var spikePair1 = SKNode()
    var spikePair2 = SKNode()
    var moveAndRemove = SKAction()
    var moveAndRemoveBombs = SKAction()
    var ground = SKSpriteNode()
    var score = Int()
    let scoreLbl = SKLabelNode()
    var highScore = Int()
    let highScoreLbl = SKLabelNode()
    let touchLbl = SKLabelNode()
    var random = SKSpriteNode()
    var oneSound = true
    var bombPair = SKNode()
    //swipe variables
    var isUp = true
    var isDown = false
    var isInAir = false
    var ST = 1.5
    //Game
    var GameStart = false
    var died = Bool()
    var restartBTN = SKSpriteNode()
    //sounds
    var jumpSound = AVAudioPlayer()
    var switchSound = AVAudioPlayer()
    var switchSound2 = AVAudioPlayer()
    var doVibrate = AudioServicesPropertyID(kSystemSoundID_Vibrate)
    var death = AVAudioPlayer()
    var restartSound = AVAudioPlayer()
    var highScoreSound = AVAudioPlayer()
    var played = true
    
    func restartScene()
    {
        self.removeAllChildren()
        self.removeAllActions()
        self.physicsWorld.gravity = CGVector(dx: 0.0,dy: -9.3)
        died = false
        GameStart = false
        isUp = true
        isDown = false
        isInAir = false
        score = 0
        scoreLbl.text = NSString(format: "%i", score) as String
        oneSound = true
        played = true
        createScene()
    }
    
    
    
    //touch
    func handleSwipes(sender: UISwipeGestureRecognizer)
    {
        if (sender.direction == .up)
        {
            if(GameStart == true && isUp == false && isInAir == false && isDown == true)
            {
                over()
                switchSound.volume = 1
                switchSound.play()
                isDown = false
                isInAir = false
            }
            
        }
        if (sender.direction == .down)
        {
            if(GameStart == true && isUp == true && isInAir == false && isDown == false)
            {
                under()
                switchSound2.volume = 1
                switchSound2.play()
                isUp = false
                isInAir = false
            }
        }
    }
    
    func tapButton(sender: UITapGestureRecognizer)
    {
        let cg = CGFloat(27)
        if (GameStart == true && isUp == true && (player?.position.y)! < cg)
        {
            jumpSound.volume = 3
            jumpSound.play()
            jump1()
        }
        if (GameStart == true && isDown == true)
        {
            jumpSound.play()
            jump2()
        }
    
    }
    
    func createScene(){
        //touch to start label
        
        touchLbl.position = CGPoint(x: 0, y: 125)
        touchLbl.fontSize = 24
        touchLbl.text = "touch to start"
        touchLbl.fontName = "Press Start K"
        self.addChild(touchLbl)
        touchLbl.run(blinkAnimation())
        
        
        //sounds
        do{
            jumpSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "pepSound3", ofType: "mp3")!))
            jumpSound.prepareToPlay()
            
            switchSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "switchSound", ofType: "mp3")!))
            switchSound.prepareToPlay()
            
            switchSound2 = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "switchSound", ofType: "mp3")!))
            switchSound.prepareToPlay()
            
            death = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Light Tapping Sound Effect (Royalty Free)", ofType: "mp3")!))
            death.prepareToPlay()
            
            restartSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Modern Lamp Switch SOUND Effect", ofType: "mp3")!))
            restartSound.prepareToPlay()
            
            highScoreSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "powerUp7", ofType: "mp3")!))
            highScoreSound.prepareToPlay()
        }
        catch{
            print(error)
        }
        
        //score
        scoreLbl.position = CGPoint(x: 0 , y: self.frame.height / 3) //450
        scoreLbl.fontSize = 128
        scoreLbl.fontName = "Quango"
        scoreLbl.color = SKColor.black
        scoreLbl.text = NSString(format: "%i", score) as String
        if(UIDevice.current.userInterfaceIdiom == .pad){
            scoreLbl.position = CGPoint(x: 0 , y: self.frame.height / 4.2)
        }
        
        self.addChild(scoreLbl)
        
        
        //high score
        
        highScoreLbl.position = CGPoint(x: 0 , y: self.frame.height / -2.7)
        highScoreLbl.fontSize = 110
        highScoreLbl.fontName = "Trench"
        highScoreLbl.color = SKColor.black
        highScoreLbl.text = NSString(format: "Highscore : %i", highScore) as String
        if(UIDevice.current.userInterfaceIdiom == .pad){
            highScoreLbl.position = CGPoint(x: 0 , y: self.frame.height / -3.9)

        }
        
        self.addChild(highScoreLbl)
        
        //floors
        let floor1 = SKSpriteNode(imageNamed: "slice36_36")
        floor1.size = CGSize(width: 748.032, height: 2.505)
        floor1.position = CGPoint(x: 0.984, y: -30.597)
        floor1.physicsBody = SKPhysicsBody(rectangleOf: floor1.size)
        floor1.physicsBody?.categoryBitMask = PhysicsCatagory.floor
        floor1.physicsBody?.collisionBitMask = PhysicsCatagory.player | PhysicsCatagory.bombs
        floor1.physicsBody?.contactTestBitMask = PhysicsCatagory.player | PhysicsCatagory.bombs
        floor1.physicsBody?.affectedByGravity = false
        floor1.physicsBody?.isDynamic = false
        floor1.physicsBody?.pinned = true
        self.addChild(floor1)
        
        
        let floor2 = SKSpriteNode(imageNamed: "slice36_36")
        floor2.size = CGSize(width: 748.032, height: 2.505)
        floor2.position = CGPoint(x: 0.984, y: -77.857)
        floor2.physicsBody = SKPhysicsBody(rectangleOf: floor2.size)
        floor2.physicsBody?.categoryBitMask = PhysicsCatagory.floor
        floor2.physicsBody?.collisionBitMask = PhysicsCatagory.player | PhysicsCatagory.bombs
        floor2.physicsBody?.contactTestBitMask = PhysicsCatagory.player | PhysicsCatagory.bombs
        floor2.physicsBody?.affectedByGravity = false
        floor2.physicsBody?.isDynamic = false
        floor2.physicsBody?.pinned = true
        self.addChild(floor2)
        
        //player
        player = SKSpriteNode(imageNamed: "player_walk1")
        player?.size = CGSize(width: 80, height: 110)
        player?.zPosition = 5
        self.addChild(player!)
        player?.position = CGPoint(x: -314.457, y: 28.2)
        
                
        
        player?.physicsBody = SKPhysicsBody(circleOfRadius: (player?.frame.height)! / 2)
        player?.physicsBody?.categoryBitMask = PhysicsCatagory.player
        player?.physicsBody?.collisionBitMask = PhysicsCatagory.Wall | PhysicsCatagory.floor | PhysicsCatagory.bombs
        player?.physicsBody?.contactTestBitMask = PhysicsCatagory.Wall | PhysicsCatagory.score | PhysicsCatagory.floor | PhysicsCatagory.bombs
        player?.physicsBody?.affectedByGravity = true
        player?.physicsBody?.usesPreciseCollisionDetection = true
        
        
        
        
        //ground
        
        createGrounds()
        
        //walking
        let walking:SKAction = SKAction(named: "Walking")!
        player?.run(walking)
        
        
        
        //swipes
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
        downSwipe.direction = .down
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
        upSwipe.direction = .up
        view?.addGestureRecognizer(downSwipe)
        view?.addGestureRecognizer(upSwipe)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapButton(sender:)))
        view?.addGestureRecognizer(tap)
        
        var highscoreDefault = UserDefaults.standard
        
        if(highscoreDefault.value(forKey: "HighScore") != nil)
        {
            highScore = highscoreDefault.value(forKey: "HighScore") as! NSInteger
            highScoreLbl.text = NSString(format: "Highscore : %i", highScore) as String
        }
       
        
        
    }
    
        override func didMove(to view: SKView) {
            self.physicsWorld.contactDelegate = self
            createScene()
            
            
            
            
        }
    
    func createBTN(){
        
        restartBTN = SKSpriteNode(imageNamed: "restartButton")
        restartBTN.position = CGPoint(x: 0, y: 0)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        restartBTN.run(SKAction.scale(to: 2.0, duration: 0.4))
    }
    
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCatagory.Wall && secondBody.categoryBitMask == PhysicsCatagory.player || firstBody.categoryBitMask == PhysicsCatagory.player && secondBody.categoryBitMask == PhysicsCatagory.Wall{
            
            died = true
            isUp = false
            isDown = false
            
            let fall:SKAction = SKAction(named: "Falling")!
            let fall2 = SKAction.run
            {
                self.player?.run(fall)
            }
            self.run(fall2)
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.3)
            player?.physicsBody?.collisionBitMask = 0
            
            if oneSound == true
            {
                death.currentTime = 10.7
                death.play()
                createBTN()
                oneSound = false
            }
        }
        if firstBody.categoryBitMask == PhysicsCatagory.score && secondBody.categoryBitMask == PhysicsCatagory.player || firstBody.categoryBitMask == PhysicsCatagory.player && secondBody.categoryBitMask == PhysicsCatagory.score{
            
            if(died == false)
            {
                score += 1
                scoreLbl.text = NSString(format: "%i", score) as String
                if(score > highScore)
                {
                    if played == true
                    {
                        highScoreSound.play()
                        played = false
                    }
                    highScore = score
                    highScoreLbl.text = NSString(format: "Highscore : %i", highScore) as String
                }
            }
            else{
                score += 0
                scoreLbl.text = NSString(format: "%i", score) as String
                var highscoreDefault = UserDefaults.standard
                highscoreDefault.setValue(highScore, forKey: "HighScore")
                highscoreDefault.synchronize()
                
            }
            
            if firstBody.categoryBitMask == PhysicsCatagory.bombs && secondBody.categoryBitMask == PhysicsCatagory.player || firstBody.categoryBitMask == PhysicsCatagory.player && secondBody.categoryBitMask == PhysicsCatagory.bombs{
                
                let ex: SKAction = SKAction(named: "boom")!
                let ex2 = SKAction.run {
                    self.bombPair.run(ex)
                }
                self.run(ex2)
                
            }
            
        }
        
        
            
        
        
    }
        
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches { self.touchDown(atPoint: t.location(in: self)) }
            
            if GameStart == false{
                //walls
                GameStart = true
                let spawn = SKAction.run(self.createWalls)
                let delay = SKAction.wait(forDuration: TimeInterval(ST))
                let spawnDelay = SKAction.sequence([spawn,delay])
                let spawnDelayForever = SKAction.repeatForever(spawnDelay)
                self.run(spawnDelayForever)
                
                let distance = CGFloat(self.frame.width + wallPair.frame.width)
                let moveWalls = SKAction.moveBy(x: -distance - 500, y: 0, duration: TimeInterval(3.2))
                let removepipes = SKAction.removeFromParent()
                moveAndRemove = SKAction.sequence([moveWalls,removepipes])
                touchLbl.removeFromParent()
                //movingBombs()
                
                
                
            }
            else
            {
                if died == true
                {
                    
                }
                else
                {
                    /*player?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0))
                    isUp = false
                    isDown = false
                    isInAir = true*/
                }
            }
            
            
            for touch in touches{
                let location = touch.location(in: self)
                if died == true{
                    if restartBTN.contains(location)
                    {
                        let waitForSound = SKAction.wait(forDuration: 0.3)
                        let playRestart = SKAction.run {
                            self.restartSound.currentTime = 0.5
                            self.restartSound.play()
                        }
                        let finish = SKAction.run(restartScene)
                        let runBTN = SKAction.sequence([playRestart,waitForSound,finish])
                        self.run(runBTN)
                        
                    }
                }
            }
    }

        func touchDown(atPoint pos: CGPoint) {
           
        }
        func jump1() {
            isInAir = true
            let j = SKAction.run(topJump)
            let delay = SKAction.wait(forDuration: 0.5)
            let air = SKAction.run(airFunc)
            let jumping = SKAction.sequence([j,delay,air])
            self.run(jumping)
        }
    
        func topJump() {
            player?.texture = SKTexture(imageNamed: "player_jump")
            player?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
            
        }
    
        func jump2()
        {
            isInAir = true
            let jump = SKAction.moveTo(y: -258.509, duration: 0.3)
            let down = SKAction.moveTo(y: -133.367, duration: 0.5)
            let air = SKAction.run(airFunc)
            let jumpUnder = SKAction.sequence([jump,down,air])
            player?.run(jumpUnder)
            
        }
    
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        }
    
        func touchUp(atPoint pos: CGPoint) {
            player?.texture = SKTexture(imageNamed: "player_walk1")
        }
    
        override func update(_ currentTime: TimeInterval) {
            // Called before each frame is rendered
            moveGround()
            if(died == true)
            {
                self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.3)
                player?.physicsBody?.collisionBitMask = 0
                isUp = false
                isDown = false
            }

        }
    
    
    func createWalls(){

        wallPair = SKNode()
        spikePair1 = SKNode()
        spikePair2 = SKNode()
        let scoreSpike1 = SKSpriteNode()
        let scoreSpike2 = SKSpriteNode()
        let normalScore = SKSpriteNode()
        let normalScore2 = SKSpriteNode()
        
        //score is kept by how many walls are passed.
        
        scoreSpike1.size = CGSize(width: 1, height: 350)
        scoreSpike1.position = CGPoint(x: 603.262, y: 55)
        scoreSpike1.physicsBody = SKPhysicsBody(rectangleOf: scoreSpike1.size)
        scoreSpike1.physicsBody?.categoryBitMask = PhysicsCatagory.score
        scoreSpike1.physicsBody?.collisionBitMask = 0
        scoreSpike1.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        scoreSpike1.physicsBody?.affectedByGravity = false
        scoreSpike1.physicsBody?.isDynamic = false
        //scoreSpike1.color = SKColor.blue
        
        scoreSpike2.size = CGSize(width: 1, height: 350)
        scoreSpike2.position = CGPoint(x: 720.428, y: -125)
        scoreSpike2.physicsBody = SKPhysicsBody(rectangleOf: scoreSpike2.size)
        scoreSpike2.physicsBody?.categoryBitMask = PhysicsCatagory.score
        scoreSpike2.physicsBody?.collisionBitMask = 0
        scoreSpike2.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        scoreSpike2.physicsBody?.affectedByGravity = false
        scoreSpike2.physicsBody?.isDynamic = false
        //scoreSpike2.color = SKColor.blue
        
        normalScore.size = CGSize(width: 1, height: 350)
        normalScore.position = CGPoint(x: 403.262, y: -50)
        normalScore.physicsBody = SKPhysicsBody(rectangleOf: normalScore.size)
        normalScore.physicsBody?.categoryBitMask = PhysicsCatagory.score
        normalScore.physicsBody?.collisionBitMask = 0
        normalScore.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        normalScore.physicsBody?.affectedByGravity = false
        normalScore.physicsBody?.isDynamic = false
        //normalScore.color = SKColor.blue
        
        normalScore2.size = CGSize(width: 1, height: 350)
        normalScore2.position = CGPoint(x: 620.428, y: 50)
        normalScore2.physicsBody = SKPhysicsBody(rectangleOf: normalScore2.size)
        normalScore2.physicsBody?.categoryBitMask = PhysicsCatagory.score
        normalScore2.physicsBody?.collisionBitMask = 0
        normalScore2.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        normalScore2.physicsBody?.affectedByGravity = false
        normalScore2.physicsBody?.isDynamic = false
        //normalScore2.color = SKColor.blue
        
        
        //spiked walls pair 1 
        
        //spike wall top
        
        let spike1 = SKSpriteNode(imageNamed: "slice36_36")
        spike1.position = CGPoint(x: 603.262, y: -1.787)
        spike1.size = CGSize(width: 50.0, height: 50.0)
        spike1.zRotation = CGFloat(M_PI)
        
        let botSpike1 = SKSpriteNode(imageNamed:"slice22_22")
        botSpike1.position = CGPoint(x: 603.262, y: -108.38)
        botSpike1.size = CGSize(width: 56.524, height: 60.026)
        
        let botSpike2 = SKSpriteNode(imageNamed:"slice22_22")
        botSpike2.position = CGPoint(x: 603.262, y: -168.406)
        botSpike2.size = CGSize(width: 56.524, height: 60.026)
        
        let botSpike3 = SKSpriteNode(imageNamed:"slice24_24")
        botSpike3.position = CGPoint(x: 603.262, y: -228.432)
        botSpike3.size = CGSize(width: 56.524, height: 60.026)

        // correct
        spike1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: spike1.size.width - 5, height: spike1.size.height - 5))
        spike1.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        spike1.physicsBody?.collisionBitMask = PhysicsCatagory.player
        spike1.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        spike1.physicsBody?.isDynamic = false
        spike1.physicsBody?.affectedByGravity = false
        spike1.physicsBody?.usesPreciseCollisionDetection = true
        
        botSpike1.physicsBody = SKPhysicsBody(rectangleOf: botSpike1.size)
        botSpike1.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        botSpike1.physicsBody?.collisionBitMask = PhysicsCatagory.player
        botSpike1.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        botSpike1.physicsBody?.isDynamic = false
        botSpike1.physicsBody?.affectedByGravity = false
        botSpike1.physicsBody?.usesPreciseCollisionDetection = true
        
        botSpike2.physicsBody = SKPhysicsBody(rectangleOf: botSpike2.size)
        botSpike2.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        botSpike2.physicsBody?.collisionBitMask = PhysicsCatagory.player
        botSpike2.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        botSpike2.physicsBody?.isDynamic = false
        botSpike2.physicsBody?.affectedByGravity = false
        botSpike2.physicsBody?.usesPreciseCollisionDetection = true
        
        botSpike3.physicsBody = SKPhysicsBody(rectangleOf: botSpike3.size)
        botSpike3.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        botSpike3.physicsBody?.collisionBitMask = PhysicsCatagory.player
        botSpike3.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        botSpike3.physicsBody?.isDynamic = false
        botSpike3.physicsBody?.affectedByGravity = false
        botSpike3.physicsBody?.usesPreciseCollisionDetection = true
        
        //end of first spike pair
        
        
        
        //spiked walls pair 2
        
        //spike wall bottom
        
        let spike2 = SKSpriteNode(imageNamed:"slice36_36")
        spike2.position = CGPoint(x: 720.428, y: -108.38)
        spike2.size = CGSize(width: 56.524, height: 60.026)
        
        let topSpike1 = SKSpriteNode(imageNamed:"slice22_22")
        topSpike1.position = CGPoint(x: 720.428, y: -1.787)
        topSpike1.size = CGSize(width: 56.524, height: 60.026)
        
        let topSpike2 = SKSpriteNode(imageNamed:"slice24_24")
        topSpike2.position = CGPoint(x: 720.428, y: 58.239)
        topSpike2.size = CGSize(width: 56.524, height: 60.026)
        
        let topSpike3 = SKSpriteNode(imageNamed:"slice22_22")
        topSpike3.position = CGPoint(x: 720.428, y: 108.213)
        topSpike3.size = CGSize(width: 56.524, height: 60.026)
        
        
        spike2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: spike2.size.width , height: spike2.size.height ))
        spike2.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        spike2.physicsBody?.collisionBitMask = PhysicsCatagory.player
        spike2.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        spike2.physicsBody?.isDynamic = false
        spike2.physicsBody?.affectedByGravity = false
        spike2.physicsBody?.usesPreciseCollisionDetection = true
        
        topSpike1.physicsBody = SKPhysicsBody(rectangleOf: topSpike1.size)
        topSpike1.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topSpike1.physicsBody?.collisionBitMask = PhysicsCatagory.player
        topSpike1.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        topSpike1.physicsBody?.isDynamic = false
        topSpike1.physicsBody?.affectedByGravity = false
        topSpike1.physicsBody?.usesPreciseCollisionDetection = true
        
        topSpike2.physicsBody = SKPhysicsBody(rectangleOf: topSpike2.size)
        topSpike2.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topSpike2.physicsBody?.collisionBitMask = PhysicsCatagory.player
        topSpike2.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        topSpike2.physicsBody?.isDynamic = false
        topSpike2.physicsBody?.affectedByGravity = false
        topSpike2.physicsBody?.usesPreciseCollisionDetection = true
        
        topSpike3.physicsBody = SKPhysicsBody(rectangleOf: topSpike3.size)
        topSpike3.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topSpike3.physicsBody?.collisionBitMask = PhysicsCatagory.player
        topSpike3.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        topSpike3.physicsBody?.isDynamic = false
        topSpike3.physicsBody?.affectedByGravity = false
        topSpike3.physicsBody?.usesPreciseCollisionDetection = true
        
        
        //end of spikes
        
        
        
        //new top walls
        let topWall1 = SKSpriteNode(imageNamed:"slice22_22")
        topWall1.position = CGPoint(x: 403.262, y: -1.787)
        topWall1.size = CGSize(width: 56.524, height: 60.026)
        
        let topWall2 = SKSpriteNode(imageNamed:"slice24_24")
        topWall2.position = CGPoint(x: 403.262, y: 58.239)
        topWall2.size = CGSize(width: 56.524, height: 60.026)
        
        let topWall3 = SKSpriteNode(imageNamed:"slice22_22")
        topWall3.position = CGPoint(x: 403.262, y: 108.213)
        topWall3.size = CGSize(width: 56.524, height: 60.026)
        
        //new bottom walls
        let botWall1 = SKSpriteNode(imageNamed:"slice22_22")
        botWall1.position = CGPoint(x: 620.428, y: -108.38)
        botWall1.size = CGSize(width: 56.524, height: 60.026)
        
        let botWall2 = SKSpriteNode(imageNamed:"slice22_22")
        botWall2.position = CGPoint(x: 620.428, y: -168.406)
        botWall2.size = CGSize(width: 56.524, height: 60.026)
        
        let botWall3 = SKSpriteNode(imageNamed:"slice24_24")
        botWall3.position = CGPoint(x: 620.428, y: -228.432)
        botWall3.size = CGSize(width: 56.524, height: 60.026)
        
        //physics body top walls
        topWall1.physicsBody = SKPhysicsBody(rectangleOf: topWall1.size)
        topWall1.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall1.physicsBody?.collisionBitMask = PhysicsCatagory.player
        topWall1.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        topWall1.physicsBody?.isDynamic = false
        topWall1.physicsBody?.affectedByGravity = false
        topWall1.physicsBody?.usesPreciseCollisionDetection = true
        
        topWall2.physicsBody = SKPhysicsBody(rectangleOf: topWall2.size)
        topWall2.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall2.physicsBody?.collisionBitMask = PhysicsCatagory.player
        topWall2.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        topWall2.physicsBody?.isDynamic = false
        topWall2.physicsBody?.affectedByGravity = false
        topWall2.physicsBody?.usesPreciseCollisionDetection = true
        
        topWall3.physicsBody = SKPhysicsBody(rectangleOf: topWall3.size)
        topWall3.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall3.physicsBody?.collisionBitMask = PhysicsCatagory.player
        topWall3.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        topWall3.physicsBody?.isDynamic = false
        topWall3.physicsBody?.affectedByGravity = false
        topWall3.physicsBody?.usesPreciseCollisionDetection = true
        
        //physics body bottom walls
        botWall1.physicsBody = SKPhysicsBody(rectangleOf: botWall1.size)
        botWall1.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        botWall1.physicsBody?.collisionBitMask = PhysicsCatagory.player
        botWall1.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        botWall1.physicsBody?.isDynamic = false
        botWall1.physicsBody?.affectedByGravity = false
        botWall1.physicsBody?.usesPreciseCollisionDetection = true
        
        botWall2.physicsBody = SKPhysicsBody(rectangleOf: botWall2.size)
        botWall2.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        botWall2.physicsBody?.collisionBitMask = PhysicsCatagory.player
        botWall2.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        botWall2.physicsBody?.isDynamic = false
        botWall2.physicsBody?.affectedByGravity = false
        botWall2.physicsBody?.usesPreciseCollisionDetection = true
        
        botWall3.physicsBody = SKPhysicsBody(rectangleOf: botWall3.size)
        botWall3.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        botWall3.physicsBody?.collisionBitMask = PhysicsCatagory.player
        botWall3.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        botWall3.physicsBody?.isDynamic = false
        botWall3.physicsBody?.affectedByGravity = false
        botWall3.physicsBody?.usesPreciseCollisionDetection = true
        
        //wallPair child
        
        wallPair.addChild(topWall1)
        wallPair.addChild(topWall2)
        wallPair.addChild(topWall3)
        wallPair.addChild(normalScore)
        
        wallPair.addChild(botWall1)
        wallPair.addChild(botWall2)
        wallPair.addChild(botWall3)
        wallPair.addChild(normalScore2)
        
        //spikes child
        
        spikePair1.addChild(spike1)
        spikePair1.addChild(botSpike1)
        spikePair1.addChild(botSpike2)
        spikePair1.addChild(botSpike3)
        spikePair1.addChild(scoreSpike1)
        
        spikePair2.addChild(spike2)
        spikePair2.addChild(topSpike1)
        spikePair2.addChild(topSpike2)
        spikePair2.addChild(topSpike3)
        spikePair2.addChild(scoreSpike2)
        
        let RS = CGFloat.random(min: 1, max: 3)
        let randomSpawn = CGFloat.random(min: 1, max: 6)
        let r = Int(randomSpawn)
        if r == 1 || r == 2
        {
            let randomSpike = Int(RS)
            if randomSpike == 1
            {
                self.addChild(spikePair1)
                spikePair1.run(moveAndRemove)
            }
            if randomSpike == 2 || randomSpike == 3
            {
                self.addChild(spikePair2)
                spikePair2.run(moveAndRemove)
            }
        }
        else{
            
            self.addChild(wallPair)
            wallPair.run(moveAndRemove)
            
        }
        
        
    }
    //player?.xScale = (player?.xScale)! * -1
    func under()
    {
        let gravAndCol1 = SKAction.run {
            self.player?.physicsBody?.affectedByGravity = false
            self.player?.physicsBody?.collisionBitMask = 0
        }
        let gravAndCol2 = SKAction.run {
            self.player?.physicsBody?.collisionBitMask = PhysicsCatagory.Wall | PhysicsCatagory.floor
            self.player?.physicsBody?.contactTestBitMask = PhysicsCatagory.Wall | PhysicsCatagory.score | PhysicsCatagory.floor
            self.physicsWorld.gravity = CGVector(dx: 0.0,dy: 0.2)
            self.player?.physicsBody?.affectedByGravity = true
        }
        let moveD:SKAction = SKAction(named: "MoveD")!
        let moveDown = SKAction.run {
            self.player?.run(moveD)
        }
        let cD = SKAction.run(climbDown)
        let reverse = SKAction.run(({
            self.player?.xScale = (self.player?.xScale)! * -1
        }))
        let rotate = SKAction.run {
            self.player?.zRotation = CGFloat(179.3)
        }
        let isUnder = SKAction.run {
            self.isUnder()
        }
        let physics = SKAction.run(physicsBack)
        let delay = SKAction.wait(forDuration: 0.2)
        let goUnder = SKAction.sequence([gravAndCol1,moveDown,cD,gravAndCol2,reverse,rotate,physics,isUnder])
        self.run(goUnder)
    }
    func over()
    {
        let gravAndCol1 = SKAction.run {
            self.player?.physicsBody?.affectedByGravity = false
            self.player?.physicsBody?.collisionBitMask = 0
        }
        let gravAndCol2 = SKAction.run {
            self.player?.physicsBody?.collisionBitMask = PhysicsCatagory.Wall | PhysicsCatagory.floor
            self.physicsWorld.gravity = CGVector(dx: 0.0,dy: -9.3)
            self.player?.physicsBody?.affectedByGravity = true
        }
        let moveU:SKAction = SKAction(named: "moveUP")!
        let moveUP = SKAction.run {
            self.player?.run(moveU)
        }
        let cUP = SKAction.run(climbUp)
        let reverse = SKAction.run(({
            self.player?.xScale = (self.player?.xScale)! * -1
        }))
        let rotate = SKAction.run {
            self.player?.zRotation = CGFloat(0)
        }
        let isOver = SKAction.run {
            self.isUp = true
        }
        let physics = SKAction.run(physicsBack)
        //let delay = SKAction.wait(forDuration: 0.2)
        
        //let position = SKAction.run {
           // self.player?.position = CGPoint(x: -314.5, y: 25.2)
       // }
        
        let goOver = SKAction.sequence([reverse,rotate,gravAndCol1,moveUP,cUP,gravAndCol2,physics,isOver])
        self.run(goOver)
    }
    
    func createGrounds()
    {
        for i in 1...13
        {
            let ground = SKSpriteNode(imageNamed: "grassHalfMid")
            ground.name = "Ground"
            ground.size = CGSize(width: 100.506, height: 77.001)
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ground.position = CGPoint(x: CGFloat(i) * -(ground.size.width), y: -70.349)
            
            self.addChild(ground)
        }
    }
    
    func moveGround()
    {
        self.enumerateChildNodes(withName: "Ground", using: ({
            (node,error) in
            node.position.x -= 5
            
            if node.position.x < -((self.scene?.size.width)!){
                
                node.position.x += (self.scene?.size.width)! * 1.70
            }
            
            
        }))
    }
    func airFunc()
    {
        isInAir = false
    }
    func climbDown()
    {
        let cD:SKAction = SKAction(named: "cD")!
        player?.run(cD)
    }
    func climbUp()
    {
        let cUP:SKAction = SKAction(named: "cUP")!
        player?.run(cUP)
    }
    func isUnder()
    {
        isDown = true
    }
    func isOver()
    {
        isUp = true
    }
    func physicsBack()
    {
        player?.physicsBody = SKPhysicsBody(circleOfRadius: (player?.frame.height)! / 2)
        player?.physicsBody?.categoryBitMask = PhysicsCatagory.player
        player?.physicsBody?.collisionBitMask = PhysicsCatagory.Wall | PhysicsCatagory.floor
        player?.physicsBody?.contactTestBitMask = PhysicsCatagory.Wall | PhysicsCatagory.score | PhysicsCatagory.floor
        player?.physicsBody?.affectedByGravity = true
    }
    
    
    func blinkAnimation() -> SKAction {
        let duration = 1.0
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let fadeIn = SKAction.fadeIn(withDuration: duration)
        let blink = SKAction.sequence([fadeOut,fadeIn])
        return SKAction.repeatForever(blink)
    }
    
    
}





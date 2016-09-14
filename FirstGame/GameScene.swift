//
//  GameScene.swift
//  FirstGame
//
//  Created by Esa Serog on 6/2/15.
//  Copyright (c) 2015 esaSerog. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var movingGround: JSMovingGround!
    var movingCieling: JSMovingGround!
    var player: ESSpaceship!
    var backgroundMusicPlayer : AVAudioPlayer!
    var PLAYER_STARTING_POINT : CGPoint!
    var isStarted = false
    let pauseButton: UIButton = UIButton(type: UIButtonType.custom)
    var isHit = false
    var bg : SKSpriteNode!
    var pause = false
    var asteroid : JSAsteroid!
    
    //timer for keeping score & increasing difficulty
    let timer : Timer = Timer()
    var timer_value = 0
    
    //array of asteroids
    let asteroids : NSMutableArray = NSMutableArray()
    
    
    
    var viewController: UIViewController?
    
    //starting message
    let label = SKLabelNode(text: "Tap the screen to start!")
    
    //counter for num of touches
    var counter = 0
    
    
    
    //START SCENE
    override func didMove(to view: SKView) {
        
        //play background music
        playBackgroundMusic("bg_music.mp3")
        backgroundColor = UIColor.clear //TODO: maybe add an image to the background to give it a space feel
        
        
        
        //MARK: setup world physics
        physicsWorld.contactDelegate = self
        addElementsAndUI()
    }//didMoveToView
    
    
    
    //gameSceneDidView above
    //==========================================================================================================================================//
    //==========================================================================================================================================//
    //more methods below
    
    
    
    //MARK: playBackgroundMusic
    func playBackgroundMusic(_ filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if(url == nil)
        {
            print("Could not find file: \(filename)")
            return
        }//if
        
        
        //below is an example of the new try catch in swift 2!
        do {
            try backgroundMusicPlayer = AVAudioPlayer(contentsOf: url!)
        } catch {
            print("Could not create audio player")
        }//catch
        
        backgroundMusicPlayer.numberOfLoops = -1 //toSetInfiniteLoop
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }//playBackgroundMusic
    
    
    //TODO: finish this method
    func reset() {
        player.position = PLAYER_STARTING_POINT
    }//reset
    
    
    //MARK: addPhysicsToWorld
    func addPhysicsToWorld() {
        //add physics to world
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -3.5)
        //addphysics to moving ground
        movingGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: view!.frame.width, height: movingGround.size.height * 2))
        movingGround.physicsBody?.isDynamic = false
        movingCieling.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: view!.frame.width, height: movingCieling.size.height/2))
        movingCieling.physicsBody?.isDynamic = false
        
        //add physics to ground and cieling
        //physics setup
        //TODO: find out why this doesn't work in class
        movingGround.physicsBody?.categoryBitMask = 0x1 << 1
        movingGround.physicsBody?.contactTestBitMask = 0x1 << 0
        movingCieling.physicsBody?.categoryBitMask = 0x1 << 1
        movingCieling.physicsBody?.contactTestBitMask = 0x1 << 0


    }//addPhysicsToWorld
    

    //MARK: blink animation
    func blinkAnimation() -> SKAction {
        let duration  = 0.6
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: duration)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: duration)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        return SKAction.repeatForever(blink)
    }//blinkAnimation
    
    
    //MARK: add elementsAndUI
    func addElementsAndUI() {
        //add background -- background added through sprite
        bg = SKSpriteNode(imageNamed: "game_bg.jpg")
        bg.size = CGSize(width: view!.frame.width, height:( view?.frame.height)!)
        bg.position = CGPoint(x: (view?.frame.width)!/2, y: view!.frame.height/2)
        
        //pause button
        pauseButton.frame = CGRect(x: (scene?.frame.width)! - (scene?.frame.width)! * 0.20, y: view!.frame.height - (view?.frame.height)! * 0.06, width: view!.frame.width * 0.20, height: view!.frame.height * 0.06)
        pauseButton.backgroundColor = UIColor.white
        pauseButton.titleLabel?.textAlignment = NSTextAlignment.center
        pauseButton.titleLabel?.textAlignment = NSTextAlignment.center
        pauseButton.setTitle("pause", for: UIControlState())
        pauseButton.tintColor = UIColor.clear
        pauseButton.addTarget(self, action: #selector(GameScene.pauseButtonPressed), for: UIControlEvents.touchUpInside)
        pauseButton.setTitleColor(UIColor.black, for: UIControlState())

        
        //create and position the player right above the ground
        player = ESSpaceship()
        player.position = CGPoint(x: 70, y: view!.frame.height/2.0 /*- player.frame.size.height/2*/)
        PLAYER_STARTING_POINT = player.position
        
        //ground and ceiling
        movingGround = JSMovingGround(size: CGSize(width: view!.frame.width, height: 20))
        movingCieling = JSMovingGround(size: CGSize(width: view!.frame.width, height: view!.frame.height/15))
        
        //set the position of the ground
        movingGround.position = CGPoint(x: 0, y: 0)
        movingCieling.position = CGPoint(x: 0, y: view!.frame.height - movingCieling.frame.height)
        
        //TODO: asteroid
        asteroid = JSAsteroid(scene: self)
        
        //physics
        addPhysicsToWorld()
        
        //label
        label.position.x = view!.center.x
        label.position.y = view!.center.y
        label.fontName = "TimesNewRomanPS-BoldItalicMT"
        label.fontColor = UIColor.white
        label.run(blinkAnimation()) //runs the blink animation forever

        //add the objects to the scene
        addChild(bg) //set to first so it is in the back of the view
        addChild(movingGround)
        addChild(label)
        addChild(player)
        addChild(movingCieling)
        addChild(asteroid)
        view!.addSubview(pauseButton)
    }//addElementsAndUI
    
    
    //MARK: touches began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        //increment touch counter every time screen is touched
        counter += 1
        //things to do on first touch
        if counter == 1 {
            //adding the physics body here makes it so that the player doesn't automatically drop when the view starts
            player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
            player.physicsBody?.isDynamic = true
            player.physicsBody?.allowsRotation = true
            label.isHidden = true
            asteroid.move()
        }//if
        if counter > 1 {
            player.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        }//if
    }//touches began function
    
    
    //MARK: update
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }//update
    
    
    //MARK: did Begin Contact
    func didBegin(_ contact: SKPhysicsContact) {
        if isHit != true {
            isHit = true
            backgroundMusicPlayer.stop()
            playBackgroundMusic("game_over.mp3")
            sleep(1) //TODO: try to find out why physics gravity and speed don't wait for the timer
            print("A collision occured between two objects")
            physicsWorld.gravity = CGVector.zero
            physicsWorld.speed = 0.0
            pauseButton.titleLabel?.text = "replay"
            
        }//if
    }//didBeginContact
    

    //TODO: find out why segue isn't performing
    //MARK: pause button pressed
    func pauseButtonPressed() {
        if (pause == false && isHit == false) {
            pause = true
            print(physicsWorld.speed) //to find current speed
            physicsWorld.speed = 0.0
            //performSegueWithIdentifier("toMainMenu", sender: self) //not available in SKScene
            pauseButton.setTitle("resume", for: UIControlState())
            print("entered pause, pause var is now:   \(pause)")
        } else if (pause == true && isHit == false) {
            pause = false
            pauseButton.setTitle("pause", for: UIControlState())
            physicsWorld.speed = 1.0 //resumes game
        } else if (pause == false && isHit == true) {
            print("button pressed and is hit is true")
            //causes error
            //self.view!.window!.rootViewController!.performSegueWithIdentifier("toMainMenu", sender: self)
        }
    }//pauseButtonPressed
}//class


//TODO: make an astroid/obstacle class and implement in main game
//TODO: make start screen & barriers less ugly

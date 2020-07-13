//
//  GameScene.swift
//  TweetyTrump
//
//  Created by Kaden Storrs on 7/12/20.
//  Copyright © 2020 Kaden Storrs. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var tweet: Tweet?
    let tweetController: TrumpTweetController = TrumpTweetNetworkController()
    
    var gameStarted = Bool(false)
    var died = Bool(false)
    
    var score = Int(0)
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    
    var tweetBackground = SKSpriteNode()
    var tweetUsertext = SKLabelNode()
    var tweetText = SKLabelNode()
    var tweetImage = SKSpriteNode()
    
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    
    let trumpAtlas = SKTextureAtlas(named: "player")
    
    var trumpSprites = Array<SKTexture>()
    var flappyTrump = SKSpriteNode()
    var repeatActionTrump = SKAction()
    
    override func didMove(to view: SKView) {
        createScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false{
            gameStarted =  true
            flappyTrump.physicsBody?.affectedByGravity = true
            createPauseBtn()
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
            self.flappyTrump.run(repeatActionTrump)
            
            let spawn = SKAction.run({
                () in
                self.wallPair = self.createWalls()
                self.addChild(self.wallPair)
            })
            
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            flappyTrump.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            flappyTrump.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            
        } else {
            
            if died == false {
                flappyTrump.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                flappyTrump.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            }
        }
        
        for touch in touches{
            let location = touch.location(in: self)
            if died == true {
                if restartBtn.contains(location){
                    if UserDefaults.standard.object(forKey: "highestScore") != nil {
                        let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                        if hscore < Int(scoreLbl.text!)!{
                            UserDefaults.standard.set(scoreLbl.text, forKey: "highestScore")
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: "highestScore")
                    }
                    restartScene()
                }
            } else {
                if pauseBtn.contains(location){
                    if self.isPaused == false{
                        self.isPaused = true
                        pauseBtn.texture = SKTexture(imageNamed: "play")
                    } else {
                        self.isPaused = false
                        pauseBtn.texture = SKTexture(imageNamed: "pause")
                    }
                }
            }
        }
    }
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    
    
    func createScene(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.trumpMask
        self.physicsBody?.contactTestBitMask = CollisionBitMask.trumpMask
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "blackScreen")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        trumpSprites.append(SKTexture(imageNamed: "TrumpMask"))
        
    
        self.flappyTrump = createTrump()
        self.addChild(flappyTrump)
        
        
        let animatebird = SKAction.animate(with: self.trumpSprites, timePerFrame: 0.1)
        self.repeatActionTrump = SKAction.repeatForever(animatebird)
        
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.trumpMask && secondBody.categoryBitMask == CollisionBitMask.pillarCategory || firstBody.categoryBitMask == CollisionBitMask.pillarCategory && secondBody.categoryBitMask == CollisionBitMask.trumpMask || firstBody.categoryBitMask == CollisionBitMask.trumpMask && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.trumpMask{
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if died == false{
                died = true
                createRestartBtn()
                pauseBtn.removeFromParent()
                self.flappyTrump.removeAllActions()
            }
        } else if firstBody.categoryBitMask == CollisionBitMask.trumpMask && secondBody.categoryBitMask == CollisionBitMask.kimCoinMask {
            
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.kimCoinMask && secondBody.categoryBitMask == CollisionBitMask.trumpMask {
            
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {

        if gameStarted == true{
            if died == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
                    }
                }))
            }
        }
    }
}


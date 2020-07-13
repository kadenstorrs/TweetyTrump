//
//  GameElements.swift
//  TweetyTrump
//
//  Created by Kaden Storrs on 7/12/20.
//  Copyright © 2020 Kaden Storrs. All rights reserved.
//

import Foundation
import SpriteKit

struct CollisionBitMask {
    static let trumpMask:UInt32 = 0x1 << 0
    static let pillarCategory:UInt32 = 0x1 << 1
    static let kimCoinMask:UInt32 = 0x1 << 2
    static let groundCategory:UInt32 = 0x1 << 3
}

extension GameScene{
    func createTrump() -> SKSpriteNode {
        let trump = SKSpriteNode(texture: SKTextureAtlas(named:"player").textureNamed("TweetyTrump"))
        trump.size = CGSize(width: 60, height: 60)
        trump.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        
        trump.physicsBody = SKPhysicsBody(circleOfRadius: trump.size.width / 2)
        trump.physicsBody?.linearDamping = 1.1
        trump.physicsBody?.restitution = 0
        trump.physicsBody?.categoryBitMask = CollisionBitMask.trumpMask
        trump.physicsBody?.collisionBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.groundCategory
        trump.physicsBody?.contactTestBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.kimCoinMask | CollisionBitMask.groundCategory
        trump.physicsBody?.affectedByGravity = false
        trump.physicsBody?.isDynamic = true
        
        return trump
    }
    
    func createRestartBtn() {
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:100, height:100)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createPauseBtn() {
        pauseBtn = SKSpriteNode(imageNamed: "pause")
        pauseBtn.size = CGSize(width:40, height:40)
        pauseBtn.position = CGPoint(x: self.frame.width - 30, y: 30)
        pauseBtn.zPosition = 6
        self.addChild(pauseBtn)
    }
    
    func createScoreLabel() -> SKLabelNode {
        let scoreLbl = SKLabelNode()
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.6)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 50
        scoreLbl.fontName = "HelveticaNeue-Bold"
        
        let scoreBg = SKShapeNode()
        scoreBg.position = CGPoint(x: 0, y: 0)
        scoreBg.path = CGPath(roundedRect: CGRect(x: CGFloat(-50), y: CGFloat(-30), width: CGFloat(100), height: CGFloat(100)), cornerWidth: 50, cornerHeight: 50, transform: nil)
        let scoreBgColor = UIColor(red: CGFloat(0.0 / 255.0), green: CGFloat(0.0 / 255.0), blue: CGFloat(0.0 / 255.0), alpha: CGFloat(0.2))
        scoreBg.strokeColor = UIColor.clear
        scoreBg.fillColor = scoreBgColor
        scoreBg.zPosition = -1
        scoreLbl.addChild(scoreBg)
        return scoreLbl
    }
    
    func createHighscoreLabel() -> SKLabelNode {
        let highscoreLbl = SKLabelNode()
        highscoreLbl.position = CGPoint(x: self.frame.width - 80, y: self.frame.height - 22)
        if let highestScore = UserDefaults.standard.object(forKey: "highestScore"){
            highscoreLbl.text = "Highest Score: \(highestScore)"
        } else {
            highscoreLbl.text = "Highest Score: 0"
        }
        
        highscoreLbl.zPosition = 5
        highscoreLbl.fontSize = 15
        highscoreLbl.fontName = "Helvetica-Bold"
        return highscoreLbl
    }
    
    func createLogo() {
        logoImg = SKSpriteNode()
        logoImg = SKSpriteNode(imageNamed: "logo")
        logoImg.size = CGSize(width: 150, height: 150)
        logoImg.position = CGPoint(x: self.frame.midX, y:self.frame.midY)
        logoImg.setScale(0.5)
        self.addChild(logoImg)
        logoImg.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createTaptoplayLabel() -> SKLabelNode {
        let taptoplayLbl = SKLabelNode()
        taptoplayLbl.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 100)
        taptoplayLbl.text = "Tap anywhere to play"
        taptoplayLbl.fontColor = .orange
        taptoplayLbl.fontSize = 35
        taptoplayLbl.zPosition = 5
        return taptoplayLbl
    }
    
    func createWalls() -> SKNode  {
        let tweetCoin = SKSpriteNode(imageNamed: "BlueTrumpCoin")
        tweetCoin.size = CGSize(width: 40, height: 40)
        tweetCoin.position = CGPoint(x: self.frame.width + 20, y: self.frame.height / 2)
        tweetCoin.physicsBody = SKPhysicsBody(rectangleOf: tweetCoin.size)
        tweetCoin.physicsBody?.affectedByGravity = false
        tweetCoin.physicsBody?.isDynamic = false
        tweetCoin.physicsBody?.categoryBitMask = CollisionBitMask.kimCoinMask
        tweetCoin.physicsBody?.collisionBitMask = 0
        tweetCoin.physicsBody?.contactTestBitMask = CollisionBitMask.trumpMask
        tweetCoin.color = SKColor.blue
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "pillar")
        let btmWall = SKSpriteNode(imageNamed: "pillar")
        
        topWall.position = CGPoint(x: self.frame.width + 50, y: self.frame.height / 2 + 325)
        btmWall.position = CGPoint(x: self.frame.width + 50, y: self.frame.height / 2 - 325)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody =
            SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = CollisionBitMask.pillarCategory
        topWall.physicsBody?.collisionBitMask = CollisionBitMask.trumpMask
        topWall.physicsBody?.contactTestBitMask = CollisionBitMask.trumpMask
        
        
        topWall.physicsBody?.isDynamic = true
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = CollisionBitMask.pillarCategory
        btmWall.physicsBody?.collisionBitMask = CollisionBitMask.trumpMask
        btmWall.physicsBody?.contactTestBitMask = CollisionBitMask.trumpMask
        
        
        btmWall.physicsBody?.isDynamic = true
        btmWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(Double.pi)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y +  randomPosition
        wallPair.addChild(tweetCoin)
        
        wallPair.run(moveAndRemove)
        
        return wallPair
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 4294967296)
    }
    
    func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }

}

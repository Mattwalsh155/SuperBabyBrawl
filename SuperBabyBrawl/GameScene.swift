import SpriteKit
import GameplayKit
import CoreMotion

protocol EventListenerNode {
    func didMoveToScene()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var isJumping = false
    
    let playerMovePointsPerSecond: CGFloat = 300.0
    
    var velocity = CGPoint.zero
    
    let player = SKSpriteNode(imageNamed: "baby400_backward0")
    
    let joystickBase = SKSpriteNode(imageNamed: "joystickBase")
    let joystickBall = SKSpriteNode(imageNamed: "joystickBall")
    let radiansOf90Deg: CGFloat = 1.57
    var moveSpeed: CGFloat = 100
    var joystickNeeded: Bool = true
    var joystickActive: Bool = false
    var joystickAutoCenter: Bool = true
    var joystickSpeed: CGFloat = -0.002
    let motionManager = CMMotionManager()
    var xAcceleration = CGFloat(0)
    var yAcceleration = CGFloat(0)
    //var player: Player!
    
    let buttonA = SKSpriteNode(imageNamed: "joystickBall")
    let buttonB = SKSpriteNode(imageNamed: "joystickBall")
    
    var bHit: Bool = false
    var aHit: Bool = false
    
    private var imp : SKNode?
    var currentLevel: Int = 0

    
    override func didMove(to view: SKView) {
        view.showsPhysics = true
        view.showsNodeCount = true
        setupJoystick()
        setupButton()
        //calculate playable margin
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = ((size.height + 175) - maxAspectRatioHeight)/2
        let playableRect = CGRect(x: 0,
                                  y: playableMargin,
                                  width: size.width,
                                  height: size.height - playableMargin * 2)
        moveSpeed = size.width/15
        physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
        
        player.position = CGPoint(x: size.width/4,
                                  y: size.height/2)
        player.setScale(0.3)
        player.physicsBody = SKPhysicsBody(texture: player.texture!,
                                           size: player.size)
        player.physicsBody!.allowsRotation = false
        addChild(player)
        //PlayerNode = childNode(withName: "player") as? playerNode
        //physicsWorld.contactDelegate = self
        //scene?.physicsBody = SKPhysicsBody(edgeLoopFrom: scene!.frame)
        
        enumerateChildNodes(withName: "//*", using: { node, _ in
            if let eventListenerNode = node as? EventListenerNode {
                eventListenerNode.didMoveToScene()
            }
        })
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        //move(sprite: player, velocity: velocity)
        if player != nil{
            //print("\(player.position.x)")
            player.position = CGPoint(x: player.position.x + xAcceleration * moveSpeed,
                                      y: player.position.y )
            if(xAcceleration <= 0){
                //player.xScale = 1
            } else {
                //player.xScale = -1
            }
        }
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            //if joystickNeeded == true {
            for touch in touches {
                let location = touch.location(in: self)
                
                if(buttonA.frame.contains(location)){
                    aPressed()
                    
                }
                if(buttonB.frame.contains(location)){
                    bPressed()
                }
                if (joystickBall.frame.contains(location)) {
                    joystickActive = true
                } else {
                    joystickActive = false
                }
            }
            //}
        }
        
        func aPressed(){
            //        aHit = true
            //        if(!bHit){
            print("A hit")
            //        }
        }
        
        func bPressed(){
            //        bHit = true
            //        if(!aHit){
            print("B hit")
            //       }
        }
        
        // Add in the touchesMoved method below
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            if joystickNeeded == true {
                for touch in touches {
                    let location = touch.location(in: self)
                    let v = CGVector(dx: location.x - joystickBase.position.x, dy: location.y - joystickBase.position.y)
                    let angle = atan2(v.dy, v.dx)
                    let length: CGFloat = joystickBase.frame.size.height / 2
                    let xDist: CGFloat = sin(angle - radiansOf90Deg) * length
                    let yDist: CGFloat = cos(angle - radiansOf90Deg) * length
                    
                    if (joystickBase.frame.contains(location)) {
                        joystickBall.position = location
                    }
                    //                   else {
                    //                    joystickBall.position = CGPointMake(joystickBase.position.x - xDist, joystickBase.position.y + yDist)
                    //                }
                    
                    xAcceleration = xDist * joystickSpeed
                    yAcceleration = yDist * joystickSpeed
                    if yAcceleration < -0.1 {
                        if !isJumping {
                        jump()
                        }
                    }
                    
                }
            }
        }
    
    func jump() {
        player.physicsBody?.applyImpulse(CGVector(dx: 0,
                                                dy: size.height/2))
        isJumping = true
        print("Jump\(yAcceleration)")
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        
    }
        
        // Add in the touchesEnded method below
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            if joystickNeeded == true {
                if (joystickActive == true && joystickAutoCenter == true)  {
                    let returnToCenter: SKAction = SKAction.move(to: joystickBase.position, duration: 0.2)
                    returnToCenter.timingMode = .easeOut
                    joystickBall.run(returnToCenter)
                    xAcceleration = 0.0
                    yAcceleration = 0.0
                    isJumping = false
                }
            }
        
            aHit = false
            bHit = false
        xAcceleration = 0.0
        yAcceleration = 0.0
        }
        
        func setupButton() {
            
            buttonA.size = CGSize(width: 100, height: 100)
            buttonB.size = CGSize(width: 100, height: 100)
            buttonB.color = SKColor.blue
            buttonB.colorBlendFactor = 1
            buttonA.position = CGPoint(x: size.width * 0.9, y: size.height * 0.2)
            buttonB.position = CGPoint(x: size.width * 0.95, y: size.height * 0.2)
            buttonA.zPosition = 10
            buttonB.zPosition = 10
            
            addChild(buttonA)
            addChild(buttonB)
        }
        
        // Add in the setupJoystick methid below
        func setupJoystick() {
            joystickNeeded = true
            joystickBase.scale(to: CGSize(width: 150, height: 150))
            scene?.addChild(joystickBase)
            let joyPos = CGPoint(x: size.width * 0.2, y: size.height * 0.2)
            joystickBase.position = joyPos
            joystickBase.name = "JoystickBase"
            //
            joystickBase.zPosition = 10
            print("Joystick Added")
            joystickBall.scale(to: CGSize(width: 150, height: 150))
            scene?.addChild(joystickBall)
            joystickBall.position = joystickBase.position
            joystickBall.name = "JoystickBall"
            //
            joystickBall.zPosition = 11
        }

    }
    
//    func move(sprite: SKSpriteNode, velocity: CGPoint) {
//        let velocity = 100
//        let amountToMove = CGPoint(x: velocity,
//                                   y: 0)
//        sprite.position = CGPoint(
//            x: sprite.size.width/2 + amountToMove.x,
//            y: 0)
//    }
//
//    func movePlayerToward(location: CGPoint) {
//        let offset = CGPoint(x: location.x - player.position.x,
//                             y: 0)
//        let length = sqrt(
//        Double(offset.x * offset.x + offset.y * offset.y))
//        let direction = CGPoint(x: offset.x / CGFloat(length),
//                                y: 0)
//        velocity = CGPoint(x: direction.x * playerMovePointsPerSecond,
//                           y: 0)
//    }
//
//    func sceneTouched(touchLocation: CGPoint) {
//        movePlayerToward(location: touchLocation)
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>,
//                               with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
//        let touchLocation = touch.location(in: self)
//        sceneTouched(touchLocation: touchLocation)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>,
//                               with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
//        let touchLocation = touch.location(in: self)
//        sceneTouched(touchLocation: touchLocation)
//    }


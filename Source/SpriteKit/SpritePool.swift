import SpriteKit

class SpritePool {
    let atlas: SKTextureAtlas
    var parkedDrones: [SKSpriteNode]
    let texture: SKTexture

    init(_ atlasName: String, _ textureName: String) {
        self.atlas = SKTextureAtlas(named: atlasName)
        self.texture = atlas.textureNamed(textureName)
        self.parkedDrones = []
    }

    func makeSprite() -> SKSpriteNode {
        let drone = getDrone()
        return makeSprite(with: drone)
    }

    func releaseSprite(_ sprite: SKSpriteNode) {
        sprite.removeAllActions()
        sprite.removeFromParent()
        parkedDrones.append(sprite)
    }
}

private extension SpritePool {

    func getDrone() -> SKSpriteNode {
        if parkedDrones.isEmpty {
            parkedDrones.append(SKSpriteNode(texture: self.texture))
        }

        return parkedDrones.popLast()!
    }

    func makeSprite(with drone: SKSpriteNode) -> SKSpriteNode {
        drone.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        drone.color = .white
        drone.colorBlendFactor = 1
        drone.zPosition = 1
        drone.zRotation = 0
        return drone
    }
}

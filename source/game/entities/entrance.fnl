(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :entrance
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  (fn react! [self map-state]
    (let [roll (math.random 0 800)
          entity self.state.spawn]
      (if (and (<= roll map-state.speed) (= (length (self:overlappingSprites)) 0))
          (let [new-customer (entity.new! self.x self.y {:tile-h self.tile-h :tile-w self.tile-w})]
            (print "Spawned new customer")
            (new-customer:add))
          (<= roll map-state.speed)
          (print "could not spawn another customer")
          ))
    )

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w :layer-details {: spawn }}]
    (let [player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 16 16)
      (player:setCollideRect 0 0 16 16)
      ;; NPCs don't collide with _it_, but detects collisions with npcs
      (player:setGroups [8])
      (player:setCollidesWithGroups [3])
      (tset player :draw draw)
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :react! react!)

      (tset player :state {:facing :down
                           : spawn
                           :tile-x (div x tile-w) :tile-y (div y tile-h)})
      player)))


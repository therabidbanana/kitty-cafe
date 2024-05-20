(import-macros {: inspect : defns} :source.lib.macros)

(defns :entrance
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  (fn react! [self map-state]
    (let [roll (math.random 0 100)
          entity self.state.spawn]
      (if (= roll 1)
          (let [new-customer (entity.new! self.x self.y {:tile-h self.tile-h :tile-w self.tile-w})]
            (print "Spawned new customer")
            (new-customer:add))))
    )

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w :layer-details {: spawn }}]
    (let [player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 16 16)
      ;; (player:setCollideRect 6 1 18 30)
      ;; (player:setCollidesWithGroups [1 4])
      (tset player :draw draw)
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :react! react!)
      (tset player :state {:facing :down
                           : spawn
                           :tile-x (// x tile-w) :tile-y (// y tile-h)})
      player)))


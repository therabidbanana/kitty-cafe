(import-macros {: inspect : defns : div} :source.lib.macros)

;; TODO: rename 'register'
(defns :order
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  (fn interact! [self player]
    (let [facing-x (+ self.x (div self.width 2))
          facing-y (+ self.y (+ self.height 8))
          [facing-sprite & _] (icollect [_ spr (ipairs (gfx.sprite.querySpritesAtPoint facing-x facing-y))]
                                (if (?. spr :interact!) spr nil))]
      (if facing-sprite
          (facing-sprite:interact! player)
          )
      ))

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w}]
    (let [player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 16 16)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 0 0 16 16)
      (player:setGroups [2])
      ;; (player:setCollidesWithGroups [1 4])
      (tset player :draw draw)
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :interact! interact!)
      (tset player :state {:facing :down
                           :tile-x (div x tile-w) :tile-y (div y tile-h)})
      player)))


(import-macros {: inspect : defns} :source.lib.macros)

(defns :npc
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   anim (require :source.lib.animation)

   sprite-count 6
   dirs {:down 0
         :up (* 1 sprite-count)
         :left (* 3 sprite-count)
         :right (* 2 sprite-count)}
   ]

  (fn react! [{: state : height : x : y : tile-w : tile-h : width &as self}]
    
    (let [(dx dy) (self:tile-movement-react! state.speed)]
      (if (and (= dx 0) (= dy 0))
          (case (math.random 0 100)
            1 (self:->left!)
            2 (self:->right!)
            3 (self:->up!)
            4 (self:->down!)
            _ nil))
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))
      )
    self)

  (fn update [{:state {: animation : dx : dy : walking? &as state} &as self}]
    (let [target-x (+ dx self.x)
          target-y (+ dy self.y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)]
      (if walking?
          (animation:transition! (.. state.facing "." :walking ))
          (animation:transition! (.. state.facing "." :standing)
                                 {:if (.. state.facing "." :walking)}))
      (tset self :state :dx 0)
      (tset self :state :dy 0)
      (if (> count 0) (self:->stop!))
      (self:markDirty))
    )

  (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
    (animation:draw x y))

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w}]
    (let [image (gfx.imagetable.new :assets/images/patron1)
          animation (anim.new {: image :states [
          {:state :down.standing
           :start (+ 1 dirs.down) :end (+ 1 dirs.down)
           :delay 2300 :transition-to :down.blinking}
          {:state :down.blinking
           :start (+ 3 dirs.down) :end (+ 3 dirs.down)
           :delay 300 :transition-to :down.pace}
          {:state :down.pace
           :start (+ 1 dirs.down) :end (+ 2 dirs.down)
           :delay 500 :transition-to :down.standing}
          {:state :down.walking
           :start (+ 4 dirs.down) :end (+ 6 dirs.down)}
          {:state :up.standing
           :start (+ 1 dirs.up) :end (+ 1 dirs.up)
           :delay 2300 :transition-to :up.blinking}
          {:state :up.blinking
           :start (+ 3 dirs.up) :end (+ 3 dirs.up)
           :delay 300 :transition-to :up.pace}
          {:state :up.pace
           :start (+ 1 dirs.up) :end (+ 2 dirs.up)
           :delay 500 :transition-to :up.standing}
          {:state :up.walking
           :start (+ 4 dirs.up) :end (+ 6 dirs.up)}
          {:state :left.standing
           :start (+ 1 dirs.left) :end (+ 1 dirs.left)
           :delay 2300 :transition-to :left.blinking}
          {:state :left.blinking
           :start (+ 3 dirs.left) :end (+ 3 dirs.left)
           :delay 300 :transition-to :left.pace}
          {:state :left.pace
           :start (+ 1 dirs.left) :end (+ 2 dirs.left)
           :delay 500 :transition-to :left.standing}
          {:state :left.walking
           :start (+ 4 dirs.left) :end (+ 6 dirs.left)}
          {:state :right.standing
           :start (+ 1 dirs.right) :end (+ 1 dirs.right)
           :delay 2300 :transition-to :right.blinking}
          {:state :right.blinking
           :start (+ 3 dirs.right) :end (+ 3 dirs.right)
           :delay 300 :transition-to :right.pace}
          {:state :right.pace
           :start (+ 1 dirs.right) :end (+ 2 dirs.right)
           :delay 500 :transition-to :right.standing}
          {:state :right.walking
           :start (+ 4 dirs.right) :end (+ 6 dirs.right)}
                                                ]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 32 32)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 0 0 32 32)
      (player:setGroups [3])
      (player:setCollidesWithGroups [1 4])
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :state {: animation :speed 2 :dx 0 :dy 0 :visible true
                           :facing :down
                           :tile-x (// x tile-w) :tile-y (// y tile-h)})
      (tile.add! player {: tile-h : tile-w})
      player)))


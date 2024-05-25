(import-macros {: inspect : defns} :source.lib.macros)

(defns :player
  [pressed? playdate.buttonIsPressed
   justpressed? playdate.buttonJustPressed
   gfx playdate.graphics
   $ui (require :source.lib.ui)
   tile (require :source.lib.behaviors.tile-movement)
   scene-manager (require :source.lib.scene-manager)
   anim (require :source.lib.animation)
   sprite-count 6
   dirs {:down 0
         :up (* 1 sprite-count)
         :left (* 3 sprite-count)
         :right (* 2 sprite-count)}
   ]

  (fn react! [{: state : height : x : y : width &as self} map-state]
    (if state.walking? nil
        (pressed? playdate.kButtonLeft) (self:->left!)
        (pressed? playdate.kButtonRight) (self:->right!)
        (pressed? playdate.kButtonUp) (self:->up!)
        (pressed? playdate.kButtonDown) (self:->down!))
    (let [(dx dy) (self:tile-movement-react! (* map-state.speed state.speed))
          ;; Leave screen
          ;; dx (if (and (>= (+ x width) 400) (> dx 0)) 0
          ;;        (and (<= x 0) (< dx 0)) 0
          ;;        dx)
          ;; dy (if (and (>= (+ y height) 240) (> dy 0)) 0
          ;;        (and (<= y 0) (< dy 0)) 0
          ;;        dy)
          [facing-x facing-y] (case state.facing
                                :left [(- x 3) (+ y 19)]
                                :right [(+ 3 width x) (+ y 19)]
                                :up [(+ x 13) (- y 3)]
                                _ [(+ x 13) (+ 3 height y)]) ;; 6x6 square near center mass
          [facing-sprite & _] (icollect [_ spr (ipairs (gfx.sprite.querySpritesInRect facing-x facing-y 6 6))]
                                (if (?. spr :interact!) spr nil))
          ]
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))

      ;; (if (playdate.buttonJustPressed playdate.kButtonB)
      ;;     (scene-manager:select! :menu))
      (if (and (playdate.buttonJustPressed playdate.kButtonA)
               facing-sprite)
          (facing-sprite:interact! self)
          )
      )
    self)

  (fn update [{:state {: animation : dx : dy : walking? &as state} &as self}]
    (let [target-x (+ dx self.x)
          target-y (+ dy self.y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)]
      (if walking?
         (animation:transition! (.. state.facing "." :walking ))
         (animation:transition! (.. state.facing "." :standing)
                                {:if (.. state.facing "." :walking)})))
    (self:markDirty)
    )

  (fn take-held [{:state {: holding} &as self}]
    (tset self :state :holding nil)
    holding)

  (fn pay! [{:state {: cash} &as self} paid]
    (tset self :state :cash (+ (or cash 0) paid))
    )

  (fn hold-item! [{:state {: holding} &as self} item]
    (tset self :state :holding item))

  (fn modify-item! [{:state {: holding} &as self} modifier]
    (let [modifiers (or (?. holding :modifiers) [])
          _ (table.insert modifiers modifier)]
      (tset self :state :holding :modifiers modifiers)))

  (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
    (animation:draw x y))

  (fn collisionResponse [self other]
    (other:collisionResponse))

  (fn new! [x y {: tile-w : tile-h :layer-details { : name}}]
    (let [image (gfx.imagetable.new :assets/images/princess)
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
      (player:setCollideRect 0 16 32 16)
      (player:setGroups [1])
      (player:setCollidesWithGroups [3 4])
      (player:setZIndex 1)
      (tset player :draw draw)
      (tset player :pay! pay!)
      (tset player :player? true)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :take-held take-held)
      (tset player :hold-item! hold-item!)
      (tset player :modify-item! modify-item!)
      (tset player :state {: name :facing :down : animation :speed 2 :dx 0 :dy 0 :visible true :cash 0})
      (tile.add! player {: tile-h : tile-w})
      player)))


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

  (fn plan-next-step [state {: graph : graph-locations : grid-w}]
    (let [goal (case state.state
                 :order (?. graph-locations :wait)
                 :leave (?. graph-locations :exit)
                 _ nil)
          ;; TODO: XY on nodes seems +1 each way. coords 1 based?
          curr (if goal (graph:nodeWithID (+ (* grid-w state.tile-y) (+ state.tile-x 1))))
          ;; curr (if goal (graph:nodeWithXY (+ (inspect state.tile-y) 1) (+ (inspect state.tile-x) 1)))
          path (if curr (graph:findPath curr goal))
          ;; _ (inspect {:x curr.x :y curr.y})
          ;; _ (inspect (curr:connectedNodes))
          ;; _ (inspect path)
          next-step (?. path 2)]
      (if
       (and (= (?. curr :x) (?. goal :x)) (= (?. curr :y) (?. goal :y))) :at-goal
       (= (type next-step) "nil") :pause
       (< (- next-step.y 1) state.tile-y) :up
       (> (- next-step.x 1) state.tile-x) :right
       (< (- next-step.x 1) state.tile-x) :left
       (> (- next-step.y 1) state.tile-y) :down
       :pause)))

  (fn transition! [{: state &as self} new-state]
    (print (.. "Changing state to " new-state))
    (tset state :state new-state)
    (if (= :leave new-state)
        (do
          ;; No more colliding with the line
          (self:setGroups [1])
          (self:setCollidesWithGroups [1])))
    )

  (fn react! [{: state : height : x : y : tile-w : tile-h : width &as self} map-state]
    (if (= state.state :exit)
        (do
          (self:remove))
        (let [(dx dy) (self:tile-movement-react! state.speed)
              do-next (if (and (= dx 0) (= dy 0) (<= state.pause-ticks 0))
                          (plan-next-step state map-state))
              ]
          (case do-next
            :up (self:->up!)
            :down (self:->down!)
            :left (self:->left!)
            :right (self:->right!)
            :at-goal (case state.state
                       :order (self:transition! :wait)
                       :leave (self:transition! :exit))
            :pause (tset self :state :pause-ticks (+ state.pause-ticks 100)))
          (tset self :state :dx dx)
          (tset self :state :dy dy)
          (if (> state.pause-ticks 0)
              (tset self :state :pause-ticks (math.max (- (or state.pause-ticks 0) 1) 0)))
          (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))
          ))
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

  (fn generate-order []
    [{:item :milk
      :modifiers []}])

  (fn match-to-order [order held]
    (?. (icollect [k v (ipairs order)]
          (if (and (= (?. v :item) (?. held :item))) k))
        1))

  (fn takes-item-from? [self player]
    (let [order self.state.cafe-order
          held  player.state.holding
          index (match-to-order order held)]
      index)
    )

  (fn take-item-from! [self player]
    (let [index (self:takes-item-from? player)]
      (if index
          (do (player:take-held)
              (table.remove self.state.cafe-order index)
              (if (= (length self.state.cafe-order) 0) (self:transition! :leave))
              ))

      ))

  (fn interact! [self player]
    (let [order self.state.cafe-order
          hold  player.state.holding]
      (if (self:takes-item-from? player)
          (let [taken (self:take-item-from! player)]
            (if (= (type (next self.state.cafe-order)) "nil")
                ($ui:open-textbox! {:text "Thanks! Have a nice day!"})
                ($ui:open-textbox! {:text "Thanks! I'm still waiting for..."})
                )
            )
          hold
          ($ui:open-textbox! {:text "I don't think that's what I ordered."})
          (= self.state.state :leave)
          ($ui:open-textbox! {:text "I'm just standing here because I can't walk away yet."})
          ;;
          ($ui:open-textbox! {:text "I'm waiting for milk."})
          )
      )
    )

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
      (player:setCollideRect 0 16 32 16)
      (player:setGroups [3])
      (player:setCollidesWithGroups [3])
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :interact! interact!)
      (tset player :transition! transition!)
      (tset player :takes-item-from? takes-item-from?)
      (tset player :take-item-from! take-item-from!)
      (tset player :state {: animation :speed 2 :dx 0 :dy 0 :visible true
                           :cafe-order (generate-order)
                           :pause-ticks 0
                           :facing :down
                           :state :order
                           :patience 10
                           :tile-x (// x tile-w) :tile-y (// y tile-h)})
      (tile.add! player {: tile-h : tile-w})
      player)))


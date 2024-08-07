(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :npc
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   anim (require :source.lib.animation)
   order_helper (require :source.game.order_helper)

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
          ;; No more colliding with others in line
          (self:setGroups [8])
          (self:setCollidesWithGroups [1])))
    )

  (fn react! [{: state : height : x : y : tile-w : tile-h : width &as self} map-state]
    (if (= state.state :exit)
        (do
          (self:remove))
        (let [(dx dy) (self:tile-movement-react! (* map-state.speed state.speed))
              ;; Leave if fed up
              _ (if (and (= state.state :order) (< state.patience 0))
                    (do
                      (self:transition! :leave)))
              do-next (if (and (= dx 0) (= dy 0) (<= state.pause-ticks 0))
                          (plan-next-step state map-state))
              ]
          (case do-next
            :up (self:->up!)
            :down (self:->down!)
            :left (self:->left!)
            :right (self:->right!)
            :at-goal (case state.state
                       :order (do (self:transition! :wait)
                                  (self:face-forward!))
                       :leave (self:transition! :exit))
            :pause (tset self :state :pause-ticks (+ state.pause-ticks 100)))
          (tset self :state :dx dx)
          (tset self :state :dy dy)
          (tset self :state :map-speed map-state.speed)
          (if (> state.pause-ticks 0)
              (tset self :state :pause-ticks (math.max (- (or state.pause-ticks 0) 1) 0)))
          (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))
          ))
    self)

  (fn face-forward! [{:state {: animation : dx : dy : walking? &as state} &as self}]
    (self:->face! :up)
    (animation:transition! (.. :up "." :standing)))

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
      (if (> count 0) ;; Forced to stop
          (let [patience (or state.patience 10)
                pause-ticks (or state.pause-ticks 0)
                new-patience (if
                              (<= patience state.map-speed)
                              (- patience 1)
                              (<= (math.random 1 patience) state.map-speed)
                              (- patience 1)
                              patience)]
            (tset self :state :patience new-patience)
            (if (< patience 1)
                (tset self :state :pause-ticks 8)
                (tset self :state :pause-ticks (* new-patience (math.random 7 12))))
            (self:->stop!)))
      (self:markDirty))
    )

  (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
    (animation:draw x y))

  (fn generate-order []
    (order_helper.generate-order)
    )

  (fn match-to-order [order held]
    (?. (icollect [k v (ipairs order)]
          (if (and held (order_helper.same-item? v held)) k))
        1))

  (fn value-of-item [item]
    ;; Guaranteed random
    (order_helper.item-value item))

  (fn takes-item-from? [self player]
    (let [order self.state.cafe-order
          held  player.state.holding
          index (match-to-order order held)
          value (if index (value-of-item held))]
      (values index value))
    )

  (fn payment-owed [self]
    (let [owed (or self.state.owes 0)
          tip  (math.random 0 2)]
      (+ owed tip)))

  (fn take-item-from! [self player]
    (let [(index value) (self:takes-item-from? player)]
      (when index
        (player:take-held)
        (tset self.state :owes (+ value (or self.state.owes 0)))
        (table.remove self.state.cafe-order index)
        (when (= (length self.state.cafe-order) 0)
          (player:pay! (payment-owed self))
          (self:transition! :leave)
          ))
      ))

  (fn interact! [self player]
    (let [order self.state.cafe-order
          hold  player.state.holding
          sounds self.state.sounds
          in-stock? (player:can-fulfill? order)]
      (if (self:takes-item-from? player)
          (let [taken (self:take-item-from! player)]
            (if (= (type (next self.state.cafe-order)) "nil")
                (do
                  (sounds.thank-you:play)
                  ($ui:open-textbox! {:text "Thanks! Have a nice day!"}))
                ($ui:open-textbox! {:text (.. "Thanks! I'm still waiting for... "
                                              (order_helper.describe-items self.state.cafe-order))})
                )
            )
          hold
          ($ui:open-textbox! {:text "I don't think that's what I ordered."})
          (= self.state.state :leave)
          ($ui:open-textbox! {:text "I'm just standing here because I can't walk away yet [bug]."})
          (if in-stock?
              (do
                (sounds.can-i-order:play)
                ($ui:open-textbox! {:text (.. "Can I get... "
                                              (order_helper.describe-items self.state.cafe-order)
                                              "?")
                                    :action #($ui:open-textbox! {:nametag player.state.name :text "Sure thing!"})
                                    }))
              (do
                (sounds.can-i-order:play)
                ($ui:open-textbox! {:text (.. "Can I get... "
                                             (order_helper.describe-items self.state.cafe-order)
                                             "?")
                                   :action #($ui:open-textbox! {:nametag player.state.name :text "Sorry, we're out!"
                                                                :action (fn [] (self:transition! :leave))})})))
          )
      )
    )

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w }]
    (let [patron (case (math.random 1 2)
                   1 :patron1
                   _ :patron2)
          image (case (math.random 1 2)
                  1 (gfx.imagetable.new (.. :assets/images/ patron))
                  _ (gfx.imagetable.new (.. :assets/images/ patron)))
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
      (tset player :face-forward! face-forward!)
      (tset player :takes-item-from? takes-item-from?)
      (tset player :take-item-from! take-item-from!)
      (tset player :state {: animation :speed 2 :dx 0 :dy 0 :visible true
                           :cafe-order (generate-order)
                           :sounds {:thank-you (playdate.sound.sampleplayer.new (.. :assets/sounds/thank-you- patron))
                                    :can-i-order (playdate.sound.sampleplayer.new (.. :assets/sounds/can-i-order- patron))}
                           :pause-ticks 0
                           :facing :down
                           :state :order
                           :patience (math.random 9 18)
                           :tile-x (div x tile-w) :tile-y (div y tile-h)})
      (tile.add! player {: tile-h : tile-w})
      player)))


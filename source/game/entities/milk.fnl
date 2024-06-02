(import-macros {: inspect : defns} :source.lib.macros)

(defns :milk
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   anim (require :source.lib.animation)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  (fn react! [{: state &as self} scene-state map-state]
    (let [milk-stock (or (?. map-state :stock :milk) 0)]
      (if (>= milk-stock 80)
          (state.animation:transition! :100)
          (>= milk-stock 40)
          (state.animation:transition! :50)
          (>= milk-stock 1)
          (state.animation:transition! :20)
          (state.animation:transition! :0))
      )
    self)

  (fn update [self]
    (self:markDirty))

  (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
    (animation:draw x y))

  (fn interact! [self player]
    (if player.state.holding
        ($ui:open-textbox! {:nametag player.state.name
                            :text "I need to put down what I'm holding first."})
        (do
          (if (player:hold-item! {:item :milk})
              ($ui:open-textbox! {:nametag player.state.name
                                  :text "Grabbed milk."})
              ($ui:open-textbox! {:nametag player.state.name
                                  :text "I'm out of that."}))
          )
        )
    )

  (fn new! [x y {: tile-h : tile-w}]
    (let [image (gfx.imagetable.new (.. :assets/images/fridge))
          animation (anim.new {: image :states [
                                                {:state :100
                                                 :start 1 :end 1}
                                                {:state :50
                                                 :start 2 :end 2}
                                                {:state :20
                                                 :start 3 :end 3}
          {:state :0
           :start 4 :end 4}
          ]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 32 32)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 0 0 32 32)
      (player:setGroups [2])
      ;; (player:setCollidesWithGroups [1 4])
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :interact! interact!)
      (tset player :state {: animation
                           :tile-x (// x tile-w) :tile-y (// y tile-h)})
      player)))


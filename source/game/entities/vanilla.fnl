(import-macros {: inspect : defns} :source.lib.macros)

(defns chocolate
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   anim (require :source.lib.animation)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  (fn react! [{: state &as self} scene-state map-state]
    (let [stock (or (?. map-state :stock :vanilla) 0)]
      (if (>= stock 1)
          (state.animation:transition! :present)
          (state.animation:transition! :empty))
      )
    self)

  (fn update [self]
    (self:markDirty))

  (fn draw [{:state {: animation } &as self} x y w h]
    (animation:draw x y))

  (fn interact! [self player]
    (if player.state.holding
        (do
          (if (player:modify-item! :vanilla)
              ($ui:open-textbox! {:nametag player.state.name
                                  :text "Added a pump of vanilla."})
              ($ui:open-textbox! {:nametag player.state.name
                                  :text "I'm out of vanilla."})
              )
          )
        ($ui:open-textbox! {:nametag player.state.name
                            :text "I'm not holding anything yet."}))
    )

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w}]
    (let [image (gfx.imagetable.new (.. :assets/images/vanilla))
          animation (anim.new {: image :states [{:state :empty
                                                 :start 1 :end 1}
                                                {:state :present
                                                 :start 2 :end 2}]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 16 16)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 16 8 8 8)
      (player:setGroups [4])
      ;; (player:setCollidesWithGroups [1 4])
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :interact! interact!)
      (tset player :state {: animation :facing :down
                           :tile-x (// x tile-w) :tile-y (// y tile-h)})
      player)))

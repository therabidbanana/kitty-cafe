(import-macros {: inspect : defns} :source.lib.macros)

(defns :sandwich_window
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   anim (require :source.lib.animation)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  (fn react! [{: state &as self} scene-state map-state]
    (let [stock (or (?. map-state :stock :tuna-sandwich) 0)]
      (if (>= stock 1)
          (state.animation:transition! :present)
          (state.animation:transition! :empty))
      )
    self)

  (fn update [self]
    (self:markDirty))

  (fn draw [{:state {: animation } &as self} x y w h]
    (animation:draw x y))

  (fn new! [x y {: tile-h : tile-w}]
    (let [image (gfx.imagetable.new (.. :assets/images/sandwich_window))
          animation (anim.new {: image :states [{:state :empty
                                                 :start 1 :end 1}
                                                {:state :present
                                                 :start 2 :end 2}]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 16 16)
      (player:setZIndex 10)
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :state {: animation })
      player)))

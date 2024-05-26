(import-macros {: inspect : defns} :source.lib.macros)

(defns :hud
  [gfx playdate.graphics
   $ui (require :source.lib.ui)
   anim (require :source.lib.animation)
   order_helper (require :source.game.order_helper)
   ]

  (fn react! [{:state { : player &as state} &as self}]
    (let [player-held (?. player :state :holding)
          player-held (if player-held (order_helper.describe-item player-held))]
      (when (not= player-held state.player-held)
        (tset state :player-held player-held)
        (tset state :dirty true)
        )
      )
    self)

  (fn draw [self]
    (let [heldrect (playdate.geometry.rect.new 0 0
                                               260 14)]
      (when self.state.player-held
          (gfx.setColor gfx.kColorWhite)
          (gfx.fillRoundRect heldrect 4)
          (gfx.setLineWidth 2)
          (gfx.setColor gfx.kColorBlack)
          (gfx.drawRoundRect heldrect 4)
          (gfx.setColor gfx.kColorBlack)
          (self.tagFont:drawText (.. "Held: " self.state.player-held)
                        6 2
                        ))
      )

    )

  (fn update [{:state {: animation : dx : dy : walking? &as state} &as self}]
    (when self.state.dirty
      (tset self.state :dirty nil)
      (self:markDirty)
      )
    )

  (fn new! [player]
    (let [hud (gfx.sprite.new)]
      (hud:moveTo 60 220)
      (hud:setSize 260 20)
      (hud:setCenter 0 0)
      (hud:setZIndex 1000)
      (tset hud :tagFont (gfx.font.new :assets/fonts/Nontendo-Bold))
      (tset hud :state {: player})
      (tset hud :draw draw)
      (tset hud :update update)
      (tset hud :react! react!)
      hud)))

(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :hud
  [gfx playdate.graphics
   $ui (require :source.lib.ui)
   anim (require :source.lib.animation)
   ]

  (fn react! [{:state { : level &as state} &as self}]
    (let [minutes (div (?. level :state :seconds) 60)
          minutes (+ minutes 420)] ;; day starts at 7
      (when (not= minutes state.minutes)
        (tset state :minutes minutes)
        (tset state :speed level.state.speed)
        (tset state :dirty true)
        )
      )
    self)

  (fn draw [self]
    (gfx.setColor gfx.kColorWhite)
    (let [mode (playdate.graphics.getImageDrawMode)]
      (playdate.graphics.setImageDrawMode "fillWhite")
      (self.tagFont:drawText (.. (string.format "%02d" (div self.state.minutes 60)) " : "
                                 (string.format "%02d" (% self.state.minutes 60))
                                 (if (> self.state.minutes 720) "pm" "am")
                                 )
                             0 2
                             )
      (gfx.setColor gfx.kColorWhite)
      (gfx.fillRoundRect 6 14 24 14 2)
      (gfx.setLineWidth 1)
      (gfx.setColor gfx.kColorBlack)
      (gfx.drawRoundRect 6 14 24 14 2)
      (playdate.graphics.setImageDrawMode "fillBlack")
      (self.tagFont:drawText (.. "x" (string.format "%d" self.state.speed))
                             8 16
                             )
      (playdate.graphics.setImageDrawMode mode)
      )
    

    )

  (fn update [{:state {: animation : dx : dy : walking? &as state} &as self}]
    (when self.state.dirty
      (tset self.state :dirty nil)
      (self:markDirty)
      )
    )

  (fn new! [level]
    (let [hud (gfx.sprite.new)]
      (hud:setCenter 0 0)
      (hud:setSize 50 60)
      (hud:moveTo 340 0)
      (hud:setZIndex 1001)
      (tset hud :tagFont (gfx.font.new :assets/fonts/Nontendo-Bold))
      (tset hud :state {: level :minutes 0 :speed 1})
      (tset hud :draw draw)
      (tset hud :update update)
      (tset hud :react! react!)
      hud)))

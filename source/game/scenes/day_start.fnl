(import-macros {: inspect : defns} :source.lib.macros)

(defns day-start
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})
  (fn enter! [$ game-state]
    (tset $ :state {:day (or (?. game-state :day) 1)})
    ($ui:open-textbox! {:nametag (.. "Day " $.state.day)
                        :text (.. "Almost 7am... time to open up the shop!")
                        :action #(scene-manager:select! :level_0)})
    )

  (fn exit! [$ game-state]
    (tset game-state :day $.state.day)
    (tset $ :state {}))

  (fn tick! [{: state &as $}]
    (if ($ui:active?) ($ui:tick!))
    )

  (fn draw! [{: state &as $}]
    ($ui:render!)
    )
  )


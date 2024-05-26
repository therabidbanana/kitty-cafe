(import-macros {: inspect : defns} :source.lib.macros)

(defns day-start
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})
  (fn enter! [$ game-state]
    (if (> game-state.savings 3000)
        ($ui:open-textbox! {:text (.. "I have enough to make rent! The cafe will make it another month.")
                            :action #(scene-manager:select! :menu)})
        ($ui:open-textbox! {:text (.. "I don't have enough to make rent. Guess it's time to close up.")
                            :action #(scene-manager:select! :menu)})
        )
    )

  (fn exit! [$ game-state]
    (tset $ :state {}))

  (fn tick! [{: state &as $}]
    (if ($ui:active?) ($ui:tick!))
    )

  (fn draw! [{: state &as $}]
    ($ui:render!)
    )
  )


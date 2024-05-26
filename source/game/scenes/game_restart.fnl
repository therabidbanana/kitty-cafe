(import-macros {: inspect : defns} :source.lib.macros)

(defns scene
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (fn enter! [$ game-state]
    (let []
      ($ui:open-textbox! {:text "Now where was I?"
                          :action #(scene-manager:select! :day_start)})
      )
    )

  (fn exit! [$]
    (tset $ :state {}))

  (fn tick! [{: state &as $}]
    (if ($ui:active?) ($ui:tick!))
    )

  (fn draw! [{: state &as $}]
    ($ui:render!)
    )
  )


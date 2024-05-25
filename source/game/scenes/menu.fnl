(import-macros {: inspect : defns} :source.lib.macros)

(defns scene
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})
  (fn enter! [$]
    ($ui:open-menu! {:options [{:text "Start Game [!]" :action #(scene-manager:select! :level_0)}]})
    ;; (tset $ :state :listview (testScroll pd gfx))
    )
  (fn exit! [$]
    (tset $ :state {}))
  (fn tick! [{:state {: listview} &as $}]
    ;; (listview:drawInRect 180 20 200 200)
    (if ($ui:active?) ($ui:tick!)
        (let [pressed? playdate.buttonJustPressed]
          (if (pressed? playdate.kButtonA) (scene-manager:select! :level_0)))
        ))
  (fn draw! [{:state {: listview} &as $}]
    ($ui:render!)
    ;; (listview:drawInRect 180 20 200 200)
    )
  )


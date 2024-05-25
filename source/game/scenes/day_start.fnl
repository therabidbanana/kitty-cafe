(import-macros {: inspect : defns} :source.lib.macros)

(defns day-start
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})
  (fn enter! [$]
    ($ui:open-textbox! {:text ""})
    ;; (tset $ :state :listview (testScroll pd gfx))
    )
  (fn exit! [$]
    (tset $ :state {}))
  (fn tick! [{:state {: listview} &as $}]
    ;; (listview:drawInRect 180 20 200 200)
    (if ($ui:active?) ($ui:tick!)
        ))
  (fn draw! [{:state {: listview} &as $}]
    ($ui:render!)
    ;; (listview:drawInRect 180 20 200 200)
    )
  )


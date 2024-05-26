(import-macros {: inspect : defns} :source.lib.macros)

(defns game-start
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})
  (fn enter! [$]
    (let [game-saves (playdate.datastore.read)
          game-saves (or (?. (or game-saves {}) :saves) [])
          game-saves (icollect [k v (ipairs game-saves)]
                       {:text (.. v.name)
                        :id v.id
                        :action (fn []
                                  ($ui:open-menu!
                                   {:options [{:text "Continue"
                                               :action (fn []
                                                         (let [game-id v.id
                                                               game-state (playdate.datastore.read game-id)]
                                                           (scene-manager:reset-state! game-state)
                                                           (scene-manager:select! :game_restart)))}
                                              {:text "Delete"
                                               :action (fn []
                                                         (let [game-saves (playdate.datastore.read)
                                                               saves (icollect [i j (ipairs game-saves.saves)]
                                                                       (if (not (= j.id v.id)) j))]
                                                           (playdate.datastore.write {: saves})
                                                           (playdate.datastore.delete v.id))
                                                         (scene-manager:select! :menu))}
                                              ]})
                                  )})
          ]
      (table.insert game-saves 1 {:text "New Game" :action #(scene-manager:select! :game_start)})
      ($ui:open-menu!
       {:options game-saves
        :on-draw (fn [comp selected]
                   (gfx.clear)
                   (when selected.id
                    (let [game-state (playdate.datastore.read selected.id)
                          dayrect (playdate.geometry.rect.new 280 20 120 20)
                          cashrect (playdate.geometry.rect.new 280 40 120 20)]
                      (gfx.setColor gfx.kColorWhite)
                      (gfx.fillRoundRect dayrect 4)
                      (gfx.setLineWidth 2)
                      (gfx.setColor gfx.kColorBlack)
                      (gfx.drawRoundRect dayrect 4)
                      (gfx.setColor gfx.kColorBlack)
                      (gfx.drawText (.. "Day: " (or (?. game-state.day) 1)) 286 22)

                      (gfx.setColor gfx.kColorWhite)
                      (gfx.fillRoundRect cashrect 4)
                      (gfx.setLineWidth 2)
                      (gfx.setColor gfx.kColorBlack)
                      (gfx.drawRoundRect cashrect 4)
                      (gfx.setColor gfx.kColorBlack)
                      (gfx.drawText (.. "Cash: " (or (?. game-state.savings) 0)) 286 42)
                      ))
                   )}))
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


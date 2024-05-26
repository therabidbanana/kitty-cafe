(import-macros {: inspect : defns} :source.lib.macros)

(defns scene
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (fn get-name [{: state}]
    (set playdate.keyboard.keyboardWillHideCallback
         (fn [save]
           (if save (tset state :name playdate.keyboard.text))
           ))
    (set playdate.keyboard.keyboardDidHideCallback
         (fn []
           (let [curr-state (or (playdate.datastore.read) {:saves []})]
             (table.insert curr-state.saves state)
             (playdate.datastore.write curr-state)
             (scene-manager:select! :day_start))
           ))
    (playdate.keyboard.show state.name)
    )

  (fn enter! [$ game-state]
    (let [(start-time millis) (playdate.getSecondsSinceEpoch)
          new-game-state {:name "Kate"
                          :id start-time
                          :day 1
                          :stock {:milk 20 :tuna-sandwich 10
                                  :strawberry-cake 2 :cherry-danish 1
                                  :chocolate 15 :vanilla 15}}]
      (tset $ :state new-game-state)
      (scene-manager:reset-state! new-game-state)
      (tset playdate.keyboard :text new-game-state.name)
      ($ui:open-textbox! {:text "What is your princess' name?"
                          :action (fn [] (get-name $))})
      )
    ;; ($ui:open-menu! {:options [{:text "Start Game [!]" :action #(scene-manager:select! :game_start)}]})
    ;; (tset $ :state :listview (testScroll pd gfx))
    )

  (fn exit! [$]
    (tset $ :state {}))

  (fn tick! [{:state {: listview &as state} &as $}]
    ;; (listview:drawInRect 180 20 200 200)
    (let [rect (playdate.geometry.rect.new 10 10
                                           120 20)
          ]
      (gfx.setColor gfx.kColorWhite)
      (gfx.fillRoundRect rect 4)
      (gfx.setLineWidth 2)
      (gfx.setColor gfx.kColorBlack)
      (gfx.drawRoundRect rect 4)
      (gfx.setColor gfx.kColorBlack)
      (gfx.drawText (or (?. playdate :keyboard :text) state.name) 16 12)
      )
    (if ($ui:active?) ($ui:tick!))
    )
  (fn draw! [{:state {: listview} &as $}]
    ($ui:render!)
    ;; (listview:drawInRect 180 20 200 200)
    )
  )


(import-macros {: inspect : defns} :source.lib.macros)

(defns day-end
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})


  (fn buy-item [game-state item quantity price]
    (when (>= game-state.savings price)
      (let [curr-stock (or (?. game-state.stock item) 0)
            new-stock (+ quantity curr-stock)
            new-cash (- game-state.savings price)]
        (tset game-state :stock item new-stock)
        (tset game-state :savings new-cash)
        )
      ))

  (fn enter! [$ game-state]
    (fn restock [$ game-state day-cash]
      (tset game-state :savings (+ (or (?. game-state :savings) 0) day-cash))
      ($ui:open-menu! {
                       :on-draw (fn [comp selected]
                                  (let [rect (playdate.geometry.rect.new 280 40
                                                                         120 20)
                                        ]
                                    (gfx.setColor gfx.kColorWhite)
                                    (gfx.fillRoundRect rect 4)
                                    (gfx.setLineWidth 2)
                                    (gfx.setColor gfx.kColorBlack)
                                    (gfx.drawRoundRect rect 4)
                                    (gfx.setColor gfx.kColorBlack)
                                    (gfx.drawText (.. "cash: " (or (?. game-state.savings) 0)) 286 42)
                                    )
                                  (let [rect (playdate.geometry.rect.new 280 10
                                                                         120 20)
                                        ]
                                    (gfx.setColor gfx.kColorWhite)
                                    (gfx.fillRoundRect rect 4)
                                    (gfx.setLineWidth 2)
                                    (gfx.setColor gfx.kColorBlack)
                                    (gfx.drawRoundRect rect 4)
                                    (gfx.setColor gfx.kColorBlack)
                                    (gfx.drawText (.. "Have: " (or (?. game-state.stock selected.item) 0)) 286 12)
                                    )
                                  (gfx.drawText (.. "Rent due: $3000") 220 180)
                                  (gfx.drawText (.. "in " (- 30 game-state.day) " days") 220 210)
                                  )
                       :options
                       [
                        {:item :milk
                         :price 2
                         :keep-open? true
                         :text "Milk ($1)" :action (fn [] (buy-item game-state :milk 1 1))}
                        {:item :chocolate
                         :price 10
                         :keep-open? true
                         :text "Chocolatex100 ($10)" :action (fn [] (buy-item game-state :chocolate 100 10))}
                        {:item :vanilla
                         :price 10
                         :keep-open? true
                         :text "Vanillax100 ($10)" :action (fn [] (buy-item game-state :vanilla 100 10))}
                        {:item :cherry-danish
                         :price 2
                         :keep-open? true
                         :text "Cherry Danish ($2)" :action (fn [] (buy-item game-state :cherry-danish 1 2))}
                        {:item :strawberry-cake
                         :price 25
                         :keep-open? true
                         :text "Berry Cakex8 ($25)" :action (fn [] (buy-item game-state :strawberry-cake 8 25))}
                        {:item :tuna-sandwich
                         :price 5
                         :keep-open? true
                         :text "Tuna Sando ($5)" :action (fn [] (buy-item game-state :tuna-sandwich 1 5))}
                        {:text "Done" :action #(if (>= game-state.day 3)
                                                   (scene-manager:select! :game_end)
                                                   (scene-manager:select! :day_start))}
                        ]
                       })
      )
    (tset $ :state {:day (or (?. game-state :day) 1)})
    ($ui:open-textbox! {:nametag (.. "Day " $.state.day)
                        :text (.. "Alrighty, all cleaned up. Looks like I made $" game-state.day-cash " today.")
                        :action #(restock $ game-state game-state.day-cash)})
    )

  (fn exit! [$ game-state]
    (tset game-state :day (+ $.state.day 1))
    (tset game-state :day-cash 0)
    (tset $ :state {}))

  (fn tick! [{: state &as $}]
    (if ($ui:active?) ($ui:tick!))
    )

  (fn draw! [{: state &as $}]
    ($ui:render!)
    )
  )


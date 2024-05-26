(import-macros {: inspect : defns} :source.lib.macros)

(defns day-end
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})


  (fn buy-item [game-state item quantity price]
    (when (>= game-state.day-cash price)
      (let [curr-stock (?. game-state.stock item)
            new-stock (+ quantity curr-stock)
            new-cash (- game-state.day-cash price)]
        (tset game-state :stock item new-stock)
        (tset game-state :day-cash new-cash)
        )
      ))

  (fn enter! [$ game-state]
    (fn restock [$ game-state]
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
                                    (gfx.drawText (.. "cash: " (or (?. game-state.day-cash) 0)) 286 42)
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
                                  )
                       :options
                       [
                        {:item :milk
                         :price 2
                         :keep-open? true
                         :text "Milk ($2)" :action (fn [] (buy-item game-state :milk 1 2))}
                        {:item :chocolate
                         :price 10
                         :keep-open? true
                         :text "Chocolatex100 ($10)" :action (fn [] (buy-item game-state :chocolate 100 10))}
                        {:item :vanilla
                         :price 10
                         :keep-open? true
                         :text "Vanillax100 ($10)" :action (fn [] (buy-item game-state :vanilla 100 10))}
                        {:item :tuna-sandwich
                         :price 5
                         :keep-open? true
                         :text "Tuna Sand ($5)" :action (fn [] (buy-item game-state :tuna-sandwich 1 5))}
                        {:text "Done" :action #(scene-manager:select! :day_start)}
                        ]
                       })
      )
    (tset $ :state {:day (or (?. game-state :day) 1)})
    ($ui:open-textbox! {:nametag (.. "Day " $.state.day)
                        :text (.. "Alrighty, all cleaned up. Looks like I made $" game-state.day-cash " today.")
                        :action #(restock $ game-state)})
    )

  (fn exit! [$ game-state]
    (tset game-state :day (+ $.state.day 1))
    (tset $ :state {}))

  (fn tick! [{: state &as $}]
    (if ($ui:active?) ($ui:tick!))
    )

  (fn draw! [{: state &as $}]
    ($ui:render!)
    )
  )

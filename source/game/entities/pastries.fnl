(import-macros {: inspect : defns} :source.lib.macros)

(defns :milk
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  (fn interact! [self player]
    (if player.state.holding
        ($ui:open-textbox! {:nametag player.state.name
                            :text "I need to put down what I'm holding first."})
        ($ui:open-menu! {:options [{:text "Tuna Sandwich"
                                    :action #(if (player:hold-item! {:item :tuna-sandwich})
                                                 true
                                                 ($ui:open-textbox! {:text "I'm out."}))}
                                   {:text "Nevermind."}]})
        )
    )

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w}]
    (let [player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 80 16)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 0 0 80 16)
      (player:setGroups [2])
      ;; (player:setCollidesWithGroups [1 4])
      (tset player :draw draw)
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :interact! interact!)
      (tset player :state {:facing :down
                           :tile-x (// x tile-w) :tile-y (// y tile-h)})
      player)))


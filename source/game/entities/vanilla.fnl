(import-macros {: inspect : defns} :source.lib.macros)

(defns chocolate
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  (fn interact! [self player]
    (if player.state.holding
        (do
          (player:modify-item! :vanilla)
          ($ui:open-textbox! {:text "Added a pump of vanilla."})
          )
        ($ui:open-textbox! {:text "I'm not holding anything yet."}))
    )

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w}]
    (let [player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 16 16)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 16 8 8 8)
      (player:setGroups [4])
      ;; (player:setCollidesWithGroups [1 4])
      (tset player :draw draw)
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :interact! interact!)
      (tset player :state {:facing :down
                           :tile-x (// x tile-w) :tile-y (// y tile-h)})
      player)))

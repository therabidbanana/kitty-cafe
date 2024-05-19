(import-macros {: inspect : defns} :source.lib.macros)

(defns :line
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w :layer-details {: node-list : grid-w }}]
    (let [tile-x (// x tile-w)
          tile-y (// y tile-h)]
      (tset node-list (+ (* tile-y grid-w) (+ tile-x 1)) 1)
      nil)))


(import-macros {: pd/import : defns : inspect} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_0
  [entity-map (require :source.game.entities.core)
   ;; ldtk (require :source.lib.ldtk.loader)
   {: prepare-level!} (require :source.lib.level)
   $ui (require :source.lib.ui)
   pd playdate
   gfx pd.graphics]

  (fn -node-list! [size]
    (local t {})
    (for [i 1 size]
      (tset t i 0))
    t)

  (fn enter! [$]
    (let [
          ;; Option 1 - Loads at runtime
          ;; loaded (prepare-level! (ldtk.load-level {:level 0}) entity-map)
          ;; Option 2 - relies on deflevel compiling
          tile-size 16
          grid-w (inspect (// level_0.w tile-size))
          grid-h (// level_0.h tile-size)
          node-list (-node-list! (* grid-w grid-h))
          locations {}
          patrons []
          loaded (prepare-level! level_0 entity-map {:tiles {:z-index 100}
                                                     :line { : node-list : grid-w : locations}
                                                     :wait { : node-list : grid-w : locations}
                                                     :exit { : node-list : grid-w : locations}
                                                     :npc { : patrons }
                                                     :appliances {:z-index 0}
                                                     :entrance { :spawn (?. entity-map :npc) }
                                                     :floor_covers {:z-index -100}
                                                     :flooring {:z-index -110}
                                                     })
          graph (playdate.pathfinder.graph.new2DGrid grid-w grid-h false node-list)
          graph-locations (collect [k v (pairs locations)]
                            ;; (values k (graph:nodeWithXY (+ v.tile-x 1) (+ v.tile-y 1)))
                            (values k (graph:nodeWithID (+ (* grid-w v.tile-y) (+ v.tile-x 1))))
                            )
          wait-node (?. graph-locations :wait)
          player (?. (icollect [_ v (ipairs loaded.entities)]
                       (if (?. v :player?) v)) 1)
          hud (entity-map.hud.new! player)]
      (hud:add)
      ;; (inspect {:x wait-node.x :y wait-node.y})
      (tset $ :state {: graph : locations : graph-locations : grid-w
                      :ticks 1 })
      loaded
      )
    )

  (fn exit! [$])

  (fn tick! [$]
    (if ($ui:active?) ($ui:tick!)
        (do
          (tset $ :state :ticks (+ $.state.ticks 1))
          (gfx.sprite.performOnAllSprites (fn react-each [ent]
                                            (if (?. ent :react!) (ent:react! $.state)))))))
  (fn draw! [$]
    ;; ($.layer.tilemap:draw 0 0)
    ($ui:render!)
    )
  )


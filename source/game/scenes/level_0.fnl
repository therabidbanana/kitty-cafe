(import-macros {: pd/import : clamp : defns : inspect} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_0
  [entity-map (require :source.game.entities.core)
   ;; ldtk (require :source.lib.ldtk.loader)
   scene-manager (require :source.lib.scene-manager)
   {: prepare-level!} (require :source.lib.level)
   $ui (require :source.lib.ui)
   pd playdate
   gfx pd.graphics]

  (fn -node-list! [size]
    (local t {})
    (for [i 1 size]
      (tset t i 0))
    t)

  (fn enter! [$ {: name &as game-state}]
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
                                                     :player { : name }
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
          hud (entity-map.hud.new! player)
          clock (entity-map.clock.new! $)
          ]
      (hud:add)
      (clock:add)
      ;; (inspect {:x wait-node.x :y wait-node.y})
      (tset $ :state {: graph : locations : graph-locations : grid-w
                      :player-name name : player
                      :ticks 1 :seconds 0 })
      loaded
      )
    )

  (fn exit! [$]
    (tset $ :state {})
    )

  (fn tick! [$ game-state]
    (if ($ui:active?) ($ui:tick!)
        (let [(change acceleratedChange) (playdate.getCrankChange)
              cranked (+ (or $.state.cranked 0) acceleratedChange)
              cranked (clamp 0 cranked 960) ;; 3x is fastest without bugging move
              speed (or $.state.speed 1)
              speed (clamp 1 (+ 1 (// cranked 360)) 3)
              seconds  (+ (* speed 2) $.state.seconds)]
          (tset $ :state :ticks (+ $.state.ticks 1))
          (tset $ :state :seconds seconds)
          (tset $ :state :speed speed)
          (tset $ :state :cranked cranked)
          (if (> $.state.seconds (* 60 (* 2 60)))
              (do
                (tset game-state :day-cash $.state.player.state.cash)
                ($ui:open-textbox! {:text "Looks like it's about time to close up shop for the day."
                                    :action #(scene-manager:select! :day_end)})
                )
              )
          (gfx.sprite.performOnAllSprites (fn react-each [ent]
                                            (if (?. ent :react!) (ent:react! $.state)))))))
  (fn draw! [$]
    ;; ($.layer.tilemap:draw 0 0)
    ($ui:render!)
    )
  )


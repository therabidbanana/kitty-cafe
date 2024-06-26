(let [player (require :source.game.entities.player)
      npc    (require :source.game.entities.npc)
      order    (require :source.game.entities.order)
      milk    (require :source.game.entities.milk)
      pastries    (require :source.game.entities.pastries)
      line    (require :source.game.entities.line)
      wait    (require :source.game.entities.wait)
      exit    (require :source.game.entities.exit)
      entrance    (require :source.game.entities.entrance)
      hud    (require :source.game.entities.hud)
      holding_hud    (require :source.game.entities.holding_hud)
      clock    (require :source.game.entities.clock)
      trash    (require :source.game.entities.trash)
      vanilla    (require :source.game.entities.vanilla)
      chocolate    (require :source.game.entities.chocolate)
      sandwich_window (require :source.game.entities.sandwich_window)
      danish_window (require :source.game.entities.danish_window)
      cake_window (require :source.game.entities.cake_window)
      ]
  {: player : npc : hud : holding_hud : clock
   : order : milk : trash : pastries
   : vanilla : chocolate
   : sandwich_window : cake_window : danish_window
   : line : wait : exit : entrance})

(let [player (require :source.game.entities.player)
      npc    (require :source.game.entities.npc)
      order    (require :source.game.entities.order)
      milk    (require :source.game.entities.milk)
      line    (require :source.game.entities.line)
      wait    (require :source.game.entities.wait)
      exit    (require :source.game.entities.exit)
      entrance    (require :source.game.entities.entrance)
      ]
  {: player : npc
   : order : milk
   : line : wait : exit : entrance})

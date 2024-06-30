(import-macros {: inspect : pd/import : pd/load : require/patch : love/patch} :source.lib.macros)
(require/patch)
(love/patch)

(pd/import :CoreLibs/object)
(pd/import :CoreLibs/easing)
(pd/import :CoreLibs/graphics)
(pd/import :CoreLibs/sprites)
(pd/import :CoreLibs/timer)
(pd/import :CoreLibs/keyboard)

(global $config {:debug true})

(pd/load
 [{: scene-manager} (require :source.lib.core)]
 (fn load-hook []
   (scene-manager:load-scenes! (require :source.game.scenes))
   (scene-manager:select! :logo)
   )
 (fn update-hook []
   (scene-manager:tick!)
   )
 (fn draw-hook []
   (scene-manager:draw!)
   )
 )

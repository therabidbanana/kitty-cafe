(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :keyboard))
    (tset _G.playdate :keyboard {}))

(defmodule
 _G.playdate.keyboard
 []

 ;; TODO: text settable?
 (var text "")

 (fn show [t]
   (set text t)
   )
 )

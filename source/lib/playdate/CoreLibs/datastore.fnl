(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :datastore))
    (tset _G.playdate :datastore {}))

(defmodule
 _G.playdate.datastore
 []

 (fn read [id]
   (let [id (or id "default")
         file (.. id ".datastore")]
     (if
      (love.filesystem.exists file)
      (with-open [f (love.filesystem.newFile file)]
        (: f :open "r")
        (love.data.decode :data :hex (: f :read)))
      )
     ))
 (fn write [data id]
   (let [id (or id "default")
         file (.. id ".datastore")]
     (with-open [f (love.filesystem.newFile file)]
       (: f :open "w")
       (love.data.encode :data :hex data))
     ))
 )

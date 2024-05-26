(import-macros {: inspect : defns} :source.lib.macros)

(defns order_helper
  []

  (fn random-milk []
    (let [modifier (case (math.random 1 9)
                     1 [:chocolate]
                     2 [:vanilla]
                     3 [:chocolate]
                     4 [:vanilla]
                     5 [:chocolate :vanilla]
                     _ [])]
      {:item :milk
       :modifiers modifier}))

  (fn random-pastry []
    (case (math.random 1 9)
      1 {:item :cherry-danish
         :modifiers []}
      2 {:item :cherry-danish
         :modifiers [:chocolate]}
      3 {:item :strawberry-cake
         :modifiers []}
      4 {:item :strawberry-cake
         :modifiers [:chocolate]}
      _ {:item :tuna-sandwich
       :modifiers []}))

  (fn generate-order []
    (case (math.random 1 10)
      1 [(random-milk) (random-milk) (random-milk)]
      2 [(random-milk) (random-milk)]
      3 [(random-pastry)]
      4 [(random-pastry)]
      5 [(random-milk) (random-pastry)]
      6 [(random-milk) (random-pastry)]
      _ [(random-milk)])
    )

  (fn item-value [{ : item : modifiers &as full-item}]
    (let [modifier-value (length (or modifiers []))]
      (case item
        :milk (+ 2 modifier-value)
        :tuna-sandwich (+ 7 modifier-value)
        :cherry-danish (+ 3 modifier-value)
        :strawberry-cake (+ 4 modifier-value)
        _ 0)))

  (fn describe-item [full-item]
    (if (= (type full-item) "nil")
        "nothing"
        (let [{: item : modifiers} full-item
              item-readable (case item
                              :tuna-sandwich "tuna sandwich"
                              :cherry-danish "cherry danish"
                              :strawberry-cake "strawberry cake"
                              other other)
              mods (or modifiers [])
              sorted (table.sort mods)]
          (if (> (length mods) 0)
              (.. item-readable " with " (table.concat mods " & "))
              item-readable)))
    )

  (fn sentence-from [[first & rest]]
    (case (length rest)
      0
      first
      1
      (.. (?. rest 1) " and " first)
      _
      (.. (table.concat rest ", ") ", and " first)
      )
    )

  (fn describe-items [items]
    (if
     (= (type items) "nil")
     "nothing"
     (> (length items) 1)
     (sentence-from
      (icollect [i v (ipairs items)] (describe-item v)))
     (> (length items) 0)
     (describe-item (?. items 1))
     ;; else
     "nothing"
     )
    )

  (fn same-item? [item1 item2]
    (= (describe-item item1)
       (describe-item item2)))
  )

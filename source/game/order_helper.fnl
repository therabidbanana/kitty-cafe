(import-macros {: inspect : defns} :source.lib.macros)

(defns order_helper
  []

  (fn random-milk []
    (let [modifier (case (math.random 1 6)
                     1 [:chocolate]
                     2 [:vanilla]
                     3 [:chocolate :vanilla]
                     _ [])]
      {:item :milk
       :modifiers modifier}))

  (fn random-pastry []
    {:item :tuna-sandwich
     :modifiers []})

  (fn generate-order []
    (case (math.random 1 7)
      1 [(random-milk) (random-milk) (random-milk)]
      2 [(random-milk) (random-milk)]
      3 [(random-pastry)]
      _ [(random-milk)])
    )

  (fn item-value [{ : item : modifiers &as full-item}]
    (let [modifier-value (length (or modifiers []))]
      (case item
        :milk (+ 2 modifier-value)
        :tuna-sandwich (+ 7 modifier-value)
        _ 0)))

  (fn describe-item [full-item]
    (if (= (type full-item) "nil")
        "nothing"
        (let [{: item : modifiers} full-item
              item-readable (case item
                              :tuna-sandwich "tuna sandwich"
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
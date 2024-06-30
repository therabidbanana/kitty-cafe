(import-macros {: defmodule : inspect} :source.lib.macros)

(if (not (?. _G.playdate :pathfinder))
    (tset _G.playdate :pathfinder {}))

(if (not (?. _G.playdate :pathfinder :graph))
    (tset _G.playdate :pathfinder :graph {}))

(if (not (?. _G.playdate :pathfinder :node))
    (tset _G.playdate :pathfinder :node {}))


(defmodule
  _G.playdate.pathfinder
  []

  (local
   node
   (defmodule
     _G.playdate.pathfinder.node
     []

     (fn new [id x y]
       {: id : x : y :conns {}})
     ))
  ;; end node

  (local
   graph
   (defmodule
     _G.playdate.pathfinder.graph
     []
     (local straight 10)
     (local diagonal 14)

     (fn -taxicab [{:x x1 :y y1} {:x x2 :y y2}]
       (* (+ (math.abs (- x1 x2))
             (math.abs (- y1 y2)))
          straight))

     ;; TODO - A* search, taxicab heuristic
     (fn findPath [self curr goal heuristic]
       (let [heuristic (or heuristic -taxicab)
             frontier [{:weight (heuristic curr goal)
                        :actual 0
                        :from   nil
                        :node   curr}]]
         (var exit nil)
         (while (and (> (length frontier) 0) (= nil exit))
           (let [next-item (table.remove frontier 1)]
             (if (= next-item.node goal)
                 (set exit next-item)
                 (each [nodeid weight (pairs next-item.node.conns)]
                   (table.insert frontier {:weight (+ next-item.actual
                                                      weight
                                                      (heuristic (self:nodeWithID nodeid) goal))
                                           :actual (+ weight next-item.actual)
                                           :from next-item
                                           :node (self:nodeWithID nodeid)})
                   ))
             (table.sort frontier (fn [a b] (< a.weight b.weight)))
             ))
         (if exit
             (let [path []]
               (while exit
                 (table.insert path 1 exit.node)
                 (set exit exit.from))
               path))
         ))

     (fn -xyNodeId [x y w] (+ x (* y w)))
     (fn nodeWithID [self id]
       (?. self.nodes id))
     (fn nodeWithXY [self x y]
       (?. self.nodes (-xyNodeId x y self.w)))

     (fn addConnectionToNodeWithID [self from to weight recip]
       (let [source (self:nodeWithID from)
             dest (self:nodeWithID to)]
         (if (and dest source) (tset source :conns to weight))
         (if (and recip dest source) (tset dest :conns from weight))
         ))

     (fn addConnections [self connections]
       (each [source conns (pairs connections)]
         (for [i 1 (length conns) 2]
           (self:addConnectionToNodeWithID source (?. conns i) (?. conns (+ i 1))))))

     (fn -adjacentNodeIds [gridx gridy gridw gridh diagonals]
       (let [ids []]
         ;; to the topright
         (if (and (> gridw gridx)
                  (> gridy 1)
                  diagonals)
             (do
               (table.insert ids (-xyNodeId (+ gridx 1) (- gridy 1) gridw))
               (table.insert ids diagonal))
             )
         ;; to the topleft
         (if (and (> gridx 1)
                  (> gridy 1)
                  diagonals)
             (do
               (table.insert ids (-xyNodeId (- gridx 1) (- gridy 1) gridw))
               (table.insert ids diagonal)))
         ;; to the bottomright
         (if (and (> gridw gridx)
                  (> gridh gridy)
                  diagonals)
             (do
               (table.insert ids (-xyNodeId (+ gridx 1) (+ gridy 1) gridw))
               (table.insert ids diagonal))
             )
         ;; to the bottomleft
         (if (and (> gridx 1)
                  (> gridh gridy)
                  diagonals)
             (> gridh gridy)
             (do
               (table.insert ids (-xyNodeId (- gridx 1) (+ gridy 1) gridw))
               (table.insert ids diagonal)))
         ;; to the right
         (if (> gridw gridx)
             (do
               (table.insert ids (-xyNodeId (+ gridx 1) gridy gridw))
               (table.insert ids straight))
             )
         ;; to the left
         (if (> gridx 1)
             (do
               (table.insert ids (-xyNodeId (- gridx 1) gridy gridw))
               (table.insert ids straight))
             )
         ;; to the top
         (if (> gridy 1)
             (do
               (table.insert ids (-xyNodeId gridx (- gridy 1) gridw))
               (table.insert ids straight))
             )
         ;; to the bottom
         (if (> gridh gridy)
             (do
               (table.insert ids (-xyNodeId gridx (+ gridy 1) gridw))
               (table.insert ids straight)))
         ids)
       )

     (fn new2DGrid [width height diagonals nodelist]
       (let [nodes {}
             connections {}
             graph {: nodes :w width :h height
                    : addConnections : findPath : nodeWithID : nodeWithXY
                    : addConnectionToNodeWithID}
             hasNode (if nodelist
                         (fn [id] (?. nodelist id))
                         (fn [id] true))
             ]
         (for [y 1 height]
           (for [x 1 width]
             (let [id (-xyNodeId x y width)]
               (if (hasNode id)
                   (tset nodes id (node.new id x y))))))
         (for [y 1 height]
           (for [x 1 width]
             (let [nodeid (-xyNodeId x y width)]
               (if (?. nodes nodeid)
                   (tset connections nodeid (-adjacentNodeIds x y width height diagonals))))
             ))
         (graph:addConnections connections)
         graph)
       )
     )
   )
  ;; end graph
  )

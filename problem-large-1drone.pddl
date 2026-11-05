;; Large instance, single-drone variant: same map and goals
(define (problem drones-large-1drone)
  (:domain EMERGENCY-DRONES)

  (:objects
    d1 - drone
    depot-w depot-e hub ch-n ch-e w1 w2 e1 e2 n1 n2 - location
    medkit1 medkit2 - medkit
    water1 - water
    comm1 - commdevice
    b0 b1 b2 b3 b4 b5 b6 - level)

  (:init
    ;; --- drones: one position, one battery level, empty ---
    (at d1 depot-w) (battery d1 b6) (empty d1)

    ;; --- map: connections, flight cost (battery) and distance (plan cost) ---
    (connected depot-w w1) (flight-cost depot-w w1 b1) (= (distance depot-w w1) 1)
    (connected w1 depot-w) (flight-cost w1 depot-w b1) (= (distance w1 depot-w) 1)
    (connected w1 w2) (flight-cost w1 w2 b1) (= (distance w1 w2) 1)
    (connected w2 w1) (flight-cost w2 w1 b1) (= (distance w2 w1) 1)
    (connected depot-w w2) (flight-cost depot-w w2 b2) (= (distance depot-w w2) 2)
    (connected w2 depot-w) (flight-cost w2 depot-w b2) (= (distance w2 depot-w) 2)
    (connected depot-w hub) (flight-cost depot-w hub b2) (= (distance depot-w hub) 2)
    (connected hub depot-w) (flight-cost hub depot-w b2) (= (distance hub depot-w) 2)
    (connected hub depot-e) (flight-cost hub depot-e b2) (= (distance hub depot-e) 2)
    (connected depot-e hub) (flight-cost depot-e hub b2) (= (distance depot-e hub) 2)
    (connected depot-e e1) (flight-cost depot-e e1 b1) (= (distance depot-e e1) 1)
    (connected e1 depot-e) (flight-cost e1 depot-e b1) (= (distance e1 depot-e) 1)
    (connected e1 ch-e) (flight-cost e1 ch-e b1) (= (distance e1 ch-e) 1)
    (connected ch-e e1) (flight-cost ch-e e1 b1) (= (distance ch-e e1) 1)
    (connected ch-e e2) (flight-cost ch-e e2 b1) (= (distance ch-e e2) 1)
    (connected e2 ch-e) (flight-cost e2 ch-e b1) (= (distance e2 ch-e) 1)
    (connected e1 e2) (flight-cost e1 e2 b2) (= (distance e1 e2) 2)
    (connected e2 e1) (flight-cost e2 e1 b2) (= (distance e2 e1) 2)
    (connected hub ch-n) (flight-cost hub ch-n b2) (= (distance hub ch-n) 2)
    (connected ch-n hub) (flight-cost ch-n hub b2) (= (distance ch-n hub) 2)
    (connected ch-n n1) (flight-cost ch-n n1 b1) (= (distance ch-n n1) 1)
    (connected n1 ch-n) (flight-cost n1 ch-n b1) (= (distance n1 ch-n) 1)
    (connected n1 n2) (flight-cost n1 n2 b2) (= (distance n1 n2) 2)
    (connected n2 n1) (flight-cost n2 n1 b2) (= (distance n2 n1) 2)

    ;; --- charging stations ---
    (charging-station hub) (charging-station ch-n) (charging-station ch-e)

    ;; --- accessible from the start (all except locked sites) ---
    (accessible depot-w) (accessible depot-e) (accessible hub) (accessible ch-n) (accessible ch-e) (accessible w1) (accessible w2) (accessible e1) (accessible n1)

    ;; --- unlock dependencies ---
    (unlocked-by-delivery e1 e2)        ; delivery at e1 unlocks e2
    (unlocked-by-inspection n1 n2)        ; inspection at n1 unlocks n2

    ;; --- supplies and needs ---
    (supply-at medkit1 depot-w)
    (supply-at medkit2 depot-w)
    (supply-at water1 depot-e)
    (supply-at comm1 depot-e)
    (needs w2 medkit1)
    (needs w1 medkit2)
    (needs e1 comm1)
    (needs e2 water1)

    ;; --- symbolic battery arithmetic ---
    (battery-after b1 b1 b0)
    (battery-after b2 b1 b1)
    (battery-after b2 b2 b0)
    (battery-after b3 b1 b2)
    (battery-after b3 b2 b1)
    (battery-after b4 b1 b3)
    (battery-after b4 b2 b2)
    (battery-after b5 b1 b4)
    (battery-after b5 b2 b3)
    (battery-after b6 b1 b5)
    (battery-after b6 b2 b4)
    (next-level b0 b1) (next-level b1 b2) (next-level b2 b3) (next-level b3 b4) (next-level b4 b5) (next-level b5 b6)
    (max-level b6)

    (= (total-cost) 0))

  (:goal (and
    (inspected w1)
    (inspected n1)
    (inspected n2)
    (delivered medkit1 w2)
    (delivered medkit2 w1)
    (delivered comm1 e1)
    (delivered water1 e2)
  ))

  (:metric minimize (total-cost)))

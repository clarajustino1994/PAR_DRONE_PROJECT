;; Large instance: 3 drones, 16 locations, 10 goals
(define (problem drones-large)
  (:domain EMERGENCY-DRONES)

  (:objects
    d1 d2 d3 - drone
    depot-w depot-e hub ch-n ch-e ch-s w1 w2 w3 n1 n2 n3 e1 e2 s1 s2 - location
    medkit1 medkit2 - medkit
    water2 water1 - water
    comm1 comm2 - commdevice
    b0 b1 b2 b3 b4 b5 - level)

  (:init
    ;; --- drones: one position, one battery level, empty ---
    (at d1 depot-w) (battery d1 b5) (empty d1)
    (at d2 depot-e) (battery d2 b5) (empty d2)
    (at d3 ch-n) (battery d3 b5) (empty d3)

    ;; --- map: connections, flight cost (battery) and distance (plan cost) ---
    (connected depot-w w1) (flight-cost depot-w w1 b1) (= (distance depot-w w1) 1)
    (connected w1 depot-w) (flight-cost w1 depot-w b1) (= (distance w1 depot-w) 1)
    (connected depot-w w2) (flight-cost depot-w w2 b2) (= (distance depot-w w2) 2)
    (connected w2 depot-w) (flight-cost w2 depot-w b2) (= (distance w2 depot-w) 2)
    (connected w1 w2) (flight-cost w1 w2 b2) (= (distance w1 w2) 2)
    (connected w2 w1) (flight-cost w2 w1 b2) (= (distance w2 w1) 2)
    (connected w2 w3) (flight-cost w2 w3 b1) (= (distance w2 w3) 1)
    (connected w3 w2) (flight-cost w3 w2 b1) (= (distance w3 w2) 1)
    (connected hub ch-n) (flight-cost hub ch-n b2) (= (distance hub ch-n) 2)
    (connected ch-n hub) (flight-cost ch-n hub b2) (= (distance ch-n hub) 2)
    (connected ch-n n1) (flight-cost ch-n n1 b1) (= (distance ch-n n1) 1)
    (connected n1 ch-n) (flight-cost n1 ch-n b1) (= (distance n1 ch-n) 1)
    (connected n1 n2) (flight-cost n1 n2 b2) (= (distance n1 n2) 2)
    (connected n2 n1) (flight-cost n2 n1 b2) (= (distance n2 n1) 2)
    (connected n2 n3) (flight-cost n2 n3 b1) (= (distance n2 n3) 1)
    (connected n3 n2) (flight-cost n3 n2 b1) (= (distance n3 n2) 1)
    (connected n3 ch-n) (flight-cost n3 ch-n b1) (= (distance n3 ch-n) 1)
    (connected ch-n n3) (flight-cost ch-n n3 b1) (= (distance ch-n n3) 1)
    (connected w1 ch-n) (flight-cost w1 ch-n b3) (= (distance w1 ch-n) 3)
    (connected ch-n w1) (flight-cost ch-n w1 b3) (= (distance ch-n w1) 3)
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
    (connected hub s1) (flight-cost hub s1 b2) (= (distance hub s1) 2)
    (connected s1 hub) (flight-cost s1 hub b2) (= (distance s1 hub) 2)
    (connected w3 s1) (flight-cost w3 s1 b1) (= (distance w3 s1) 1)
    (connected s1 w3) (flight-cost s1 w3 b1) (= (distance s1 w3) 1)
    (connected s1 ch-s) (flight-cost s1 ch-s b1) (= (distance s1 ch-s) 1)
    (connected ch-s s1) (flight-cost ch-s s1 b1) (= (distance ch-s s1) 1)
    (connected ch-s s2) (flight-cost ch-s s2 b2) (= (distance ch-s s2) 2)
    (connected s2 ch-s) (flight-cost s2 ch-s b2) (= (distance s2 ch-s) 2)
    (connected e2 s2) (flight-cost e2 s2 b2) (= (distance e2 s2) 2)
    (connected s2 e2) (flight-cost s2 e2 b2) (= (distance s2 e2) 2)
    (connected depot-w hub) (flight-cost depot-w hub b2) (= (distance depot-w hub) 2)
    (connected hub depot-w) (flight-cost hub depot-w b2) (= (distance hub depot-w) 2)

    ;; --- charging stations ---
    (charging-station hub) (charging-station ch-n) (charging-station ch-e) (charging-station ch-s)

    ;; --- accessible from the start (all except locked sites) ---
    (accessible depot-w) (accessible depot-e) (accessible hub) (accessible ch-n) (accessible ch-e) (accessible w1) (accessible w2) (accessible n1) (accessible e1) (accessible s1) (accessible s2)

    ;; --- unlock dependencies ---
    (unlocked-by-inspection w2 w3)        ; inspection at w2 unlocks w3
    (unlocked-by-inspection n1 n2)        ; inspection at n1 unlocks n2
    (unlocked-by-delivery n2 n3)        ; delivery at n2 unlocks n3
    (unlocked-by-delivery e1 e2)        ; delivery at e1 unlocks e2
    (unlocked-by-inspection s1 ch-s)        ; inspection at s1 unlocks ch-s

    ;; --- supplies and needs ---
    (supply-at medkit1 depot-w)
    (supply-at medkit2 depot-w)
    (supply-at water2 depot-w)
    (supply-at comm1 depot-e)
    (supply-at comm2 depot-e)
    (supply-at water1 depot-e)
    (needs w1 medkit1)
    (needs w3 water2)
    (needs n2 comm2)
    (needs e1 comm1)
    (needs e2 water1)
    (needs s2 medkit2)

    ;; --- symbolic battery arithmetic ---
    (battery-after b1 b1 b0)
    (battery-after b2 b1 b1)
    (battery-after b2 b2 b0)
    (battery-after b3 b1 b2)
    (battery-after b3 b2 b1)
    (battery-after b3 b3 b0)
    (battery-after b4 b1 b3)
    (battery-after b4 b2 b2)
    (battery-after b4 b3 b1)
    (battery-after b5 b1 b4)
    (battery-after b5 b2 b3)
    (battery-after b5 b3 b2)
    (next-level b0 b1) (next-level b1 b2) (next-level b2 b3) (next-level b3 b4) (next-level b4 b5)
    (max-level b5)

    (= (total-cost) 0))

  (:goal (and
    (inspected w2)
    (inspected n1)
    (inspected n3)
    (inspected s1)
    (delivered medkit1 w1)
    (delivered water2 w3)
    (delivered comm2 n2)
    (delivered comm1 e1)
    (delivered water1 e2)
    (delivered medkit2 s2)
  ))

  (:metric minimize (total-cost)))

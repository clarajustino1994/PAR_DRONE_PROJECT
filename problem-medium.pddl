
(define (problem emergency-medium)
  (:domain EMERGENCY-DRONES)

  (:objects
    drone1 drone2 - drone

    depot station1 station2
    site1 site2 site3 site4 site5 - location

    med1 - medkit
    water1 - water
    comm1 - commdevice

    b0 b1 b2 b3 b4 b5 b6 - level
  )

  (:init
    ;; Both drones start at the depot
    (at drone1 depot)
    (at drone2 depot)

    ;; Both drones start empty
    (empty drone1)
    (empty drone2)

    ;; Both drones start fully charged
    (battery drone1 b6)
    (battery drone2 b6)

    ;; All supplies are stored at the depot
    (supply-at med1 depot)
    (supply-at water1 depot)
    (supply-at comm1 depot)

    ;; Delivery requirements
    (needs site3 med1)
    (needs site4 water1)
    (needs site5 comm1)

    ;; Initially accessible locations
    (accessible depot)
    (accessible station1)
    (accessible station2)
    (accessible site1)
    (accessible site3)
    (accessible site4)
    (accessible site5)

    ;; Site 2 is locked until Site 1 is inspected
    (unlocked-by-inspection site1 site2)

    ;; Charging stations
    (charging-station station1)
    (charging-station station2)

    ;; ==========================================
    ;; CONNECTIONS, FLIGHT COSTS AND DISTANCES
    ;; ==========================================

    ;; Depot <-> Station 1 (cost 1)
    (connected depot station1)
    (connected station1 depot)
    (flight-cost depot station1 b1)
    (flight-cost station1 depot b1)
    (= (distance depot station1) 1)
    (= (distance station1 depot) 1)

    ;; Depot <-> Site 1 (cost 2)
    ;; Direct route to the first inspection site
    (connected depot site1)
    (connected site1 depot)
    (flight-cost depot site1 b2)
    (flight-cost site1 depot b2)
    (= (distance depot site1) 2)
    (= (distance site1 depot) 2)

    ;; Site 1 <-> Site 2 (cost 1)
    (connected site1 site2)
    (connected site2 site1)
    (flight-cost site1 site2 b1)
    (flight-cost site2 site1 b1)
    (= (distance site1 site2) 1)
    (= (distance site2 site1) 1)

    ;; Station 1 <-> Site 3 (cost 2)
    (connected station1 site3)
    (connected site3 station1)
    (flight-cost station1 site3 b2)
    (flight-cost site3 station1 b2)
    (= (distance station1 site3) 2)
    (= (distance site3 station1) 2)

    ;; Site 3 <-> Station 2 (cost 1)
    (connected site3 station2)
    (connected station2 site3)
    (flight-cost site3 station2 b1)
    (flight-cost station2 site3 b1)
    (= (distance site3 station2) 1)
    (= (distance station2 site3) 1)

    ;; Station 2 <-> Site 4 (cost 1)
    (connected station2 site4)
    (connected site4 station2)
    (flight-cost station2 site4 b1)
    (flight-cost site4 station2 b1)
    (= (distance station2 site4) 1)
    (= (distance site4 station2) 1)

    ;; Site 4 <-> Site 5 (cost 1)
    (connected site4 site5)
    (connected site5 site4)
    (flight-cost site4 site5 b1)
    (flight-cost site5 site4 b1)
    (= (distance site4 site5) 1)
    (= (distance site5 site4) 1)

    ;; Site 2 <-> Site 5 (cost 2)
    (connected site2 site5)
    (connected site5 site2)
    (flight-cost site2 site5 b2)
    (flight-cost site5 site2 b2)
    (= (distance site2 site5) 2)
    (= (distance site5 site2) 2)

    ;; Site 3 <-> Site 4 (cost 2)
    (connected site3 site4)
    (connected site4 site3)
    (flight-cost site3 site4 b2)
    (flight-cost site4 site3 b2)
    (= (distance site3 site4) 2)
    (= (distance site4 site3) 2)

    ;; ==========================================
    ;; BATTERY TRANSITIONS
    ;; ==========================================

    ;; Flights costing 1 battery level
    (battery-after b1 b1 b0)
    (battery-after b2 b1 b1)
    (battery-after b3 b1 b2)
    (battery-after b4 b1 b3)
    (battery-after b5 b1 b4)
    (battery-after b6 b1 b5)

    ;; Flights costing 2 battery levels
    (battery-after b2 b2 b0)
    (battery-after b3 b2 b1)
    (battery-after b4 b2 b2)
    (battery-after b5 b2 b3)
    (battery-after b6 b2 b4)

    ;; ==========================================
    ;; RECHARGING
    ;; ==========================================

    ;; Model B: incremental recharge
    (next-level b0 b1)
    (next-level b1 b2)
    (next-level b2 b3)
    (next-level b3 b4)
    (next-level b4 b5)
    (next-level b5 b6)

    ;; Model A: full recharge
    (max-level b6)

    ;; Initial total cost
    (= (total-cost) 0)
  )

  (:goal
    (and
      ;; Four inspections
      (inspected site1)
      (inspected site2)
      (inspected site3)
      (inspected site4)

      ;; Three deliveries
      (delivered med1 site3)
      (delivered water1 site4)
      (delivered comm1 site5)
    )
  )

  (:metric minimize (total-cost))
)

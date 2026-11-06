
(define (problem emergency-small)
  (:domain EMERGENCY-DRONES)

  (:objects
    drone1 - drone

    depot station site1 site2 site3 - location

    med1 - medkit

    b0 b1 b2 b3 b4 - level
  )

  (:init
    ;; Initial drone state
    (at drone1 depot)
    (empty drone1)
    (battery drone1 b4)

    ;; All locations are initially accessible
    (accessible depot)
    (accessible station)
    (accessible site1)
    (accessible site2)
    (accessible site3)

    ;; Bidirectional flight connections
    (connected depot station)
    (connected station depot)

    (connected station site1)
    (connected site1 station)

    (connected station site2)
    (connected site2 station)

    (connected site2 site3)
    (connected site3 site2)

    ;; Flight battery costs: 1 per edge
    (flight-cost depot station b1)
    (flight-cost station depot b1)

    (flight-cost station site1 b1)
    (flight-cost site1 station b1)

    (flight-cost station site2 b1)
    (flight-cost site2 station b1)

    (flight-cost site2 site3 b1)
    (flight-cost site3 site2 b1)

    ;; Flight action costs
    (= (distance depot station) 1)
    (= (distance station depot) 1)

    (= (distance station site1) 1)
    (= (distance site1 station) 1)

    (= (distance station site2) 1)
    (= (distance site2 station) 1)

    (= (distance site2 site3) 1)
    (= (distance site3 site2) 1)

    ;; Charging station
    (charging-station station)

    ;; Medical supply and delivery request
    (supply-at med1 depot)
    (needs site3 med1)

    ;; Valid battery subtraction: before - cost = after
    (battery-after b1 b1 b0)
    (battery-after b2 b1 b1)
    (battery-after b3 b1 b2)
    (battery-after b4 b1 b3)

    ;; Battery increments for Model B
    (next-level b0 b1)
    (next-level b1 b2)
    (next-level b2 b3)
    (next-level b3 b4)

    ;; Maximum battery capacity
    (max-level b4)

    ;; Initial total plan cost
    (= (total-cost) 0)
  )

  (:goal
    (and
      (inspected site1)
      (inspected site2)
      (delivered med1 site3)
    )
  )

  (:metric minimize (total-cost))
)

(define (domain EMERGENCY-DRONES)

  (:requirements
    :strips                   ; actions with preconditions and add/delete effects
    :typing                   ; typed parameters (drone, location, ...)
    :negative-preconditions   ; (not (inspected ?l)) and (not (max-level ?cur))
    :conditional-effects      ; forall/when to unlock locations
    :action-costs)            ; (total-cost) for the plan cost

  (:types
    drone location supply level - object
    medkit water commdevice - supply)

  (:predicates
    (at ?d - drone ?l - location)                  ; where is the drone
    (empty ?d - drone)                             ; no supplies 
    (carrying ?d - drone ?s - supply)              ; what supply is carrying the drone
    (battery ?d - drone ?b - level)          ; current battery level for drone

    ;; localtions connection and charging stations
    (connected ?from ?to - location)             
    (charging-station ?l - location)               ; where a drone can recharge

    ;; localtion status
    (accessible ?l - location)                  ; a drone can enter
    (inspected ?l - location)                      ; localtion has already been inspected

    ;; supply status
    (supply-at ?s - supply ?l - location)          ; ?s is on the ground at ?l
    (needs ?l - location ?s - supply)              ; ?l is waiting for this specific supply ?s
    (delivered ?s - supply ?l - location)          ; ?s has already been delivered to ?l

    ;; unlocked dependencies
    (unlocked-by-inspection ?x ?y - location)      ; inspecting ?x unlocks ?y
    (unlocked-by-delivery ?x ?y - location)        ; delivering at ?x unlocks ?y

    ;; simulate the increment and reduction of battery levels
    (flight-cost ?from ?to - location ?c - level)  ; flying ?from -> ?to costs ?c levels
    (battery-after ?before ?c ?left - level)       ; ?before - ?c = ?left (only if >= 0)
    (next-level ?l1 ?l2 - level)                   ; ?l2 = ?l1 + 1 
    (max-level ?l - level))                        ; full battery capacity

  (:functions
    (total-cost) - number                          ; plan cost (minimized)
    (distance ?from ?to - location) - number)      ; cost of a flight

  ;; level to measure batter
  (:action fly
    :parameters (?d - drone ?from ?to - location ?before ?c ?left - level)
    :precondition (and
      (at ?d ?from)
      (connected ?from ?to)
      (accessible ?to)                             ; the drone cannot enter blocked locations
      (battery ?d ?before)
      (flight-cost ?from ?to ?c)
      (battery-after ?before ?c ?left))            ; check battery is enough

      (not (at ?d ?from))
      (at ?d ?to)
      (not (battery ?d ?before))
      (battery ?d ?left)
      (increase (total-cost) (distance ?from ?to))))

  ;; inspects its current location; may unlock other locations
  (:action inspect
    :parameters (?d - drone ?l - location)
    :precondition (and
      (at ?d ?l)
      (not (inspected ?l)))                        ; avoids useless repeated inspections
    :effect (and
      (inspected ?l)
      (forall (?y - location)
        (when (unlocked-by-inspection ?l ?y)
          (accessible ?y)))
      (increase (total-cost) 1)))


  (:action pick-up-supply
    :parameters (?d - drone ?s - supply ?l - location)
    :precondition (and
      (at ?d ?l)
      (supply-at ?s ?l)
      (empty ?d))                                  ; carries at most one supply
    :effect (and
      (not (supply-at ?s ?l))
      (not (empty ?d))
      (carrying ?d ?s)
      (increase (total-cost) 1)))

  ;; where is needed and unlocked locations
  (:action deliver-supply
    :parameters (?d - drone ?s - supply ?l - location)
    :precondition (and
      (at ?d ?l)
      (carrying ?d ?s)
      (needs ?l ?s))                             ; mandatory to the location that needs the supply
    :effect (and
      (not (carrying ?d ?s))
      (empty ?d)
      (not (needs ?l ?s))
      (delivered ?s ?l)
      (forall (?y - location)
        (when (unlocked-by-delivery ?l ?y)
          (accessible ?y)))
      (increase (total-cost) 1)))

  ;; this is the only action that differs from Model B
  (:action recharge
    :parameters (?d - drone ?l - location ?l1 ?l2 - level)
    :precondition (and
      (at ?d ?l)
      (charging-station ?l)
      (battery ?d ?l1)
      (next-level ?l1 ?l2)                
    :effect (and
      (not (battery ?d ?l1))
      (battery ?d ?l2)
      (increase (total-cost) 1)))
)

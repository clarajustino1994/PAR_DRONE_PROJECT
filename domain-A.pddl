;; =====================================================================
;; Emergency-response drones -- MODEL A (full recharge)
;; One recharge action sets the battery directly to the maximum level,
;; whatever the current level. Everything except the recharge action is
;; identical to Model B (domain-B.pddl), so both models share the same
;; problem files.
;; =====================================================================
(define (domain EMERGENCY-DRONES)

  (:requirements
    :strips                   ; actions with preconditions and add/delete effects
    :typing                   ; typed parameters (drone, location, ...)
    :negative-preconditions   ; (not (inspected ?l)) and (not (max-level ?cur))
    :conditional-effects      ; forall/when to unlock locations
    :action-costs)            ; (total-cost) for the plan cost

  (:types
    drone location supply level - object
    medkit water commdevice - supply)              ; kinds of supply

  (:predicates
    ;; drone state
    (at ?d - drone ?l - location)                  ; current location of the drone
    (empty ?d - drone)                             ; the drone carries no supply
    (carrying ?d - drone ?s - supply)              ; supply carried by the drone
    (battery ?d - drone ?b - level)                ; current battery level of the drone

    ;; map (static)
    (connected ?from ?to - location)               ; a direct flight ?from -> ?to exists
    (charging-station ?l - location)               ; a drone can recharge at ?l

    ;; location status
    (accessible ?l - location)                     ; a drone may enter ?l
    (inspected ?l - location)                      ; ?l has already been inspected

    ;; supply status
    (supply-at ?s - supply ?l - location)          ; ?s is on the ground at ?l
    (needs ?l - location ?s - supply)              ; ?l is waiting for this specific supply ?s
    (delivered ?s - supply ?l - location)          ; ?s has been delivered to ?l

    ;; unlock dependencies (static)
    (unlocked-by-inspection ?x ?y - location)      ; inspecting ?x unlocks ?y
    (unlocked-by-delivery ?x ?y - location)        ; delivering at ?x unlocks ?y

    ;; symbolic battery arithmetic (static)
    (flight-cost ?from ?to - location ?c - level)  ; flying ?from -> ?to costs ?c levels
    (battery-after ?before ?c ?left - level)       ; ?before - ?c = ?left (listed only if >= 0)
    (next-level ?l1 ?l2 - level)                   ; ?l2 = ?l1 + 1 (declared so both models share the problem files; not used in Model A)
    (max-level ?l - level))                        ; full battery capacity

  (:functions
    (total-cost) - number                          ; plan cost (minimized)
    (distance ?from ?to - location) - number)      ; static plan cost of a flight

  ;; fly: move ?d from ?from to the connected and accessible location ?to.
  ;; The flight is possible only if battery-after ?before ?c ?left exists,
  ;; i.e. the battery is at least the flight cost. Plan cost += distance.
  (:action fly
    :parameters (?d - drone ?from ?to - location ?before ?c ?left - level)
    :precondition (and
      (at ?d ?from)
      (connected ?from ?to)
      (accessible ?to)                             ; locked locations cannot be entered
      (battery ?d ?before)
      (flight-cost ?from ?to ?c)
      (battery-after ?before ?c ?left))            ; only exists if ?before >= ?c
    :effect (and
      (not (at ?d ?from))
      (at ?d ?to)
      (not (battery ?d ?before))
      (battery ?d ?left)
      (increase (total-cost) (distance ?from ?to))))

  ;; inspect: ?d inspects its current location ?l. Every location ?y with
  ;; (unlocked-by-inspection ?l ?y) becomes accessible. Plan cost += 1.
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

  ;; pick-up-supply: an empty drone loads a supply lying at its location.
  ;; Capacity is one supply per drone. Plan cost += 1.
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

  ;; deliver-supply: ?d hands the supply ?s to the location ?l that needs
  ;; exactly that object. Every location ?y with (unlocked-by-delivery ?l ?y)
  ;; becomes accessible. Plan cost += 1.
  (:action deliver-supply
    :parameters (?d - drone ?s - supply ?l - location)
    :precondition (and
      (at ?d ?l)
      (carrying ?d ?s)
      (needs ?l ?s))                               ; only where this supply is needed
    :effect (and
      (not (carrying ?d ?s))
      (empty ?d)
      (not (needs ?l ?s))                          ; the request is satisfied
      (delivered ?s ?l)
      (forall (?y - location)
        (when (unlocked-by-delivery ?l ?y)
          (accessible ?y)))
      (increase (total-cost) 1)))

  ;; recharge (MODEL A): at a charging station, set the battery directly to
  ;; the maximum level. This is the only action that differs from Model B.
  ;; Plan cost += 1.
  (:action recharge
    :parameters (?d - drone ?l - location ?cur ?max - level)
    :precondition (and
      (at ?d ?l)
      (charging-station ?l)
      (battery ?d ?cur)
      (max-level ?max)
      (not (max-level ?cur)))                      ; do not recharge if already full
    :effect (and
      (not (battery ?d ?cur))
      (battery ?d ?max)
      (increase (total-cost) 1)))
)

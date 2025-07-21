#lang typed/racket/base

(require "./types.rkt"
         guard
         racket/bool
         )

(provide (except-out (all-defined-out) default-execute-move))

(define (default-execute-move 
          [env : battle-env]
          #:stat-diff [stat-diff : battle-stats (battle-stats 0 0 0 0 0)]
          #:invulnerable? [invulnerable? : Boolean #f]
          #:recoil [recoil : (Option Positive-Integer) #f])
  (let* ([opposing-target (opposing-target env)]
         [current-target (current-target env)]
         [chosen-move (entity-chosen-move current-target)])
    (guarded-block
      (guard (not (entity-fainted? opposing-target)) #:else 'Failed)
      (guard (not (or invulnerable? (entity-invulnerable? opposing-target))) #:else 'Missed)
      (guard (not (eq? (pmove-category chosen-move) 'Status)) #:else (status stat-diff opposing-target))

      (attack 2 100 'SuperEffective (or recoil 0)))))

; move definitions
(define defense-curl 
  (pmove 'DefenseCurl #f 40 #f #f 'Normal 'Status 0 1 
         (lambda ([env : battle-env]) 
           (status (battle-stats 0 1 0 0 0) (current-target env)))))

(define sucker-punch 
  (pmove 'SuckerPunch 80 5 100 #t 'Dark 'Physical 1 1 
         (lambda ([env : battle-env])
           (define opp-target (opposing-target env))

           (guarded-block
             (guard (nor (entity-attacked? opp-target)
                         (eq? (pmove-category (entity-chosen-move opp-target)) 'Status))
                    #:else 'Failed)

             (default-execute-move env)))))

(define tackle (pmove 'Tackle 40 25 100 #t 'Normal 'Physical 0 1 default-execute-move))


(module* test racket/base
  (require rackunit 
           racket/match
           "./types.rkt"
           (submod "./types.rkt" test-utils)
           (submod "." ".."))

  (define (construct-battle-env 
          #:enemy [enemy (construct-entity #:chosen-move tackle)]
          #:player [player (construct-entity #:chosen-move tackle)]
          #:players-turn? [players-turn? #t])
    (battle-env enemy player players-turn?))

  (define-simple-check (check-failed? f v) (check-eq? (f v) 'Failed))
  (define-simple-check (check-missed? f v) (check-eq? (f v) 'Missed))
  
  ; start of test cases
  (test-case "defense curl tests"
    (define player-entity (construct-entity #:chosen-move defense-curl))
    (define execute-dc (pmove-execute defense-curl))
    (define args 
      (list (execute-dc (construct-battle-env #:player player-entity #:enemy (construct-entity #:chosen-move defense-curl #:fainted? #t)))
            (execute-dc (construct-battle-env #:player player-entity #:enemy (construct-entity #:chosen-move defense-curl #:underground? #t)))))

    (for-each (lambda (result)
                (match result 
                  [(status diff target)
                    (check-match diff (battle-stats 0 1 0 0 0))
                    (check-equal? player-entity (status-target result))]
                  [else (fail "Not a status return type")]))
              args))

  (test-case "sucker punch tests"
    (define execute-sp (pmove-execute sucker-punch))
    (define player (construct-entity #:chosen-move tackle))

    (check-failed? execute-sp (construct-battle-env #:enemy (construct-entity #:chosen-move sucker-punch #:attacked? #t) #:player player))
    (check-pred attack? (execute-sp (construct-battle-env #:enemy (construct-entity #:chosen-move sucker-punch) #:player player)))
  )
  )


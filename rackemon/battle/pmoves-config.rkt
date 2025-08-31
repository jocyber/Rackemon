#lang typed/racket/base

(require "./types.rkt"
         "./pmoves-execute.rkt")

(provide (all-defined-out))

(module+ test
  (require typed/rackunit 
           (submod "./types.rkt" test-utils)))

(define tackle (pmove 'Tackle 40 25 100 #t 'Normal 'Physical 0 1 execute-tackle))


(define defense-curl (pmove 'DefenseCurl #f 40 #f #f 'Normal 'Status 0 1 execute-defense-curl))

(module+ test 
  (test-case 
    "defense curl tests"

    (define execute-dc (pmove-execute defense-curl))
    (define player-entity (construct-entity #:chosen-move defense-curl))

    (check-pred status? (execute-dc (construct-battle-env #:player player-entity)))
    (test-equal? "It can still be executed when the enemy has fainted"
                 (execute-dc (construct-battle-env #:player player-entity #:enemy (construct-entity #:fainted? #t)))
                 (status (battle-stats 0 1 0 0 0) player-entity))))
             

(define sucker-punch (pmove 'SuckerPunch 80 5 100 #t 'Dark 'Physical 1 1 execute-sucker-punch))

(module+ test
  (test-case
    "sucker punch tests"

    (define execute-sp (pmove-execute sucker-punch))

    (test-eq? "It should fail if the enemy already attacked"
              (execute-sp (construct-battle-env #:enemy (construct-entity #:chosen-move tackle #:attacked? #t)))
              'Failed)
    (test-eq? "It should fail if the enemy chose a non-attacking move"
              (execute-sp (construct-battle-env #:enemy (construct-entity #:chosen-move defense-curl)))
              'Failed)
    (check-pred attack? (execute-sp (construct-battle-env #:enemy (construct-entity #:chosen-move tackle))))
    (test-pred "It should pass if the enemy does not have a chosen move" 
               attack? (execute-sp (construct-battle-env #:enemy (construct-entity))))
    ))


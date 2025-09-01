#lang typed/racket

(require "./types.rkt"
         "./pmoves-execute.rkt")

(provide (all-defined-out))

(module+ test
  (require typed/rackunit
           racket/math
           racket/function
           (submod "./types.rkt" test-utils))

  (define ((execute-move [move : pmove]) [env : battle-env]) : Move-Info
    (cdar ((pmove-execute move) env)))

  (define ((execute-multihit-move [move : pmove]) [env : battle-env]) : (Listof Move-Info)
    (map (lambda ([info : Execution-Info]) (cdr info)) ((pmove-execute move) env)))
  )


; move definitions
(define tackle (pmove 'Tackle 40 25 100 #t 'Normal 'Physical 0 1 execute-tackle))
(define defense-curl (pmove 'DefenseCurl #f 40 #f #f 'Normal 'Status 0 1 execute-defense-curl))

(module+ test 
  (test-case 
    "defense curl tests"
    (define execute-dc (execute-move defense-curl))

    (check-pred status? (execute-dc (construct-battle-env)))
    (test-pred "It can still be executed when the enemy has fainted"
               status? (execute-dc (construct-battle-env #:enemy (construct-entity #:fainted? #t))))
    ))
             

(define sucker-punch (pmove 'SuckerPunch 80 5 100 #t 'Dark 'Physical 1 1 execute-sucker-punch))

(module+ test
  (test-case
    "sucker punch tests"
    (define execute-sp (execute-move sucker-punch))

    (test-eq? "It should fail if the enemy already attacked"
              (execute-sp (construct-battle-env #:enemy (construct-entity #:chosen-move tackle #:attacked? #t)))
              'Failed)
    (test-eq? "It should fail if the enemy chose a non-attacking move"
              (execute-sp (construct-battle-env #:enemy (construct-entity #:chosen-move defense-curl)))
              'Failed)
    (check-pred attack? (execute-sp (construct-battle-env #:player (construct-entity #:chosen-move tackle)
                                                          #:enemy (construct-entity #:chosen-move tackle))))
    (test-pred "It should pass if the enemy does not have a chosen move" 
               attack? (execute-sp (construct-battle-env #:player (construct-entity #:chosen-move tackle)
                                                         #:enemy (construct-entity))))
    ))


(define aerial-ace (pmove 'AerialAce 60 20 +inf.0 #t 'Flying 'Physical 0 1 execute-aerial-ace))

(module+ test
  (test-case
    "aerial ace tests"
    (define execute-aa (execute-move aerial-ace))
    (define result (execute-aa (construct-battle-env #:player (construct-entity #:chosen-move aerial-ace))))

    (test-pred 
      "It should return infinite accuracy"
      (lambda (r) (and (attack? r) (infinite? (attack-accuracy r))))
      result)
    ))


(define bullet-seed (pmove 'BulletSeed 25 30 100 #f 'Grass 'Physical 0 1 execute-bullet-seed))

(module+ test 
  (test-case
    "Bullet seed tests"
    (define execute-bs (execute-multihit-move bullet-seed))
    (define result (execute-bs (construct-battle-env #:player (construct-entity #:chosen-move bullet-seed))))

    (test-pred
      "It hits at least once when accuracy is 100%"
      (lambda ([l : (Listof Move-Info)]) (>= (length l) 1))
      result)
    (test-pred
      "It hits at most 5 times"
      (lambda ([l : (Listof Move-Info)]) (<= (length l) 5))
      result)
    (test-pred
      "It monotonically decreases accuracy"
      (lambda ([l : (Listof Move-Info)])
        (for/and ([res1 (in-list l)]
                  [res2 (in-list (cdr l))]) : Boolean
          (assert res1 attack?)
          (assert res2 attack?)
          
          (>= (attack-accuracy res1) (attack-accuracy res2))))
      result)
    ))


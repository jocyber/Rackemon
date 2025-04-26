#lang typed/racket/base

(require "./battle/env.rkt"
         "./types/pmoves.rkt"
         "./types/ptypes.rkt")

(module+ test 
  (require/typed rackunit
                 [check-eq? (->* (Any Any) (String) Void)])
  (require (submod "./battle/env.rkt" test-utils)))

(provide (except-out (all-defined-out) default-execute-move))

(define-type Move-Execution-Result
  (U attack status 'Failed 'Missed 'OntHitKnockOut))
(define-type Execute-Move (-> battle-env Move-Execution-Result))

(struct attack 
  ([damage : Positive-Integer] 
   [accuracy : Nonnegative-Integer] 
   [effectiveness : Effectiveness]))

(struct status ([stat-diff : Integer] [target : entity]))


(: execute-defense-curl Execute-Move)
(define (execute-defense-curl env) 'Failed)

(module+ test)


(: execute-sucker-punch Execute-Move)
(define (execute-sucker-punch env)
  (let ([opposing-target (opposing-target env)])
    (cond [(or (entity-attacked? opposing-target)
               (eq? (pmove-category (entity-chosen-move opposing-target)) 'Status))
           'Failed]
          [else (default-execute-move env)])))

(module+ test
  (define sp execute-sucker-punch)

  (check-eq? 'Failed (sp (construct-battle-env #:enemy (construct-entity #:attacked? #t))))
  (check-eq? 'Failed (sp (construct-battle-env #:enemy (construct-entity #:chosen-move defense-curl)))))


(: execute-tackle Execute-Move)
(define (execute-tackle env) 'Failed)

(module+ test)


; specifies how a regular move should behave
(: default-execute-move Execute-Move)
(define (default-execute-move env) 'Missed)



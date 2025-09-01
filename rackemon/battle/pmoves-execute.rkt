#lang typed/racket/base

(require "./types.rkt"
         guard 
         racket/bool 
         racket/list
         )
(require/typed racket/base
               [in-inclusive-range (-> Real Real (Sequenceof Real))])
(require/typed racket/list
               [flatten (All (A) (-> (Listof (Listof A)) (Listof A)))])

(provide (except-out (all-defined-out) default-execute-move))

(define (default-execute-move 
          [env : battle-env]
          #:accuracy [accuracy : (Option Exact-Rational) #f]
          #:damage [damage : (Option Positive-Integer) #f]
          #:invulnerable? [invulnerable? : Boolean #f]
          #:recoil [recoil : (Option Positive-Integer) #f]) : Move-Execution-Result
  (let* ([opposing-target (opposing-target env)]
         [current-target (current-target env)]
         [chosen-move (entity-chosen-move current-target)])
    `((,env .
       ,(guarded-block
          (guard (not (entity-fainted? opposing-target)) #:else 'Failed)
          (guard (not (or invulnerable? (entity-invulnerable? opposing-target))) #:else 'Missed)
          (guard (pmove? chosen-move) #:else 'Failed)

          (attack 2 (or accuracy (pmove-accuracy chosen-move) +inf.0) 'SuperEffective (or recoil 0)))))))


(: execute-defense-curl (-> battle-env Move-Execution-Result))
(define (execute-defense-curl env) `((,env . ,(status (battle-stats 0 1 0 0 0) (current-target env)))))

(: execute-sucker-punch (-> battle-env Move-Execution-Result))
(define/guard (execute-sucker-punch env)
  (define opp-target (opposing-target env))

  (guard (nor (entity-attacked? opp-target)
              (let ([maybe-chosen-move (entity-chosen-move opp-target)])
                (and maybe-chosen-move (eq? 'Status (pmove-category maybe-chosen-move)))))
         #:else `((,env . Failed)))

  (default-execute-move env))

(define execute-tackle default-execute-move)
(define execute-aerial-ace default-execute-move)

(: execute-bullet-seed (-> battle-env Move-Execution-Result))
(define (execute-bullet-seed env)
  (define hit-attempts
    (flatten
      (for/list : (Listof Move-Execution-Result)
                ([hit    (in-inclusive-range 2 (random 2 6))]
                 [chance (in-list (list 3/8 3/8 1/8 1/8))])
        (default-execute-move env #:accuracy chance))))
  (define-values (hits misses) (splitf-at hit-attempts attack?))

  (append (default-execute-move env)
          hits 
          (if (empty? misses) '() (take misses 1))))
      

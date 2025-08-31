#lang typed/racket/base

(require "./types.rkt"
         guard 
         racket/bool)

(provide (except-out (all-defined-out) default-execute-move))

(define (default-execute-move 
          [env : battle-env]
          #:invulnerable? [invulnerable? : Boolean #f]
          #:recoil [recoil : (Option Positive-Integer) #f])
  (let* ([opposing-target (opposing-target env)]
         [current-target (current-target env)]
         [chosen-move (entity-chosen-move current-target)])
    (guarded-block
      (guard (not (entity-fainted? opposing-target)) #:else 'Failed)
      (guard (not (or invulnerable? (entity-invulnerable? opposing-target))) #:else 'Missed)

      (attack 2 100 'SuperEffective (or recoil 0)))))


(: execute-defense-curl (-> battle-env Move-Execution-Result))
(define (execute-defense-curl env) (status (battle-stats 0 1 0 0 0) (current-target env)))

(: execute-sucker-punch (-> battle-env Move-Execution-Result))
(define/guard (execute-sucker-punch env)
  (define opp-target (opposing-target env))

  (guard (nor (entity-attacked? opp-target)
              (let ([maybe-chosen-move (entity-chosen-move opp-target)])
                (and maybe-chosen-move (eq? 'Status (pmove-category maybe-chosen-move)))))
         #:else 'Failed)

  (default-execute-move env))

(: execute-tackle (-> battle-env Move-Execution-Result))
(define execute-tackle default-execute-move)


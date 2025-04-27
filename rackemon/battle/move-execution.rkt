#lang racket/base

(module results typed/racket/base
  (require "../types/ptypes.rkt"
           "./env.rkt")

  (provide (all-defined-out))

  (struct attack 
    ([damage        : Positive-Integer] 
     [accuracy      : Nonnegative-Integer] 
     [effectiveness : Effectiveness] 
     [recoil        : (Option Positive-Integer)]))
  (struct status 
    ([stat-diff : battle-stats] 
     [target    : entity])))

(require "./env.rkt"
         "../types/pmoves.rkt"
         'results)

(module+ test 
  (require rackunit
           racket/function
           (submod "./env.rkt" test-utils)))

(provide (except-out (all-defined-out) default-execute-move))


; specifies how a regular move should behave
(define (default-execute-move 
          env
          #:stat-diff [stat-diff (battle-stats 0 0 0 0 0)])
  (let ([opposing-target (opposing-target env)])
    (cond [(entity-fainted? opposing-target) 'Failed]
          )))


(define (execute-defense-curl env) (status (battle-stats 0 1 0 0 0) (current-target env)))

(module+ test 
  (define execute-dc (compose1 execute-defense-curl construct-battle-env))

  (test-begin
    (define player-entity (construct-entity #:chosen-move defense-curl))
    (define result (execute-dc #:player player-entity #:enemy (construct-entity #:fainted? #t)))

    (check-pred status? result)
    (check-eq? 1 (battle-stats-defense (status-stat-diff result)))
    (check-equal? player-entity (status-target result))))


(define (execute-sucker-punch env)
  (let ([opposing-target (opposing-target env)])
    (cond [(or (entity-attacked? opposing-target)
               (eq? (pmove-category (entity-chosen-move opposing-target)) 'Status))
           'Failed]
          [else (default-execute-move env)])))

(module+ test
  (define-simple-check (check-failed? env)
    (check-eq? 'Failed (execute-sucker-punch env)))

  (check-failed? (construct-battle-env #:enemy (construct-entity #:attacked? #t)))
  (check-failed? (construct-battle-env #:enemy (construct-entity #:chosen-move defense-curl))))


(define execute-tackle default-execute-move)

(module+ test)


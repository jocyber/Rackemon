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
         racket/undefined
         'results)

(module+ test 
  (require rackunit
           racket/function
           (submod "./env.rkt" test-utils)))

(provide (except-out (all-defined-out) default-execute-move))


; specifies how a regular move should behave
(define (default-execute-move 
          env
          #:stat-diff [stat-diff (battle-stats 0 0 0 0 0)]
          #:invulnerable? [invulnerable? undefined]
          #:recoil [recoil #f])
  (let* ([opposing-target (opposing-target env)]
         [current-target (current-target env)]
         [chosen-move (entity-chosen-move current-target)])
    (cond [(entity-fainted? opposing-target) 'Failed]
          [(if (eq? invulnerable? undefined) 
               (entity-invulnerable? opposing-target) 
               invulnerable?)
           'Missed]
          [(eq? (pmove-category chosen-move) 'Status)
           (status stat-diff opposing-target)]
          [else (attack 2 ; damage
                        100 ; accuracy
                        'SuperEffective
                        recoil)])))

(module+ test 
  (define-simple-check (check-failed? f env)
    (check-eq? 'Failed (f env)))
  (define-simple-check (check-missed? f env)
    (check-eq? 'Missed (f env)))

  (check-failed? default-execute-move (construct-battle-env #:enemy (construct-entity #:fainted? #t)))
  (check-missed? default-execute-move (construct-battle-env #:enemy (construct-entity #:in-air? #t))))


(define (execute-defense-curl env) (status (battle-stats 0 1 0 0 0) (current-target env)))

(module+ test 
  (define execute-dc (compose1 execute-defense-curl construct-battle-env))
  (define player-entity (construct-entity #:chosen-move defense-curl))

  (test-begin
    (define result (execute-dc #:player player-entity #:enemy (construct-entity #:fainted? #t)))

    (check-pred status? result)
    (check-eq? 1 (battle-stats-defense (status-stat-diff result)))
    (check-equal? player-entity (status-target result)))

  (test-begin
    (define result (execute-dc #:player player-entity #:enemy (construct-entity #:underground? #t)))

    (check-pred status? result)))


(define (execute-sucker-punch env)
  (let ([opposing-target (opposing-target env)])
    (cond [(or (entity-attacked? opposing-target)
               (eq? (pmove-category (entity-chosen-move opposing-target)) 'Status))
           'Failed]
          [else (default-execute-move env)])))

(module+ test
  (check-failed? execute-sucker-punch (construct-battle-env #:enemy (construct-entity #:attacked? #t)))
  (check-failed? execute-sucker-punch 
                 (construct-battle-env #:enemy (construct-entity #:chosen-move defense-curl))))


(define execute-tackle default-execute-move)


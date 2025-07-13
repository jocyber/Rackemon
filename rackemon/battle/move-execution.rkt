#lang typed/racket/base

(require "./env.rkt"
         "../types/pmoves.rkt"
         "../types/ptypes.rkt"
         guard
         )

(module+ test 
  (require typed/rackunit 
           racket/match
           racket/function
           (submod "./env.rkt" test-utils)))

(provide (except-out (all-defined-out) default-execute-move))

(define-type Move-Execution-Result (U attack status 'Failed 'Missed))

(struct attack 
  ([damage        : Positive-Integer] 
   [accuracy      : Nonnegative-Integer] 
   [effectiveness : Effectiveness] 
   [recoil        : Nonnegative-Integer]))
(struct status 
  ([stat-diff : battle-stats] 
   [target    : entity]))

; specifies how a regular move should behave
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

(module+ test
  (define check-failed? (curry check-eq? 'Failed))
  (define check-missed? (curry check-eq? 'Missed))

  (check-failed? (default-execute-move (construct-battle-env #:enemy (construct-entity #:fainted? #t))))
  (check-missed? (default-execute-move (construct-battle-env #:enemy (construct-entity #:in-air? #t)))))


(: execute-defense-curl (-> battle-env Move-Execution-Result))
(define (execute-defense-curl env) (status (battle-stats 0 1 0 0 0) (current-target env)))

(module+ test 
  (define player-entity (construct-entity #:chosen-move defense-curl))

  (test-begin
    (define result (execute-defense-curl (construct-battle-env #:player player-entity #:enemy (construct-entity #:fainted? #t))))

    (check-pred status? result)
    (check-eq? 1 (battle-stats-defense 
                   (match result 
                     [(status diff _) diff]
                     [_ (error "Not a status type")])))
    (check-equal? player-entity 
                    (match result 
                      [(status _ target) target]
                      [_ (error "Not pokemon target")])))

  (test-begin
    (define result (execute-defense-curl (construct-battle-env #:player player-entity #:enemy (construct-entity #:underground? #t))))

    (check-pred status? result)))


(: execute-sucker-punch (-> battle-env Move-Execution-Result))
(define (execute-sucker-punch env)
  (let ([opposing-target (opposing-target env)])
    (cond [(or (entity-attacked? opposing-target)
               (eq? (pmove-category (entity-chosen-move opposing-target)) 'Status))
           'Failed]
          [else (default-execute-move env)])))

(module+ test
  (check-failed? (execute-sucker-punch (construct-battle-env #:enemy (construct-entity #:attacked? #t))))
  (check-failed? (execute-sucker-punch 
                   (construct-battle-env #:enemy (construct-entity #:chosen-move defense-curl)))))


(: execute-tackle (-> battle-env Move-Execution-Result))
(define execute-tackle default-execute-move)


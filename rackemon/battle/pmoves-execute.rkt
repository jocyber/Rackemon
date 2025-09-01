#lang typed/racket/base

(require "./types.rkt"
         guard 
         racket/bool 
         racket/list
         racket/match
         )

(provide (except-out (all-defined-out) default-execute-move))

(module+ test
  (require typed/rackunit
           racket/math
           racket/function
           "./pmoves-config.rkt"
           (submod "./types.rkt" test-utils))

  (define ((execute-move [f : (-> battle-env Move-Execution-Result)]) [env : battle-env]) : Move-Info 
    (cdar (f env)))

  (define ((execute-multihit-move [f : (-> battle-env Move-Execution-Result)]) [env : battle-env]) : (Listof Move-Info)
    (map (lambda ([info : Execution-Info]) (cdr info)) (f env)))
  )


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

(module+ test 
  (test-case 
    "defense curl tests"
    (define execute-dc (execute-move execute-defense-curl))

    (check-pred status? (execute-dc (construct-battle-env)))
    (test-pred "It can still be executed when the enemy has fainted"
               status? (execute-dc (construct-battle-env #:enemy (construct-entity #:fainted? #t))))
    ))
             

(: execute-sucker-punch (-> battle-env Move-Execution-Result))
(define/guard (execute-sucker-punch env)
  (define opp-target (opposing-target env))

  (guard (nor (entity-attacked? opp-target)
              (let ([maybe-chosen-move (entity-chosen-move opp-target)])
                (and maybe-chosen-move (eq? 'Status (pmove-category maybe-chosen-move)))))
         #:else `((,env . Failed)))

  (default-execute-move env))

(module+ test
  (test-case
    "sucker punch tests"
    (define execute-sp (execute-move execute-sucker-punch))

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


(define execute-tackle default-execute-move)
(define execute-aerial-ace default-execute-move)

(module+ test
  (test-case
    "aerial ace tests"
    (define execute-aa (execute-move execute-aerial-ace))
    (define result (execute-aa (construct-battle-env #:player (construct-entity #:chosen-move aerial-ace))))

    (test-pred 
      "It should return infinite accuracy"
      (lambda (r) (and (attack? r) (infinite? (attack-accuracy r))))
      result)
    ))


(: execute-bullet-seed (-> battle-env Move-Execution-Result))
(define (execute-bullet-seed env)
  (define percentage (/ (random 0 100) 100))
  (define hit-count
    (cond [(and (>= percentage 0)   (< percentage 3/8)) 2]
          [(and (>= percentage 3/8) (< percentage 6/8)) 3]
          [(and (>= percentage 6/8) (< percentage 7/8)) 4]
          [else 5]))

  (let loop ([hits    : Integer               hit-count]
             [res     : Move-Execution-Result '()])
    (cond [(zero? hits) (reverse res)]
          [(default-execute-move env) => 
             (lambda (execute-result)
               (match-define (list move-result) execute-result)
               (define move-info (cdr move-result))

               (cond [(attack? move-info) (loop (sub1 hits) (cons move-result res))]
                     [else (loop 0 (cons move-result res))]))])))

(module+ test 
  (test-case
    "Bullet seed tests"
    (define execute-bs (execute-multihit-move execute-bullet-seed))
    (define result (execute-bs (construct-battle-env #:player (construct-entity #:chosen-move bullet-seed))))

    (test-pred
      "It attempts a hit at least twice when accuracy is 100%"
      (lambda ([l : (Listof Move-Info)]) (>= (length l) 2))
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

    (define result2 (execute-bs (construct-battle-env #:player (construct-entity #:chosen-move bullet-seed)
                                                      #:enemy (construct-entity #:in-air? #t))))
    (test-equal? "It stops upon reaching a miss" result2 '(Missed))

    (define result3 (execute-bs (construct-battle-env #:player (construct-entity #:chosen-move bullet-seed)
                                                      #:enemy (construct-entity #:fainted? #t))))
    (test-equal? "It stops upon reaching a failure" result3 '(Failed))
    ))


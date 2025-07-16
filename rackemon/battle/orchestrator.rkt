#lang typed/racket/base

(require "./types.rkt"
         "../combinators.rkt"
         guard)

(: entity-order-by-priority (-> battle-env (Listof entity)))
(define (entity-order-by-priority battle-env)
  (define entity-priority (compose1 pmove-priority entity-chosen-move))
  ; TODO: change to calculated overall speed
  (define entity-speed (compose1 battle-stats-speed entity-stats))

  (define/guard (priority-comparator e1 e2)
    (guard (on eq? entity-priority) #:else (> (entity-priority e1) (entity-priority e2)))
    (guard (on eq? entity-speed) #:else (> (entity-speed e1) (entity-speed e2)))
    (zero? (random 2)))

  (sort (list (battle-env-player battle-env) (battle-env-enemy battle-env))
        priority-comparator))


(module* test racket/base
  (require rackunit)

  ;(test-case "move priority determines order")
    
  )

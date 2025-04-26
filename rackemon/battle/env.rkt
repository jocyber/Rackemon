#lang typed/racket/base

(provide (all-defined-out))

(require racket/function
         "../types/pmoves.rkt")

(struct battle-env
  ([enemy  : entity]
   [player : entity]
   [players-turn? : Boolean])
   #:mutable)

(: opposing-target (-> battle-env entity))
(define (opposing-target env)
  (if (battle-env-players-turn? env) 
      (battle-env-enemy env) 
      (battle-env-player env)))

(struct entity
  ([attacked?               : Boolean]
   [chosen-move             : pmove]
   [physical-screen-active? : Boolean]
   [special-screen-active?  : Boolean])
  #:mutable)


(module+ test-utils
  (provide (all-defined-out))

  (define (construct-entity 
            #:attacked? [attacked? : Boolean #f]
            #:chosen-move [chosen-move : pmove tackle]
            #:physical-screen-active? [physical-screen-active? : Boolean #f]
            #:special-screen-active? [special-screen-active? : Boolean #f]) : entity
    (entity attacked? chosen-move physical-screen-active? special-screen-active?))

  (define (construct-battle-env 
            #:enemy [enemy : entity (construct-entity)]
            #:player [player : entity (construct-entity)]
            #:players-turn? [players-turn? : Boolean #t]) : battle-env
    (battle-env enemy player players-turn?)))

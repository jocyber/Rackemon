#lang typed/racket/base

(provide (all-defined-out))

(require racket/function
         "../types/pmoves.rkt")

(struct battle-env
  ([enemy         : entity]
   [player        : entity]
   [players-turn? : Boolean])
   #:mutable)

(: opposing-target (-> battle-env entity))
(define (opposing-target env)
  (if (battle-env-players-turn? env) 
      (battle-env-enemy env) 
      (battle-env-player env)))

(: current-target (-> battle-env entity))
(define (current-target env)
  (if (battle-env-players-turn? env) 
      (battle-env-player env) 
      (battle-env-enemy env)))

(struct battle-stats
  ([attack          : Nonnegative-Integer]
   [defense         : Nonnegative-Integer]
   [special-attack  : Nonnegative-Integer]
   [special-defense : Nonnegative-Integer]
   [speed           : Nonnegative-Integer]))

(struct entity
  ([attacked?               : Boolean]
   [stats                   : battle-stats]
   [fainted?                : Boolean]
   [chosen-move             : pmove]
   [physical-screen-active? : Boolean]
   [special-screen-active?  : Boolean])
  #:mutable)


(module* test-utils racket/base
  (require (submod "..") "../types/pmoves.rkt")

  (provide (all-defined-out))

  (define (construct-entity 
            #:attacked? [attacked? #f]
            #:stats [stats (battle-stats 0 0 0 0 0)]
            #:fainted? [fainted? #f]
            #:chosen-move [chosen-move tackle]
            #:physical-screen-active? [physical-screen-active? #f]
            #:special-screen-active? [special-screen-active? #f])
    (entity attacked? stats fainted? chosen-move 
            physical-screen-active? special-screen-active?))

  (define (construct-battle-env 
            #:enemy [enemy (construct-entity)]
            #:player [player (construct-entity)]
            #:players-turn? [players-turn? #t])
    (battle-env enemy player players-turn?)))

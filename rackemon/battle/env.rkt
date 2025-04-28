#lang typed/racket/base

(provide (all-defined-out))

(require "../types/pmoves.rkt")

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
  ([attack          : Integer]
   [defense         : Integer]
   [special-attack  : Integer]
   [special-defense : Integer]
   [speed           : Integer])
  #:mutable)

(struct entity
  ([attacked?               : Boolean]
   [stats                   : battle-stats]
   [fainted?                : Boolean]
   [in-air?                 : Boolean]
   [underground?            : Boolean]
   [underwater?             : Boolean]
   [vanished?               : Boolean]
   [chosen-move             : pmove]
   [physical-screen-active? : Boolean]
   [special-screen-active?  : Boolean])
  #:mutable)

(: entity-invulnerable? (-> entity Boolean))
(define (entity-invulnerable? e)
  (ormap (lambda ([f : (-> entity Boolean)]) (f e))
         (list entity-in-air? entity-underground? 
               entity-underwater? entity-vanished?)))


(module* test-utils racket/base
  (require (submod "..") "../types/pmoves.rkt")

  (provide (all-defined-out))

  (define (construct-entity 
            #:attacked? [attacked? #f]
            #:stats [stats (battle-stats 0 0 0 0 0)]
            #:fainted? [fainted? #f]
            #:in-air? [in-air? #f]
            #:underground? [underground? #f]
            #:underwater? [underwater? #f]
            #:vanished? [vanished? #f]
            #:chosen-move [chosen-move tackle]
            #:physical-screen-active? [physical-screen-active? #f]
            #:special-screen-active? [special-screen-active? #f])
    (entity attacked? stats 
            fainted? in-air? underground? underwater? vanished? 
            chosen-move physical-screen-active? special-screen-active?))

  (define (construct-battle-env 
            #:enemy [enemy (construct-entity)]
            #:player [player (construct-entity)]
            #:players-turn? [players-turn? #t])
    (battle-env enemy player players-turn?)))

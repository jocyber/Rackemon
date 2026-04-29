#lang typed/racket/base

(require "../animations/types.rkt"
         "../pokemon/config.rkt"
         "../pokemon/types.rkt"
         "../types.rkt")

(provide (all-defined-out))

(define-type Move-Info (U attack status 'Failed 'Missed))
(define-type Execution-Info (Pairof battle-env Move-Info))
(define-type Move-Execution-Result (Listof Execution-Info))

(define-type Move-Category (U 'Physical 'Special 'Status))
(define-type Effectiveness
  (U 'SuperEffective 'NormallyEffective 'NotVeryEffective 'NotEffective))

(define-type Accuracy (U Exact-Rational +inf.0))
(define-type Turns (U Positive-Integer (Pairof Positive-Integer Positive-Integer)))
(define-type Entity-Flag (U 'Player 'Enemy))

(struct battle-env
  ([enemy         : entity]
   [player        : entity]
   [players-turn? : Boolean]
   [enemy-dt      : Nonnegative-Float]
   [player-dt     : Nonnegative-Float]
   )
  #:transparent
  )

(struct battle-stats
  ([attack          : Integer]
   [defense         : Integer]
   [special-attack  : Integer]
   [special-defense : Integer]
   [speed           : Integer])
  #:mutable
  #:transparent)

(struct entity
  ([pokemon                 : pokemon-instance]
   [flag                    : Entity-Flag]
   [attacked?               : Boolean]
   [stats                   : battle-stats]
   [fainted?                : Boolean]
   [in-air?                 : Boolean]
   [underground?            : Boolean]
   [underwater?             : Boolean]
   [vanished?               : Boolean]
   [chosen-move             : (Option pmove)]
   [move-history            : (Listof pmove)] ; should be a bounded-queue
   [position                : vector2d]
   [frame-offset            : Nonnegative-Float]
   [physical-screen-active? : Boolean]
   [special-screen-active?  : Boolean])
  #:mutable
  #:transparent)

(struct attack
  ([damage        : Positive-Integer]
   [accuracy      : Accuracy]
   [effectiveness : Effectiveness]
   [recoil        : Nonnegative-Integer])
  #:transparent)
(struct status
  ([stat-diff : battle-stats]
   [target    : entity])
  #:transparent)

(struct pmove
  ([name     : Symbol]
   [bp       : (Option Positive-Integer)]
   [pp       : Positive-Integer]
   [accuracy : (Option Accuracy)]
   [contact? : Boolean]
   [type     : (Option Pokemon-Type)]
   [category : Move-Category]
   [priority : Integer]
   [turns    : Turns])
  #:transparent)

(struct runnable-pmove
  ([execute        : (-> battle-env Move-Execution-Result)])
   ; [play-animation : (-> battle-env)])
   #:transparent)


(module+ utils
  (provide (all-defined-out))

  (: enemy-position (-> battle-env vector2d))
  (define (enemy-position env) (entity-position (battle-env-enemy env)))
  (: player-position (-> battle-env vector2d))
  (define (player-position env) (entity-position (battle-env-player env)))

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

  (: entity-invulnerable? (-> entity Boolean))
  (define (entity-invulnerable? e)
    (ormap (lambda ([f : (-> entity Boolean)]) (f e))
           (list entity-in-air? entity-underground?
                 entity-underwater? entity-vanished?)))

  (define (construct-entity
            #:pokemon (pokemon : pokemon piplup)
            #:flag [flag : Entity-Flag 'Player]
            #:attacked? [attacked? : Boolean #f]
            #:stats [stats : battle-stats (battle-stats 0 0 0 0 0)]
            #:fainted? [fainted? : Boolean #f]
            #:in-air? [in-air? : Boolean #f]
            #:underground? [underground? : Boolean #f]
            #:underwater? [underwater? : Boolean #f]
            #:vanished? [vanished? : Boolean #f]
            #:chosen-move [chosen-move : (Option pmove) #f]
            #:move-history [move-history : (Listof pmove) '()]
            #:position [position : vector2d (vector2d 0. 0.)]
            #:frame-offset [frame-offset : Nonnegative-Float 0.]
            #:physical-screen-active? [physical-screen-active? : Boolean #f]
            #:special-screen-active? [special-screen-active? : Boolean #f])
    (entity (pokemon-instance pokemon)
            flag
            attacked?
            stats
            fainted? in-air? underground? underwater? vanished?
            chosen-move move-history
            position frame-offset
            physical-screen-active? special-screen-active?
            ))

  (define (construct-battle-env
            #:enemy [enemy : entity (construct-entity #:flag 'Enemy)]
            #:player [player : entity (construct-entity #:flag 'Player)]
            #:players-turn? [players-turn? : Boolean #t]
            #:player-dt [player-dt : Nonnegative-Float 0.]
            #:enemy-dt [enemy-dt : Nonnegative-Float 0.]
            )
    (battle-env enemy player players-turn? player-dt enemy-dt))
  )

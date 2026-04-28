#lang racket/base

(require "../raylib.rkt"
         "../window.rkt"
         "./pmoves-animations.rkt"
         (submod "../raylib.rkt" utils)
         (submod "../raylib.rkt" colors)
         (submod "../raylib.rkt" structs)
         "../animations/primitives.rkt"
         "../animations/types.rkt"
         "../animations/player.rkt"
         "../pokemon/config.rkt"
         "../pokemon/types.rkt"
         "../utils/resources.rkt"
         "./types.rkt"
         racket/class
         (submod "./types.rkt" utils))

(define idle-animation-seconds 5.5)
(define origin (make-vector2 0. 0.))

(define (display-battle! env dt background player enemy)
  ; helpers
  (define (draw-entity! entity texture-info width height player?)
    (define multiplier (if player? 5. 3.))
    (define source (make-rect (entity-frame-offset entity) 0. width height))
    (define x (vector2d-x (entity-position entity)))
    (define y (vector2d-y (entity-position entity)))

    (when (eq? (entity-flag entity) 'Enemy)
      ; draw shadow
      (draw-texture-pro
        texture-info
        source (make-rect x (+ y 62.) (* width multiplier) (/ (* height multiplier) 2.))
        origin 0.
        (make-color 0 0 0 110)))

    (draw-texture-pro
      texture-info source (make-rect x y (* width multiplier) (* height multiplier)) origin 0. WHITE)
    )

  (draw-texture-ex background origin 0. 4. WHITE)

  (define enemy-entity (battle-env-enemy env))
  (define player-entity (battle-env-player env))

  (define enemy-pokemon (pokemon-instance-config (entity-pokemon enemy-entity)))
  (define player-pokemon (pokemon-instance-config (entity-pokemon player-entity)))

  (define player-expected-dt (/ idle-animation-seconds (pokemon-frame-count player-pokemon)))
  (define enemy-expected-dt (/ idle-animation-seconds (pokemon-frame-count enemy-pokemon)))

  (define enemy-width (pokemon-frame-width enemy-pokemon))
  (define player-width (pokemon-frame-width player-pokemon))
  (define enemy-height (pokemon-frame-height enemy-pokemon))
  (define player-height (pokemon-frame-height player-pokemon))

  (define enemy-dt (+ (battle-env-enemy-dt env) dt))
  (define player-dt (+ (battle-env-player-dt env) dt))

  (define new-enemy-dt
    (cond [(>= enemy-dt enemy-expected-dt)
           (set-entity-frame-offset! enemy-entity (+ (entity-frame-offset enemy-entity) enemy-width))
           (- enemy-dt enemy-expected-dt)]
          [else enemy-dt]))
  (define new-player-dt
    (cond [(>= player-dt player-expected-dt)
           (set-entity-frame-offset! player-entity (+ (entity-frame-offset player-entity) player-width))
           (- player-dt player-expected-dt)]
          [else player-dt]))

  (draw-entity! player-entity player player-width player-height #t)
  (draw-entity! enemy-entity enemy enemy-width enemy-height #f)

  (struct-copy battle-env env [player-dt new-player-dt] [enemy-dt new-enemy-dt]))


(module+ main
  (set-target-fps 60)

  (define initial-env
    (construct-battle-env
      #:players-turn? #f
      #:enemy
        (construct-entity
          #:pokemon zigzagoon
          #:flag 'Enemy
          #:position (vector2d (- window-width 335.) 145.)
          )
      #:player
        (construct-entity
          #:pokemon piplup
          #:flag 'Player
          #:position (vector2d 150. 270.)
          )))

  (define @tackle (new AnimationPlayer% [animations (tackle! initial-env)]))

  (call-with-window
    window-width window-height window-title initial-env
    (lambda (dt env background zigzagoon piplup)
      (send @tackle @play dt)
      (display-battle! env dt background piplup zigzagoon)
      )
    "resources/battle/backgrounds/grass_background.png"
    (pokemon-front-resource-path (pokemon-name zigzagoon))
    (pokemon-back-resource-path (pokemon-name piplup))
    )
  )

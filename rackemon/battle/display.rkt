#lang racket/base

(require "../raylib.rkt"
         "../window.rkt"
         "./pmoves-animations.rkt"
         guard
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
         racket/match 
         racket/class
         (submod "./types.rkt" utils))

(provide BattleDisplayer%)

(define idle-animation-seconds 5.)
(define origin (make-vector2 0. 0.))

; move texture-info to entity
(define BattleDisplayer%
  (class object%
    (super-new)

  (init-field env)
  (init-field player-pokemon)
  (init-field enemy-pokemon)

  ; mutable fields 
  (define player-dt 0.)
  (define enemy-dt 0.)

  ; constants
  (define player-expected-dt (/ idle-animation-seconds (pokemon-frame-count player-pokemon)))
  (define enemy-expected-dt (/ idle-animation-seconds (pokemon-frame-count enemy-pokemon)))

  (define/public (display-battle! dt background player enemy)
    (draw-texture-ex background origin 0. 4. WHITE)

    (define enemy-entity (battle-env-enemy env))
    (define player-entity (battle-env-player env))

    (define enemy-width (pokemon-frame-width enemy-pokemon))
    (define player-width (pokemon-frame-width player-pokemon))
    (define enemy-height (pokemon-frame-height enemy-pokemon))
    (define player-height (pokemon-frame-height player-pokemon))

    (set! enemy-dt (+ enemy-dt dt))
    (set! player-dt (+ player-dt dt))

    (when (>= enemy-dt enemy-expected-dt)
          (set-entity-frame-offset! enemy-entity (+ (entity-frame-offset enemy-entity) enemy-width))
          (set! enemy-dt (- enemy-dt enemy-expected-dt)))
    (when (>= player-dt player-expected-dt)
          (set-entity-frame-offset! player-entity (+ (entity-frame-offset player-entity) player-width))
          (set! player-dt (- player-dt player-expected-dt)))

    (draw-entity! player-entity player player-width player-height #t)
    (draw-entity! enemy-entity enemy enemy-width enemy-height #f)
    )

  (define/private (draw-entity! entity texture-info width height player?)
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
  ))


(module+ main
  (set-target-fps 60)

  (define initial-env 
    (construct-battle-env 
      #:players-turn? #f 
      #:enemy 
        (construct-entity
          #:flag 'Enemy
          #:position (vector2d (- window-width 335.) 145.)
          )
      #:player 
        (construct-entity
          #:flag 'Player 
          #:position (vector2d 150. 270.)
          )))

  (define displayer (new BattleDisplayer% 
                         [env initial-env]
                         [player-pokemon piplup]
                         [enemy-pokemon zigzagoon]))
  (define @tackle (new AnimationPlayer% [animations (tackle! initial-env)]))

  (call-with-window
    window-width window-height window-title initial-env
    (lambda (dt env background zigzagoon piplup)
      (send @tackle @play dt)
      (send displayer display-battle! dt background piplup zigzagoon)
      env)
    "resources/battle/backgrounds/grass_background.png"
    (pokemon-front-resource-path (pokemon-name zigzagoon))
    (pokemon-back-resource-path (pokemon-name piplup))
    )
  )

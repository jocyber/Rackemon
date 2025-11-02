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
         "./types.rkt"
         racket/match 
         racket/class
         (submod "./types.rkt" utils))

(provide display-battle)

(define animation-time-seconds 5.)
(define origin (make-vector2 0. 0.))

; move texture-info to entity
(define (draw-entity env entity texture-info width height)
  (define source (make-rect (entity-frame-offset entity) 0. width height))
  (define x (vector2d-x (entity-position entity)))
  (define y (vector2d-y (entity-position entity)))

  (when (eq? (entity-flag entity) 'Enemy)
    ; draw shadow
    (draw-texture-pro 
      texture-info 
      source (make-rect x (+ y 62.) (* width 3.) (* height 1.5))
      origin 0. 
      (make-color 0 0 0 110)))

  (draw-texture-pro 
    texture-info source (make-rect x y (* width 3.) (* height 3.)) origin 0. WHITE))

(define (display-battle background env dt enemy)
  (define num-frames 112)
  (define width 58.)
  (define height 42.)
  ; animation-time-seconds should be a property of the move animation
  (define expected-dt (/ animation-time-seconds num-frames))

  (draw-texture-ex background origin 0. 4. WHITE)
  (define enemy-entity (battle-env-enemy env))

  (define new-dt
    (guarded-block
      (guard (>= dt expected-dt) #:else dt)

      (set-entity-frame-offset! enemy-entity (+ (entity-frame-offset enemy-entity) width))
      (- dt expected-dt)
      ))

  (draw-entity env enemy-entity enemy width height)
  (values new-dt env))

(define player%
  (class object%
    (super-new)

    (init-field animations)

    (define/public (@play dt)
      (define (@update a)
        (cond [(eq? a 'AnimationEnd) 'AnimationEnd]
              [else (match-define (cons _ @new) (a dt))
                    @new]))

      (cond [(null? animations) 'AnimationEnd]
            [else 
              (define results (map @update (car animations)))

              (if (andmap (lambda (a) (eq? a 'AnimationEnd)) results)
                  (set! animations (cdr animations))
                  (set! animations (cons results (cdr animations))))]))
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
          )))

  (define @tackle (new player% [animations (tackle! initial-env)]))

  (call-with-window
    window-width window-height window-title initial-env
    (lambda (dt env background zigzagoon) 
      (send @tackle @play dt)
      (display-battle background env dt zigzagoon))
    "resources/battle/backgrounds/grass_background.png"
    "resources/pokemon/front/zigzagoon.png"
    )
  )

#lang racket/base

(require "../raylib.rkt"
         "../window.rkt"
         guard
         (submod "../raylib.rkt" utils)
         (submod "../raylib.rkt" colors)
         (submod "../raylib.rkt" structs))

(provide display-battle)

(define animation-time-seconds 5.)

(struct battle-state
   (enemy-frame-offset 
    ))

(define (display-enemy texture width height state)
  (draw-texture-pro 
    texture 
    (make-rect (battle-state-enemy-frame-offset state) 0. width height) 
    (make-rect (- window-width 340.) 140. (* width 3.) (* height 3.))
    (make-vector2 0. 0.) 
    0. WHITE))

(define (display-battle background state dt enemy) ; TODO: get enemy and player from battle-env
  (define num-frames 112)
  (define width 58.)
  (define height 42.)
  (define expected-dt (/ animation-time-seconds num-frames))

  (draw-texture-ex background (make-vector2 0. 0.) 0. 4. WHITE)

  (define-values (new-dt new-state)
    (guarded-block
      (guard (>= dt expected-dt) #:else (values dt state))

      (values
        (- dt expected-dt)
        (struct-copy battle-state state 
                     [enemy-frame-offset (+ (battle-state-enemy-frame-offset state) width)]))
      ))

  (display-enemy enemy width height new-state)
  (values new-dt new-state))

(module+ main
  (call-with-window
    window-width window-height window-title
    (battle-state 0.)
    (lambda (dt state background zigzagoon) 
      (display-battle background state dt zigzagoon))
    "resources/battle/backgrounds/grass_background.png"
    "resources/pokemon/front/zigzagoon.png"
    )
  )

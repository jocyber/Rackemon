#lang racket/base

(require "../raylib.rkt"
         "../window.rkt"
         guard
         (submod "../raylib.rkt" utils)
         (submod "../raylib.rkt" colors)
         (submod "../raylib.rkt" structs)
         "../animations/primitives.rkt"
         "../animations/types.rkt")

(provide display-battle)

(define animation-time-seconds 5.)

; move to pmove-animations
; create union type of parameterized animation types and pattern match on them
(define tackle
  `((,(glide (vector2d (- window-width 335.) 140.)
             (vector2d (- window-width 500.) 140.)
             1.5))
    (,(glide (vector2d (- window-width 500.) 140.)
             (vector2d (- window-width 335.) 140.)
             1.5))))

; move texture-info to entity
(define (draw-entity entity texture-info state)
  ; get position from entity
  (define position (battle-state-enemy-position state))

  ; draw the enemies shadow
  (draw-texture-pro 
    texture 
    (make-rect (battle-state-enemy-frame-offset state) 0. width height) 
    (make-rect (- window-width 335.) 200. (* width 3.) (* height 1.5))
    (make-vector2 0. 0.) 
    0. (make-color 0 0 0 110))
  ; draw enemy animation
  (draw-texture-pro 
    texture 
    (make-rect (battle-state-enemy-frame-offset state) 0. width height) 
    ; TODO: move to the glide function
    (make-rect (vector2d-x position) (vector2d-y position) (* width 3.) (* height 3.))
    (make-vector2 0. 0.) 
    0. WHITE))

(define (display-battle background state dt enemy) ; TODO: get enemy and player from battle-env
  (define num-frames 112)
  (define width 58.)
  (define height 42.)
  ; animation-time-seconds should be property of move animation
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
  (set-target-fps 60)

  (call-with-window
    window-width window-height window-title initial-battle-state
    (lambda (dt state background zigzagoon) 
      (match-define ())
      (set-battle-state-enemy-position! state )
      (display-battle background state dt zigzagoon))
    "resources/battle/backgrounds/grass_background.png"
    "resources/pokemon/front/zigzagoon.png"
    )
  )

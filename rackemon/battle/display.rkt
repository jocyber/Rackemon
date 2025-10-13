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

; make a super-struct that contains all the paths used within the cell
; this will help with dynamically unloading and loading in new textures
(struct battle-state
   (enemy-frame-offset 
    enemy-position
    )
   #:transparent
   #:mutable)

(define (display-enemy texture width height state)
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
  (define enemy-position (vector2d (- window-width 335.) 140.))
  (define enemy-glide (glide enemy-position
                             (vector2d (- window-width 500.) 140.)
                             3.))
  (define glide-result (enemy-glide 0.2))

  (call-with-window
    window-width window-height window-title
    (battle-state 0. enemy-position)
    (lambda (dt state background zigzagoon) 
      (unless (eq? glide-result 'AnimationEnd)
        (set-battle-state-enemy-position! state (car glide-result))
        (set! glide-result ((cdr glide-result) dt)))

      (display-battle background state dt zigzagoon))
    "resources/battle/backgrounds/grass_background.png"
    "resources/pokemon/front/zigzagoon.png"
    )
  )

#lang typed/racket/base

(require 
  (for-syntax "./primitives.rkt"
              "../raylib.rkt"
      ))

#|
example syntax: have the animation player helpers call (get-frame-time)
 battle-scene(background, music, playerTeam, enemyTeam) {
    entering-animation {
        wait 3.seconds
        glide player-sprite v(1 2) v(3 4) 2.seconds

        ; all played concurrently
        begin {
            ; animation 1
            ; animation 2
        }
    }

    battle {
       
    }  
 }
|#

; make these operations effectful, i.e actually redraw the entity
(define-syntax glide
  (syntax-rules ()
    [(glide entity start end seconds)
     #'((let loop ()
          (define-values (vec animation) (glide start end seconds))





; (begin-for-syntax)

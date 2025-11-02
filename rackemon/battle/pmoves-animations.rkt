#lang typed/racket/base

(require "../animations/primitives.rkt"
         "../window.rkt"
         "./types.rkt"
         "../animations/types.rkt"
         (submod "./types.rkt" utils))

(provide (all-defined-out))

(define-type Move-Animation (Animations-List Void))
(define-type Update-Pos (-> battle-env (-> vector2d Void)))

(: tackle! (-> battle-env Move-Animation))
(define (tackle! env)
  (define distance 175.)
  (define seconds 1.5)
  
  (: get-animation (-> Update-Pos vector2d vector2d Move-Animation))
  (define (get-animation update-pos! start-position end-position)
    `((,(@on-update (update-pos! env) (glide start-position end-position seconds)))
      (,(@on-update (update-pos! env) (glide end-position start-position seconds)))))

  (cond [(battle-env-players-turn? env)
         (define start-position (player-position env))
         (define end-position 
           (vector2d (+ (vector2d-x start-position) distance) (vector2d-y start-position)))
         (get-animation update-player-pos! start-position end-position)]
        [else
         (define start-position (enemy-position env))
         (define end-position 
           (vector2d (+ (vector2d-x start-position) distance) (vector2d-y start-position)))
         (get-animation update-enemy-pos! start-position end-position)]))


; helpers
(: update-player-pos! Update-Pos)
(define ((update-player-pos! env) pos) (set-entity-position! (battle-env-player env) pos))
(: update-enemy-pos! Update-Pos)
(define ((update-enemy-pos! env) pos) (set-entity-position! (battle-env-enemy env) pos))


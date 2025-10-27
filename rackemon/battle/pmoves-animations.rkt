#lang typed/racket/base

(require "../animations/primitives.rkt"
         "../window.rkt"
         "./types.rkt"
         "../animations/types.rkt"
         (submod "./types.rkt" utils))

(provide tackle)

; helpers
(: update-player-position (battle-env -> (vector2d -> battle-env)))
(define ((update-player-position env) new-position)
  (struct-copy battle-env env 
               [player 
                 (struct-copy entity (battle-env-player env) [position new-position])]))

(: update-enemy-position (battle-env -> (vector2d -> battle-env)))
(define ((update-enemy-position env) new-position)
  (struct-copy battle-env env 
               [enemy
                 (struct-copy entity (battle-env-enemy env) [position new-position])]))

(: update-animations 
   (All (A)
     (-> battle-env
         (Animations-List A)
         (battle-env -> (A -> battle-env))
         (Animations-List battle-env))))
(define (update-animations env animations update)
  (for/list ([concurrent-animations (in-list animations)])
    (for/list ([animation (in-list concurrent-animations)])
      (animation-map animation (update env)))))

(: tackle (-> battle-env (Animations-List battle-env)))
(define (tackle env)
  (define distance 175.)
  (define seconds 1.5)
  
  (: get-animation (-> vector2d vector2d (Animations-List vector2d)))
  (define (get-animation start-position end-position)
    `((,(glide start-position end-position seconds))
      (,(glide end-position start-position seconds))))

  (cond [(battle-env-players-turn? env)
         (define start-position (player-position env))
         (define end-position 
           (vector2d (+ (vector2d-x start-position) distance) (vector2d-y start-position)))
         (update-animations env (get-animation start-position end-position) update-player-position)]
        [else
         (define start-position (enemy-position env))
         (define end-position 
           (vector2d (+ (vector2d-x start-position) distance) (vector2d-y start-position)))
         (update-animations env (get-animation start-position end-position) update-enemy-position)]))


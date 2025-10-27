#lang typed/racket/base

(require "../animations/primitives.rkt"
         "../window.rkt"
         "./types.rkt"
         "../animations/types.rkt"
         (submod "./types.rkt" utils))

(provide tackle)

(define-type Param-A (U vector2d))

(: tackle (-> battle-env (Listof (Listof (Animation Param-A)))))
(define (tackle env)
  (define distance 175.)
  (define seconds 1.5)
  
  (: get-animation (-> vector2d vector2d (Listof (Listof (Animation vector2d)))))
  (define (get-animation start-position end-position)
    `((,(glide start-position end-position seconds))
      (,(glide end-position start-position seconds))))

  (cond [(battle-env-players-turn? env)
         (define start-position (player-position env))
         (define end-position
             (struct-copy vector2d start-position
                          [x (+ (vector2d-x start-position) distance)]))
         (get-animation start-position end-position)]
        [else
         (define start-position (enemy-position env))
         (define end-position
             (struct-copy vector2d start-position
                          [x (- (vector2d-x start-position) distance)]))
         (get-animation start-position end-position)]))


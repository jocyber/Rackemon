#lang typed/racket/base

(provide (all-defined-out))

(require "../math-utils.rkt"
         "./types.rkt"
         racket/match)

(define-type (Animation A) (U 'AnimationEnd (-> Nonnegative-Float (Pair A (Animation A)))))
(define-type (Animations-List A) (Listof (Listof (Animation A))))

(: @on-update (All (A) (-> (-> A Void) (Animation A) (Animation Void))))
(define (@on-update f animation)
  (cond [(eq? animation 'AnimationEnd) 'AnimationEnd]
        [else 
          (lambda ([dt : Nonnegative-Float])
            (match-define (cons val-a @new) (animation dt))
            (f val-a)
            (cons (void) (@on-update f @new)))]))


(: glide (-> vector2d vector2d Positive-Float (Animation vector2d)))
(define (glide start end seconds)
  (define dx-rate (/ (- (vector2d-x end) (vector2d-x start)) seconds))
  (define dy-rate (/ (- (vector2d-y end) (vector2d-y start)) seconds))
  (define total-distance (compute-distance start end))
  
  (let loop ([pos start]
             [distance-traveled : Nonnegative-Real 0])
    (cond [(>= distance-traveled total-distance) 'AnimationEnd]
          [else (lambda ([dt : Nonnegative-Float])
                  (let* ([new-pos : vector2d 
                          (vector2d (+ (vector2d-x pos) (* dx-rate dt))
                                    (+ (vector2d-y pos) (* dy-rate dt)))]
                         [distance (compute-distance start new-pos)])
                      (cons (if (>= distance total-distance) end pos)
                            (loop new-pos distance))))])))

(: wait (-> Positive-Float (Animation Void)))
(define (wait seconds)
  (let loop ([time-left : Float seconds])
    (cond [(seconds . <= . 0) 'AnimationEnd]
          [else (lambda ([dt : Nonnegative-Float])
                  (cons (void) (loop (- seconds dt))))])))


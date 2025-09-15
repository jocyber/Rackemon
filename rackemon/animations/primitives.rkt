#lang typed/racket/base

(provide (all-defined-out))

(require "../propositions.rkt")

(define-type (Animation A) (-> Nonnegative-Float (U (Pair A (Animation A)) 'AnimationEnd)))

(struct vector2d 
  ([x : Real] 
   [y : Real])
  #:transparent)

(: square (-> Real Nonnegative-Real))
(define (square x) (assert (* x x) nonnegative?))

(: compute-distance (-> vector2d vector2d Nonnegative-Real))
(define (compute-distance start end)
  (let ([x-diff : Real (- (vector2d-x end) (vector2d-x start))]
        [y-diff : Real (- (vector2d-y end) (vector2d-y start))])
    (sqrt (+ (square x-diff) (square y-diff)))))


(: glide (-> vector2d vector2d Positive-Float (Animation vector2d)))
(define (glide start end seconds)
  (define dx-rate (/ (- (vector2d-x end) (vector2d-x start)) seconds))
  (define dy-rate (/ (- (vector2d-y end) (vector2d-y start)) seconds))
  (define total-distance (compute-distance start end))
  
  (let loop ([pos               : vector2d start] 
             [distance-traveled : Nonnegative-Real 0])
    (lambda ([dt : Nonnegative-Float])
      (cond [(>= distance-traveled total-distance) 'AnimationEnd]
            [else (let ([new-pos : vector2d 
                            (vector2d (+ (vector2d-x pos) (* dx-rate dt))
                                      (+ (vector2d-y pos) (* dy-rate dt)))])
                    (cons new-pos (loop new-pos (compute-distance start new-pos))))]))))

(: wait (-> Positive-Float (Animation Void)))
(define (wait seconds)
  (let loop ([time-left : Float seconds])
    (lambda ([dt : Nonnegative-Float])
      (cond [(seconds . <= . 0) 'AnimationEnd]
            [else (cons (void) (loop (- seconds dt)))]))))


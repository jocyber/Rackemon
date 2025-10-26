#lang typed/racket/base

(provide (all-defined-out))

(: nonnegative? (-> Real Boolean : #:+ Nonnegative-Real))
(define (nonnegative? n) (>= n 0))


(: square (-> Real Nonnegative-Real))
(define (square x) (assert (* x x) nonnegative?))

(: compute-distance (-> vector2d vector2d Nonnegative-Real))
(define (compute-distance start end)
  (let ([x-diff : Real (- (vector2d-x end) (vector2d-x start))]
        [y-diff : Real (- (vector2d-y end) (vector2d-y start))])
    (sqrt (+ (square x-diff) (square y-diff)))))



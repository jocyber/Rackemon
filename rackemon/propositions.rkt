#lang typed/racket/base

(provide (all-defined-out))

(: nonnegative? (-> Real Boolean : #:+ Nonnegative-Real))
(define (nonnegative? n) (>= n 0))


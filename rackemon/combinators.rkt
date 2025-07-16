#lang typed/racket/base

(provide (all-defined-out))

(: on (All (a b c) (-> a a b) (-> c a) -> (-> c c b)))
(define (on f g) (lambda (x y) (f (g x) (g y))))

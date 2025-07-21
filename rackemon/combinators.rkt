#lang typed/racket/base

(provide (all-defined-out))

(: on (All (A B C) (-> A A B) (-> C A) -> (-> C C B)))
(define (on f g) (lambda (x y) (f (g x) (g y))))

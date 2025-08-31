#lang typed/racket/base

(provide (all-defined-out))

(: on (All (A B C) (-> A A B) (-> C A) -> (-> C C B)))
(define (on f g) (lambda (x y) (f (g x) (g y))))

(: lift (All (A B C D) (-> A B C) (-> D A) (-> D B) -> (-> D C)))
(define (lift f g h) (lambda (x) (f (g x) (h x))))

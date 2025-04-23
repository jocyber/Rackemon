#lang typed/racket/base

(module+ test (require rackunit))

(provide (all-defined-out))

(: execute-defense-curl (-> Integer Integer))
(define (execute-defense-curl env) 3)

(module+ test)

(: execute-sucker-punch (-> Integer Integer))
(define (execute-sucker-punch env) 3)

(module+ test)

(: execute-tackle (-> Integer Integer))
(define (execute-tackle env) 3)

(module+ test)


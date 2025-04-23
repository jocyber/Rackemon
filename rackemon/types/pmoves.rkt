#lang typed/racket/base

(require (only-in "./ptypes.rkt" Pokemon-Type)
         "../move-execution.rkt")

(provide (all-defined-out))

(define-type Category (U 'Physical 'Special 'Status))

; consider making this a class. we may need to pattern match on the type
(struct pmove
  ([bp : (Option Positive-Integer)]
   [pp : Positive-Integer]
   [accuracy : (Option Positive-Integer)]
   [contact? : Boolean]
   [type : (Option Pokemon-Type)]
   [category : Category]
   [priority : Nonnegative-Integer]
   [turns : Positive-Integer]
   [execute : (-> Integer Integer)]) ; TODO: take in environment and return typed result
  #:transparent)

(define defense-curl (pmove #f 40 #f #f 'Normal 'Status 0 1 execute-defense-curl))
(define sucker-punch (pmove 80 5 100 #t 'Dark 'Physical 1 1 execute-sucker-punch))
(define tackle (pmove 40 25 100 #t 'Normal 'Physical 0 1 execute-tackle))

(module* utils typed/racket/base
  (require (only-in (submod "..") pmove)))

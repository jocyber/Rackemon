#lang typed/racket/base

(require (only-in "./ptypes.rkt" Pokemon-Type))

(provide (all-defined-out))

(define-type Category (U 'Physical 'Special 'Status))

(struct pmove
  ([name     : Symbol]
   [bp       : (Option Positive-Integer)]
   [pp       : Positive-Integer]
   [accuracy : (Option Positive-Integer)]
   [contact? : Boolean]
   [type     : (Option Pokemon-Type)]
   [category : Category]
   [priority : Nonnegative-Integer]
   [turns    : Positive-Integer])
  #:transparent)

(define defense-curl (pmove 'DefenseCurl #f 40 #f #f 'Normal 'Status 0 1))
(define sucker-punch (pmove 'SuckerPunch 80 5 100 #t 'Dark 'Physical 1 1))
(define tackle (pmove 'Tackle 40 25 100 #t 'Normal 'Physical 0 1))

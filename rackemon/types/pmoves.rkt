#lang typed/racket/base

(require "./ptypes.rkt"
         "../move-execution.rkt")

(provide (all-defined-out))

(define-type Category (U 'Physical 'Special 'Status))

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

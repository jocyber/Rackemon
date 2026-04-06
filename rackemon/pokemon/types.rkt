#lang typed/racket/base

(require "../types.rkt")

(provide (all-defined-out))

(struct pokemon 
  ([name         : Symbol]
   [type         : (U Pokemon-Type (Pairof Pokemon-Type Pokemon-Type))]
   [frame-width  : Positive-Float]
   [frame-height : Positive-Float]
   [frame-count  : Positive-Integer]
   )
  #:transparent)


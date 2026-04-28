#lang typed/racket/base

(require "../types.rkt")

(provide (all-defined-out))

(define-type Pokemon-Instance-Type (U Pokemon-Type (Pairof Pokemon-Type Pokemon-Type)))

(struct pokemon
  ([name         : Symbol]
   [type         : Pokemon-Instance-Type]
   [frame-width  : Positive-Float]
   [frame-height : Positive-Float]
   [frame-count  : Positive-Integer]
   )
  #:transparent)

(struct pokemon-instance
  ([config : pokemon]
   )
  #:transparent
  )

(: pokemon-instance-name (-> pokemon-instance Symbol))
(define (pokemon-instance-name pkmn-inst)
  (pokemon-name (pokemon-instance-config pkmn-inst)))

(: pokemon-instance-type (-> pokemon-instance Pokemon-Instance-Type))
(define (pokemon-instance-type pkmn-inst)
  (pokemon-type (pokemon-instance-config pkmn-inst)))

(: pokemon-instance-frame-width (-> pokemon-instance Positive-Float))
(define (pokemon-instance-frame-width pkmn-inst)
  (pokemon-frame-width (pokemon-instance-config pkmn-inst)))

(: pokemon-instance-frame-height (-> pokemon-instance Positive-Float))
(define (pokemon-instance-frame-height pkmn-inst)
  (pokemon-frame-height (pokemon-instance-config pkmn-inst)))

(: pokemon-instance-frame-count (-> pokemon-instance Positive-Integer))
(define (pokemon-instance-frame-count pkmn-inst)
  (pokemon-frame-count (pokemon-instance-config pkmn-inst)))

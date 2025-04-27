#lang typed/racket/base

(require racket/match)

(provide (all-defined-out))

(define-type Pokemon-Type 
  (U 'Fire 'Water 'Grass 'Electric 'Dragon 'Bug 'Dark 'Steel 'Psychic
     'Ground 'Fairy 'Fighting 'Flying 'Ghost 'Poison 'Rock 'Ice 'Normal))

(define-type Effectiveness
  (U 'SuperEffective 'NormallyEffective 'NotVeryEffective 'NotEffective))

(: effectiveness (-> Pokemon-Type Pokemon-Type Effectiveness))
(define (effectiveness attacking-type defending-types) ; defending type can have two types
  (define (mappings defending-type)
    (match* (attacking-type defending-type)
      [('Fire (or 'Grass 'Bug 'Steel 'Ice)) 'SuperEffective]
      [('Fire (or )) 'NotVeryEffective]
      [('Fire _) 'NormallyEffective]

      ))
  
  ; TODO: logic goes here
  'SuperEffective)

#lang typed/racket/base

(provide (all-defined-out))

(define-type Pokemon-Type 
  (U 'Fire 'Water 'Grass 'Electric 'Dragon 'Bug 'Dark 'Steel 'Psychic
     'Ground 'Fairy 'Fighting 'Flying 'Ghost 'Poison 'Rock 'Ice 'Normal))

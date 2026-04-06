#lang typed/racket/base

(provide (all-defined-out))

(: pokemon-front-resource-path (-> Symbol String))
(define (pokemon-front-resource-path name)
  (format "resources/pokemon/front/~a.png" (symbol->string name)))

(: pokemon-back-resource-path (-> Symbol String))
(define (pokemon-back-resource-path name)
  (format "resources/pokemon/back/~a.png" (symbol->string name)))

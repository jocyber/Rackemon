#lang typed/racket/base

(require "./types.rkt")

(provide (all-defined-out))

(define tackle (pmove 'Tackle 40 25 100 #t 'Normal 'Physical 0 1))
(define defense-curl (pmove 'DefenseCurl #f 40 #f #f 'Normal 'Status 0 1))
(define sucker-punch (pmove 'SuckerPunch 80 5 100 #t 'Dark 'Physical 1 1))
(define aerial-ace (pmove 'AerialAce 60 20 +inf.0 #t 'Flying 'Physical 0 1))
(define bullet-seed (pmove 'BulletSeed 25 30 100 #f 'Grass 'Physical 0 1))


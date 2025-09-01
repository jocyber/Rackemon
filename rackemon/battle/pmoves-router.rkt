#lang typed/racket/base

(require "./types.rkt"
         "./pmoves-execute.rkt"
         racket/match)

(provide route-pmove)

(: route-pmove (-> pmove (Option runnable-pmove)))
(define/match (route-pmove move)
  [((pmove 'AerialAce _ _ _ _ _ _ _ _))
   (runnable-pmove execute-aerial-ace)]
  [((pmove 'BulletSeed _ _ _ _ _ _ _ _))
   (runnable-pmove execute-bullet-seed)]
  [((pmove 'DefenseCurl _ _ _ _ _ _ _ _))
   (runnable-pmove execute-defense-curl)]
  [((pmove 'SuckerPunch _ _ _ _ _ _ _ _))
   (runnable-pmove execute-sucker-punch)]
  [((pmove 'Tackle _ _ _ _ _ _ _ _))
   (runnable-pmove execute-tackle)]
  [(_) #f]
  )

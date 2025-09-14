#lang typed/racket/base

(require "./types.rkt"
         "./pmoves-execute.rkt")

(provide route-pmove)

(define router
  (make-immutable-hash 
    `((AerialAce . ,(runnable-pmove execute-aerial-ace))
      (BulletSeed . ,(runnable-pmove execute-bullet-seed))
      (DefenseCurl . ,(runnable-pmove execute-defense-curl))
      (SuckerPunch . ,(runnable-pmove execute-sucker-punch))
      (Tackle . ,(runnable-pmove execute-tackle))
      )))

(: route-pmove (-> pmove (Option runnable-pmove)))
(define (route-pmove move) (hash-ref router (pmove-name move) #f))

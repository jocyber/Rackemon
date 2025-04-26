#lang typed/racket/base

(require "./move-execution.rkt"
         "./types/pmoves.rkt")

(struct move-executor ([move : pmove] [execute : Execute-Move]))

(define defense-curl-executor (move-executor defense-curl execute-defense-curl))
(define sucker-punch-executor (move-executor sucker-punch execute-sucker-punch))
(define tackle-executor (move-executor tackle execute-tackle))


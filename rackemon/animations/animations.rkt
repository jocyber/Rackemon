#lang racket/base

(require racket/stream 
         racket/function)

; use contracts
; may require generators for local state
(define (stream-glide dx dy pos)
  (define ((calc-pos pos) dt)
    (cons (* dt (+ dx (car (pos dt))))
          (* dt (+ dy (cdr (pos dt))))))

  (let loop ([pos (thunk* pos)])
    (let ([pos (calc-pos pos)])
      (stream* pos (loop pos)))))



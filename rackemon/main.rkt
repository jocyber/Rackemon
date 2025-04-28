#lang racket/base

(require "./raylib.rkt")

(init-window 500 500 "Hello from Racket")

(let loop ()
  (cond [(close-window?)]
        [else 
          (begin-drawing)
          (end-drawing)
          (loop)]))

(close-window)



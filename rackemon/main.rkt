#lang racket/base

(require (submod "./raylib.rkt" utils))

(call-with-window
  500 500 "Hello from Racket"
  (lambda () 
    (void)))

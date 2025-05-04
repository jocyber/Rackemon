#lang racket/base

(module constants racket/base
  (provide (all-defined-out))

  (define window-height 448)
  (define window-width 960)
  (define window-title "Pokemon"))


(module+ main
  (require (submod "./raylib.rkt" utils)
           (submod ".." constants))

  (call-with-window
    window-width window-height window-title
    (lambda (dt) 
      (void))))

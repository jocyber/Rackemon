#lang racket/base

(require (submod "./raylib.rkt" utils)
         "window.rkt"
         "./battle/pmoves-config.rkt"
         )

(module+ main
  (call-with-window
    window-width window-height window-title
    (lambda (dt) 
      (void))))

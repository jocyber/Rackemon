#lang racket/base

(require "../raylib.rkt"
         (submod "../raylib.rkt" utils)
         (submod "../raylib.rkt" colors)
         (submod "../raylib.rkt" structs))

(module+ main
  (require (submod "./env.rkt" test-utils)
           "../window.rkt")

  (call-with-window
    window-width window-height window-title
    (lambda (dt background) 
      (draw-texture-ex background (make-vector2 0. 0.) 0. 4. WHITE)
      )
    "resources/battle/backgrounds/grass_background.png")
  )

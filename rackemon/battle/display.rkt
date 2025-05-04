#lang racket/base

(require "../raylib.rkt"
         (submod "../raylib.rkt" utils)
         (submod "../raylib.rkt" colors)
         (submod "../raylib.rkt" structs))

(module+ main
  (require (submod "../main.rkt" constants)
           (submod "./env.rkt" test-utils))

  (init-window window-width window-height window-title)
  (define background (load-sprite "resources/battle/backgrounds/grass_background.png"))

  (let loop ()
    (unless (window-should-close?)
      (begin-drawing)

      (clear-background WHITE)
      (draw-texture-ex background (make-Vector2 0. 0.) 0. 4. WHITE)

      (end-drawing)
      (loop)))

  (unload-texture background))


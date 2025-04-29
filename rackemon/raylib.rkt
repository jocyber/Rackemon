#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define)

; provides a safe interface for the Raylib library
; https://www.raylib.com/cheatsheet/cheatsheet.html
(provide (rename-out [InitWindow init-window]
                     [CloseWindow close-window]
                     [WindowShouldClose window-should-close?]
                     [BeginDrawing begin-drawing]
                     [EndDrawing end-drawing]
                     [GetFrameTime get-frame-time]))

; set raylib path in environment variable in Makefile with allowing of override
(define-ffi-definer define-raylib (ffi-lib "/usr/lib/raylib/src/libraylib"))

(define-raylib InitWindow (_fun _int _int _string -> _void))
(define-raylib CloseWindow (_fun -> _void))
(define-raylib WindowShouldClose (_fun -> _stdbool)) 
(define-raylib BeginDrawing (_fun -> _void))
(define-raylib EndDrawing (_fun -> _void))
(define-raylib GetFrameTime (_fun -> _float))

(module* utils #f
  (require (submod ".."))

  (provide (all-defined-out))

  (define (call-with-window width height title f) 
    (init-window width height title)

    (let loop ()
      (unless (window-should-close?)
        (begin-drawing)
        (f (get-frame-time))
        (end-drawing)
        (loop)))

    (close-window)))

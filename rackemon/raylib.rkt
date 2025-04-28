#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define)

; provides a safe interface for the Raylib library
; https://www.raylib.com/cheatsheet/cheatsheet.html

(provide (rename-out [InitWindow init-window]
                     [CloseWindow close-window]
                     [WindowShouldClose close-window?]
                     [BeginDrawing begin-drawing]
                     [EndDrawing end-drawing]))

(define-ffi-definer define-raylib (ffi-lib "raylib"))

(define-raylib InitWindow (_fun _int _int _string -> _void))
(define-raylib CloseWindow (_fun -> _void))
(define-raylib WindowShouldClose (_fun -> _stdbool)) 
(define-raylib BeginDrawing (_fun -> _void))
(define-raylib EndDrawing (_fun -> _void))

; introduce window opening abstraction similar to "call-with-input-file"

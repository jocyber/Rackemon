#lang racket/base

(module structs racket/base
  (require ffi/unsafe 
           ffi/unsafe/define)

  (provide (all-defined-out))

  (define-cstruct _Image
    ([data _pointer]
     [width _int]
     [height _int]
     [mipmaps _int]
     [format _int]))

  (define-cstruct _Texture2D
    ([id _uint]
     [width _int]
     [height _int]
     [mipmaps _int]
     [format _int]))

  (define-cstruct _Color ([r _ubyte] [g _ubyte] [b _ubyte] [a _ubyte]))
  (define-cstruct _Vector2 ([x _float] [y _float])))


(require ffi/unsafe
         ffi/unsafe/define 
         'structs)

; provides a safe interface for the Raylib library
; https://www.raylib.com/cheatsheet/cheatsheet.html
(provide (rename-out [InitWindow init-window]
                     [CloseWindow close-window]
                     [WindowShouldClose window-should-close?]
                     [BeginDrawing begin-drawing]
                     [EndDrawing end-drawing]
                     [GetFrameTime get-frame-time]
                     [LoadImage load-image]
                     [UnloadImage unload-image]
                     [LoadTextureFromImage load-texture-from-image]
                     [DrawTexture draw-texture]
                     [UnloadTexture unload-texture]
                     [ClearBackground clear-background]
                     [DrawTextureEx draw-texture-ex]
                     ))

; set raylib path in environment variable in Makefile with allowing of override
(define-ffi-definer define-raylib (ffi-lib "/usr/lib/raylib/src/libraylib"))

(define-raylib InitWindow (_fun _int _int _string -> _void))
(define-raylib CloseWindow (_fun -> _void))
(define-raylib WindowShouldClose (_fun -> _stdbool)) 
(define-raylib BeginDrawing (_fun -> _void))
(define-raylib EndDrawing (_fun -> _void))
(define-raylib GetFrameTime (_fun -> _float))
(define-raylib LoadImage (_fun _string -> _Image))
(define-raylib UnloadImage (_fun _Image -> _void))
(define-raylib LoadTextureFromImage (_fun _Image -> _Texture2D))
(define-raylib DrawTexture (_fun _Texture2D _int _int _Color -> _void))
(define-raylib ClearBackground (_fun _Color -> _void))
(define-raylib UnloadTexture (_fun _Texture2D -> _void))
(define-raylib DrawTextureEx (_fun _Texture2D _Vector2 _float _float _Color -> _void))

(module+ colors
  (require (submod ".." structs))

  (provide (all-defined-out))

  (define WHITE (make-Color 255 255 255 255)))

(module* utils #f
  (require (submod ".."))

  (provide (all-defined-out))

  ; should be a macro to avoid creating textures before the window is ready
  (define (call-with-window width height title f [clean-up #f]) 
    ; take in variadic number of textures, init them after init-window call, then clean them up before 
    ; close window
    (init-window width height title)

    (let loop ()
      (unless (window-should-close?)
        (begin-drawing)
        (f (get-frame-time))
        (end-drawing)
        (loop)))

    (when clean-up (clean-up))
    (close-window))

  (define (load-sprite path)
    (let* ([image (load-image path)]
           [texture (load-texture-from-image image)])
      (unload-image image)
      texture)))


#lang racket/base

(require racket/match)

(module structs racket/base
  (require ffi/unsafe 
           ffi/unsafe/define)

  (provide (all-defined-out))

  (define-cstruct _image
    ([data _pointer]
     [width _int]
     [height _int]
     [mipmaps _int]
     [format _int]))

  (define-cstruct _texture2D
    ([id _uint]
     [width _int]
     [height _int]
     [mipmaps _int]
     [format _int]))

  (define-cstruct _rect
    ([x _float]
     [y _float]
     [width _float]
     [height _float]))

  (define-cstruct _color ([r _ubyte] [g _ubyte] [b _ubyte] [a _ubyte]))
  (define-cstruct _vector2 ([x _float] [y _float])))


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
                     [DrawTexturePro draw-texture-pro]
                     ))

(define clean-path->string 
  (compose1 path->string simplify-path cleanse-path))

(define default-path 
  (match (system-type 'os)
    ['unix "/usr/local/lib/raylib/src/libraylib"]
    ['macosx (clean-path->string (build-path (getenv "HOMEBREW_CELLAR") "raylib" "5.5" "lib" "libraylib"))]
    [_ (error "Platform is not supported")]))

(define raylib-path 
  (or (getenv "RAYLIB_PATH") 
      (begin
        (displayln (format "RAYLIB_PATH environment variable is not defined. Defaulting to ~a" default-path))
        default-path)))

(define-ffi-definer 
  define-raylib 
  (with-handlers ([exn:fail?
                    (lambda (e) 
                      (raise-user-error 
                        (format "Raylib library not found at location: ~a" raylib-path)))])
    (ffi-lib raylib-path)))

(define-raylib InitWindow (_fun _int _int _string -> _void))
(define-raylib CloseWindow (_fun -> _void))
(define-raylib WindowShouldClose (_fun -> _stdbool)) 
(define-raylib BeginDrawing (_fun -> _void))
(define-raylib EndDrawing (_fun -> _void))
(define-raylib GetFrameTime (_fun -> _float))
(define-raylib LoadImage (_fun _string -> _image))
(define-raylib UnloadImage (_fun _image -> _void))
(define-raylib LoadTextureFromImage (_fun _image -> _texture2D))
(define-raylib DrawTexture (_fun _texture2D _int _int _color -> _void))
(define-raylib ClearBackground (_fun _color -> _void))
(define-raylib UnloadTexture (_fun _texture2D -> _void))
(define-raylib DrawTextureEx (_fun _texture2D _vector2 _float _float _color -> _void))
(define-raylib DrawTexturePro (_fun _texture2D _rect _rect _vector2 _float _color -> _void))

(module+ colors
  (require (submod ".." structs))

  (provide (all-defined-out))

  (define WHITE (make-color 255 255 255 255)))

(module* utils #f
  (require (submod ".."))

  (provide (all-defined-out))

  (define (call-with-window width height title initial-state f . paths)
    (init-window width height title)
    (define textures (map load-sprite paths))

    (let loop ([state initial-state] [dt (get-frame-time)])
      (unless (window-should-close?)
        (begin-drawing)

        (define-values (new-dt new-state) (apply f dt state textures))

        (end-drawing)
        (loop new-state (+ new-dt (get-frame-time)))))

    (for-each unload-texture textures)
    (close-window))

  (define (load-sprite path)
    (let* ([image (load-image path)]
           [texture (load-texture-from-image image)])
      (unload-image image)
      texture)))


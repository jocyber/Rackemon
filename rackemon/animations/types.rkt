#lang typed/racket/base

; everything here needs to be moved to a typed raylib module
(require/typed (submod "../raylib.rkt" structs)
               [make-rect (-> Float Float Float Float Any)]
               [make-color (-> Byte Byte Byte Byte Any)]
               [make-vector2 (-> Real Real Any)]
               [make-texture2D (-> Integer Integer Integer Integer Integer Any)])

(provide (all-defined-out))

(struct vector2d ([x : Float] [y : Float]) #:transparent)
(struct color_t ([r : Byte] [g : Byte] [b : Byte] [a : Byte]))
(struct rect_t ([x : Float] [y : Float] [width : Float] [height : Float]))
(struct texture2d 
  ([id      : Integer]
   [width   : Integer]
   [height  : Integer]
   [mipmaps : Integer]
   [format  : Integer])) 

(struct texture-info
  ([texture      : texture2d]
   [width-scale  : Positive-Float]
   [height-scale : Positive-Float]
   [color        : color_t]
   [origin       : vector2d]
   [rotation     : Float]
   [source       : rect_t])
  #:prefab)

; TODO: make into macros
(: rect->c-rect (-> rect_t Any))
(define (rect->c-rect rectangle)
  (make-rect 
    (rect_t-x rectangle)
    (rect_t-y rectangle)
    (rect_t-width rectangle)
    (rect_t-height rectangle)))

(: color->c-color (-> color_t Any))
(define (color->c-color c)
  (make-color
    (color_t-r c)
    (color_t-g c)
    (color_t-b c)
    (color_t-a c)))

(: vector2d->c-vector2 (-> vector2d Any))
(define (vector2d->c-vector2 v2)
  (make-vector2
    (vector2d-x v2)
    (vector2d-y v2)))

(: texture2d->c-texture2d (-> texture2d Any))
(define (texture2d->c-texture2d texture)
  (make-texture2D
    (texture2d-id texture)
    (texture2d-width texture)
    (texture2d-height texture)
    (texture2d-mipmaps texture)
    (texture2d-format texture)))


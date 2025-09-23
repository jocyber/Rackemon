#lang typed/racket/base

(require/typed (submod "../raylib.rkt" structs)
               [make-rect (-> Float Float Float Float Any)]
               [make-color (-> Byte Byte Byte Byte Any)]
               [make-vector2 (-> Real Real Any)]
               [make-texture2D (-> Integer Integer Integer Integer Integer Any)])

(provide (all-defined-out))

(struct vector2d ([x : Real] [y : Real]) #:transparent)
(struct color ([r : Byte] [g : Byte] [b : Byte] [a : Byte]))
(struct rect ([x : Float] [y : Float] [width : Float] [height : Float]))
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
   [color        : color]
   [origin       : vector2d]
   [rotation     : Float]
   [source       : rect])
  #:prefab)

(: rect->c-rect (-> rect Any))
(define (rect->c-rect rectangle)
  (make-rect 
    (rect-x rectangle)
    (rect-y rectangle)
    (rect-width rectangle)
    (rect-height rectangle)))

(: color->c-color (-> color Any))
(define (color->c-color c)
  (make-color
    (color-r c)
    (color-g c)
    (color-b c)
    (color-a c)))

(: vector2d->c-vector2 (-> vector2d Any))
(define (vector2d->c-vector2 vector2)
  (make-vector2
    (vector2d-x vector2)
    (vector2d-y vector2)))

(: texture2d->c-texture2d (-> texture2d Any))
(define (texture2d->c-texture2d texture)
  (make-texture2D
    (texture2d-id texture)
    (texture2d-width texture)
    (texture2d-height texture)
    (texture2d-mipmaps texture)
    (texture2d-format texture)))


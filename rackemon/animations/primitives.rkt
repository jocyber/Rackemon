#lang typed/racket/base

(provide (all-defined-out))

(require "../math-utils.rkt"
         "../raylib.rkt"
         "./types.rkt"
         racket/function
         racket/match)

; TODO: moved to raylib typed module
(require/typed "../raylib.rkt"
               [draw-texture-pro (-> Any Any Any Any Any Any Void)])

(define-type (Animation A) (U 'AnimationEnd (-> Nonnegative-Float (Pair A (Animation A)))))
(define-type (Animations-List A) (Listof (Listof (Animation A))))

; https://play.haskell.org/saved/ubD3mGDl 
; we take advantage of the fact that an animation is a functor
(: animation-map (All (A B) (-> (Animation A) (-> A B) (Animation B))))
(define (animation-map animation f)
  (cond [(eq? animation 'AnimationEnd) 'AnimationEnd]
        [else (match-define (cons val new-animation) animation)
              (lambda ([dt : Nonnegative-Float]) 
                (cons (f val) (animation-map (new-animation dt) f)))]))

(: glide (-> vector2d vector2d Positive-Float (Animation vector2d)))
(define (glide start end seconds)
  (define dx-rate (/ (- (vector2d-x end) (vector2d-x start)) seconds))
  (define dy-rate (/ (- (vector2d-y end) (vector2d-y start)) seconds))
  (define total-distance (compute-distance start end))
  
  (let loop ([pos               : vector2d start] 
             [distance-traveled : Nonnegative-Real 0])
    (lambda ([dt : Nonnegative-Float])
      (cond [(>= distance-traveled total-distance) 'AnimationEnd]
            [else (let* ([new-pos : vector2d 
                            (vector2d (+ (vector2d-x pos) (* dx-rate dt))
                                      (+ (vector2d-y pos) (* dy-rate dt)))]
                         [distance (compute-distance start new-pos)])
                    (cons (if (> distance total-distance) end pos)
                          (loop new-pos distance)))]))))

(: wait (-> Positive-Float (Animation Void)))
(define (wait seconds)
  (let loop ([time-left : Float seconds])
    (lambda ([dt : Nonnegative-Float])
      (cond [(seconds . <= . 0) 'AnimationEnd]
            [else (cons (void) (loop (- seconds dt)))]))))


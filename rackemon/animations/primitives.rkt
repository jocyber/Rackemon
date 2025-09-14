#lang typed/racket/base

(provide (all-defined-out))

(define-type (Animation A) (-> Positive-Float (U (Pair A (Animation A)) 'AnimationEnd)))

(struct vector2d 
  ([x : Integer] 
   [y : Integer])
  #:transparent)

(: glide (-> vector2d vector2d Positive-Float (Animation vector2d)))
(define (glide start end seconds)
  (define dx-rate (/ (- (vector2d-x end) (vector2d-x start)) seconds))
  (define dy-rate (/ (- (vector2d-y end) (vector2d-y start)) seconds))
  
  (let loop ([pos : vector2d start])
    (lambda ([dt : Positive-Float])
      (cond [(and ((vector2d-x pos) . >= . (vector2d-x end))
                  ((vector2d-y pos) . >= . (vector2d-y end)))
             'AnimationEnd]
            [else (let ([new-pos : vector2d 
                            (vector2d (+ (vector2d-x pos) (* dx-rate dt))
                                      (+ (vector2d-y pos) (* dy-rate dt)))])
                    (cons new-pos (loop new-pos)))]))))

(: wait (-> Positive-Float (Animation Void)))
(define (wait seconds)
  (lambda ([dt : Positive-Float])
    (cond [(seconds . <= . 0) 'AnimationEnd]
          [else (cons (void) (wait (- seconds dt)))])))


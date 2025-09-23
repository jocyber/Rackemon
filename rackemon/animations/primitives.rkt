#lang typed/racket/base

(provide (all-defined-out))

(require "../propositions.rkt"
         "../raylib.rkt"
         "./types.rkt"
         racket/function
         racket/match)

(define-type (Animation A) (-> Nonnegative-Float (U (Pair A (Animation A)) 'AnimationEnd)))

; TODO: make this a macro
(: execute-glide (-> texture-info vector2d vector2d Positive-Float Void))
(define (execute-glide texture-info start end seconds)
  (let loop ([f : (Animation vector2d) (glide start end seconds)])
    (lambda ([dt : Nonnegative-Real])
      (match-define (cons position new-f) (f dt))

      (draw-texture-pro 
        (texture2d->c-texture2d (texture-info-texture texture-info))
        (rect->c-rect (texture-info-source texture-info))
        (rect->c-rect
          (rect (vector2d-x position) (vector2d-y position)
                (texture-info-width-scale texture-info) (texture-info-height-scale texture-info)))
        (vector2d->c-vector2 (texture-info-origin texture-info))
        (texture-info-rotation texture-info)
        (color->c-color (texture-info-color texture-info)))

      (loop new-f))))


(: square (-> Real Nonnegative-Real))
(define (square x) (assert (* x x) nonnegative?))

(: compute-distance (-> vector2d vector2d Nonnegative-Real))
(define (compute-distance start end)
  (let ([x-diff : Real (- (vector2d-x end) (vector2d-x start))]
        [y-diff : Real (- (vector2d-y end) (vector2d-y start))])
    (sqrt (+ (square x-diff) (square y-diff)))))


(define-type Execution (-> Nonnegative-Real Void))

(: play-animation (-> (Listof (Listof Execution)) 
                      (-> Nonnegative-Real (U Execution 'AnimationEnd))))
(define (play-animation animations)
  (if (null? animations)
      'AnimationEnd
      (lambda ([dt : Nonnegative-Real]) 
        (define executions (map (curry call-with-values (thunk dt)) (car animations)))
        (if (andmap (curry eq? 'AnimationEnd) executions)
            (play-animation (cdr animations))
            (play-animation animations)))))


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


#lang typed/racket/base

(require racket/function)

(define-type Animation (Nonnegative-Real -> Void))
(define-type Animations (Listof (Listof Animation)))

(define animation-player%
  (class object%
    (super-new)

    (init-field animation : Animations)

    (: play (-> Nonnegative-Real Boolean)
    (define/public (play dt)
      (cond [(null? animations) #t]
            [else 
              (define updated-animation
                (map (curry call-with-values (thunk dt)) (car animation)))
              (define finished? (andmap (curry eq? 'AnimationEnd) updated-animation))

              (or finished? (begin (set! animation (cdr animation)) #f))]))
    ))

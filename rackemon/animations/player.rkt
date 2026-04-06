#lang racket/base

(require racket/class
         racket/match 
         )

(provide AnimationPlayer%)

(define AnimationPlayer% 
  (class object%
    (super-new)

    (init-field animations)

    (define/public (@play dt)
      (define (@update a)
        (cond [(eq? a 'AnimationEnd) 'AnimationEnd]
              [else (match-define (cons _ @new) (a dt))
                    @new]))

      (cond [(null? animations) 'AnimationEnd]
            [else 
              (define results (map @update (car animations)))

              (if (andmap (lambda (a) (eq? a 'AnimationEnd)) results)
                  (set! animations (cdr animations))
                  (set! animations (cons results (cdr animations))))]))
    ))


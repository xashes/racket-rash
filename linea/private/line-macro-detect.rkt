#lang racket/base

;; struct properties and syntax classes for defining and detecting line macros

(provide
 prop:line-macro
 line-macro?
 linea-line-macro-transform
 line-macro
 line-macro-struct
 )
(module+ for-public
  (provide
   prop:line-macro
   line-macro?
   line-macro
   ))

(require syntax/parse)


(define-values (prop:line-macro
                line-macro?
                linea-line-macro-ref)
  (make-struct-type-property 'linea-line-macro))

(define-syntax-class line-macro
  (pattern op:id
           #:when (line-macro? (syntax-local-value #'op (λ () #f)))))

(define (linea-line-macro-transform stx)
  (syntax-parse stx
    [(lm:line-macro arg ...)
     (let ([slv (syntax-local-value #'lm)])
       (let ([transform (linea-line-macro-ref slv)])
         (cond [(procedure? transform) (transform slv stx)]
               [(number? transform) ({vector-ref (struct->vector slv)
                                                 (add1 transform)}
                                     stx)])))]))

(struct line-macro-struct
  (transformer)
  #:property prop:line-macro (λ (inst . args)
                               (apply
                                {line-macro-struct-transformer inst}
                                args))
  #:property prop:procedure (struct-field-index transformer))



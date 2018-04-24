#lang racket
(require (for-syntax
          ffi/unsafe
          racket/syntax
          syntax/stx))
(require ffi/unsafe
         ffi/unsafe/define)


(define gpsm-ffi-lib (ffi-lib #f))
(define gpsm-upcasts-ffi-lib (ffi-lib #f))

(define-ffi-definer define-gpsm gpsm-ffi-lib)
(define-ffi-definer define-gpsm-upcast gpsm-upcasts-ffi-lib)

(define known-upcasts (make-hash))
(define (id-or-upcast ptr dst-type)
  (let ([src-type (cpointer-tag ptr)])
    ;(display (format "Got pointer with tag ~a, want pointer with tag ~a" src-type dst-type)) (newline)
    ;(display (format "Known upcast? ~a" (hash-ref known-upcasts `(,src-type ,dst-type) (lambda () #f)))) (newline)
    (if (eq? src-type dst-type) ptr
        ((hash-ref known-upcasts `(,src-type ,dst-type)) ptr))))
(define (conforms-to-c++-type ptr dst-type)
  (let ([src-type (cpointer-tag ptr)])
    (or (eq? src-type dst-type) (hash-ref known-upcasts `(,src-type ,dst-type) #f))))

(define-syntax (define-c++pointer-type stx)
  (let ([pref-underscore
         (lambda (id) (format-id id "_~a" id))])
  (syntax-case stx ()
    [(_ id (bases upcast-fs) ...)
     (with-syntax* ([_id (pref-underscore #'id)]
                    [(_bases ...)
                     (stx-map pref-underscore #'(bases ...))]
                    [id++ (format-id #'_id "~a++" #'_id)]
                    [(upcast-inits ...)
                     #'((begin
                           (define-gpsm-upcast upcast-fs
                             (_fun _id -> _bases))
                           (hash-set! known-upcasts '(id bases) upcast-fs)) ...)])
       #'(begin
           (define-cpointer-type _id)
           upcast-inits ...
           (define-fun-syntax id++
             (syntax-id-rules (id++)
               [id++ (type: _id
                      pre: (ptr => (id-or-upcast ptr 'id)))]))))])))

(provide define-gpsm
         define-gpsm-upcast
         id-or-upcast
         known-upcasts
         define-c++pointer-type)

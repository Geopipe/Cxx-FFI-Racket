#lang racket

(require "FFI-Bindings.rkt"
         (for-syntax
          json
          syntax/location))

(define-for-syntax known-cxx-types null)
(define-syntax (emit-type-table stx)
  (syntax-case stx ()
    [(_ json-datafile)
     (call-with-input-file
         (build-path (syntax-source-directory stx)
                     (syntax->datum #'json-datafile))
       (lambda (json-port)
         (letrec ([data (read-json json-port)]
                  [symbolize
                   (lambda (maybe-l)
                     (cond
                       [(list? maybe-l) (map symbolize maybe-l)]
                       [(string? maybe-l) (string->symbol maybe-l)]
                       [else maybe-l]))])
           (with-syntax
               ([((cxx-types (cxx-bases ...)) ...) (map (lambda (datum)
                           (datum->syntax stx datum)) (symbolize data))])
               #`(begin
                   (define-c++pointer-type cxx-types cxx-bases ...) ...)))))]))

(emit-type-table "casts_table.json")

(provide (all-defined-out))

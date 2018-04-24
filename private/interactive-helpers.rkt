#lang racket
(require ffi/unsafe)

(define (prime-address-space libraries [path "/opt/local/lib"])
  (map (lambda (library) (ffi-lib library #:get-lib-dirs (lambda () `(,path)))) libraries))

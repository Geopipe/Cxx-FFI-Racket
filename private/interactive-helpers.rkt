#lang racket
(require ffi/unsafe)

(define (prime-address-space [path "/Users/thomas/geopipe/buildm/lib"])
  (values
   (ffi-lib "libgeopipe-gpsm" #:get-lib-dirs (lambda () `(,path)))
   (ffi-lib "libgeopipe-gpsm-upcasts" #:get-lib-dirs (lambda () `(,path)))))

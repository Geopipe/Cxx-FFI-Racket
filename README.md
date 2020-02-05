C++ FFI Utilities for Racket
============================
Contains three useful files:
 - `FFI-Bindings.rkt` lets you bind FFI functions using Racket's [`ffi/unsafe`](https://docs.racket-lang.org/foreign/index.html) module, but extends the Racket notion of `cpointer` types to include `c++pointer` types, which support subtyping and upcasts.
 - `Cxx-Types.rkt` lets you automatically define `c++pointer` types for the entire type hierarchy of some API, by parsing JSON descriptions of inheritance relations emitted by [this library](https://github.com/Geopipe/Cxx-FFI), to discover symbol names of functions implementing the necessary upcasts (a C++ file containing the necessary functions can be emitted using the same Python utilities).
 - `private/interactive-helpers.rkt` allows you to easily preload a set of libraries into the Racket address space, so that `FFI-Bindings.rkt` doesn't need to know about specific path to libraries.

Usage
-----
 An example usage, based on a hypothetical FFI for [`Cxx-TEDSL`](https://github.com/Geopipe/Cxx-TEDSL) might look like this:
 
 ```racket
 (define-c++ makeFloat
  (_fun _float -> _TEDSL::Float))
  
  (define-c++ makePlus
  (_fun _TEDSL::Expr<TEDSL::Number>++
        _TEDSL::Expr<TEDSL::Number>++ -> _TEDSL::Plus))
        
 (makePlus (makeFloat 1.0) (makeFloat 3.0))
 ```
 
 (In this example `Float` is a subtype of `Expr<Float>`, `Number`, and `Expr<Number>`, so the FFI wrapper for `makePlus`, would automatically be able to find the necessary upcasts).
 
 It *should* be possible to reliably track ownership of these pointers, using the `allocator`, `deallocator` and `retainer` wrappers in `ffi/unsafe/alloc`, but the documentation for these functions is dense.

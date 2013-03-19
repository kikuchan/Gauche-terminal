;;;
;;; capability.scm
;;;
;;; THE ORANGINA LICENSE
;;; Copyright 2013 wasao
;;; All rights reserved.
;;;
;;; You can do whatever you want with this stuff.
;;; If we meet some day, and you think this stuff is worth it,
;;; you can buy me a bottle of orangina in return.
;;;
;;; wasao
;;; walter@wasao.org
;;;

(define-module terminal.capability
  (export <capability>)
  )
(select-module terminal.capability)


(define-class <capability> ()
  ([true-booleans     :init-keyword :true-booleans]
   [false-booleans    :init-keyword :false-booleans]
   [available-numbers :init-keyword :available-numbers]
   [available-strings :init-keyword :available-strings]
   [fetch-capability  :init-keyword :fetch-capability]
   ))

(define-method object-apply ([cap <capability>] [sym <symbol>])
  (if (slot-exists? cap sym)
      (slot-ref cap sym)
      ((slot-ref cap 'fetch-capability) sym)))

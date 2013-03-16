;;;
;;; terminal.scm
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

(define-module terminal
  (extend terminal.winsize
          terminal.terminfo
          terminal.termcap
          terminal.tparm
          )
  (export load-terminal-capability)
  )
(select-module terminal)


(define (load-terminal-capability :key (term (sys-getenv "TERM")) path fallback)
  (cond [(load-terminfo-entry :term term :path path :fallback #f)]
        [(load-termcap-source :term term :path path :fallback #f)]
        [(undefined? fallback) (error "Failed to load terminal capabilities")]
        [else fallback]))

#!/usr/bin/env gosh
(use terminal)
(use srfi-27)

(define ANSI (load-terminal-capability :term 'ansi))
(random-source-randomize! default-random-source)
(display (ANSI 'clear-screen))


(define (cursor-move row col)
  (display (tparm (ANSI 'cursor-address) row col)))
(define (change-foreground n)
  (tparm (ANSI 'set-a-foreground) n))
(define (change-foreground-random)
  (display (change-foreground (random-integer 10))))

(define ws (read-winsize (current-input-port)))
(define rows    (car ws))
(define columns (cdr ws))
(define (set!-col-and-row _)
  (set! ws (read-winsize (current-input-port)))
  (when (and (> (car ws) 0) (> (cdr ws) 0))
        (set! rows    (car ws))
        (set! columns (cdr ws))))

(set-signal-handler! SIGWINCH set!-col-and-row)


(let loop ()
  (change-foreground-random)
  (cursor-move (random-integer rows) (random-integer columns))
  (display "■")
  (loop))

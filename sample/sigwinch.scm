#!/usr/bin/env gosh
(use terminal)

(set-signal-handler! SIGWINCH
  (^_ (print (read-winsize))))

(while #t)

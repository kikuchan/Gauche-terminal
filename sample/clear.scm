#!/usr/bin/env gosh
(use terminal)

(let1 TERM (load-terminal-capability)
  (display (TERM 'clear-screen)))

# Gauche-terminal
Terminal utility library for Gauche.

## Requirements
* Gauche 0.9 or later
* Ncurses library and pkg-config (if you want to use tparm)

## Building from tarball
```shell
% ./DIST gen
% ./configure
% make
% sudo make install
```
    
If you don't have Ncurses or don't want to build tparm,
run configure as this:
```shell
% ./configure --disable-tparm
```

## Start
```scheme
(use terminal)
```

# Reference
## terminal
This module contains terminal.* modules.

### load-terminal-capability :key term path fallback
* Common interface of load-terminfo-entry and load-termcap-source.    
* Default value of 'term' is (sys-getenv "TERM").
* Type of return value: \<capability\>. (capability-symbols receiver object)

```scm
(define TERM (load-terminal-capability))

(TERM 'true-booleans)     ; => get true-boolean symbols
(TERM 'false-booleans)    ; => get false-boolean symbols
(TERM 'available-numbers) ; => get available number symbols
(TERM 'available-strings) ; => get available string symbols
(TERM 'clear-screen)  ; => get clear_screen escape sequence

(load-terminal-capability :path "~/.terminfo"); => load "~/.terminfo"
(load-terminfo-entry :term 'ansi); => load the terminfo entry file of ansi
(load-termcap-source :term 'cygwin); => load terminal capabilities of cygwin, from termcap source
```

## terminal.terminfo
### load-terminfo-entry :key term path fallback
* Terminfo interface for load-terminal-capability.


## terminal.termcap
### load-termcap-source :key term path fallback
* Termcap interface for load-terminal-capability.


## terminal.tparm
### tparm capability-string :optional param1 param2 ... param10
This function is wrapper of GNU Ncurses tparm.


## terminal.winsize
### \<winsize\>
This class is wrapping 'struct winsize'.    
    
**Instance Variable of <winsize>:** size.row => ws_row of 'struct winsize'    
**Instance Variable of <winsize>:** size.col => ws_col of 'struct winsize'    
**Instance Variable of <winsize>:** pixel.x  => ws_xpixel of 'struct winsize'    
**Instance Variable of <winsize>:** pixel.y  => ws_ypixel of 'struct winsize'    

### load-winsize :optional port-or-fd
* call ioctl with TIOCGWINSZ to port-or-fd
* Defualt port-or-fd value is (current-input-port)
* Type of return value: \<winsize\>

### read-winsize :optional port-or-fd
* call ioctl with TIOCGWINSZ to port-or-fd
* Type of return value: \<pair\>
* Return value format: ```(size.row . size.col)```

### load-winsize! ws :optional port-or-fd
* call ioctl with TIOCGWINSZ and ws, to port-or-fd
* Destructively modifies winsize
* Type of return value: \<boolean\>
* success => #t, failure => #f

### set-winsize ws :optional port-or-fd
* call ioctl with TIOCSWINSZ and ws, to port-or-fd
* Type of return value: \<boolean\>
* success => #t, failure => #f

### make-winsize :key size.row size.col pixel.x pixel.y
* Type of return value: \<winsize\>

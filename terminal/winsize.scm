;;;
;;; winsize.scm
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

(define-module terminal.winsize
  (export-all)
  )
(select-module terminal.winsize)

(inline-stub
 (when "!defined(GAUCHE_WINDOWS)"
 "#ifndef GAUCHE_WINSIZE_H"
 "#define GAUCHE_WINSIZE_H"
 "#include <gauche.h>"
 "#include <gauche/vm.h>"
 "#include <gauche/port.h>"
 "#include <gauche/class.h>"
 "#include <termios.h>"
 "#include <sys/ioctl.h>"
 "#define VMDECL        ScmVM *vm = Scm_VM()"
 "#define LOCK(p)       PORT_LOCK(p, vm)"
 "#define UNLOCK(p)     PORT_UNLOCK(p)"
 "#endif"

 "typedef struct ScmWinSizeRec {"
 "	SCM_HEADER;"
 "	struct winsize ws;"
 "} ScmWinSize;"
 "SCM_CLASS_DECL(Scm_WinSizeClass);"
 "#define SCM_WINSIZE_P(obj) \
  	SCM_XTYPEP(obj, &Scm_WinSizeClass)"
 "#define SCM_WINSIZE_DATA(obj) \
  	((ScmWinSize*)obj)"
 "#define SCM_MAKE_WINSIZE(data) \
	(Scm_MakeWinSize(data))"

 (define-cfn make-winsize () :static
   (let* ([ws::ScmWinSize* (SCM_NEW ScmWinSize)])
     (SCM_SET_CLASS ws (& Scm_WinSizeClass))
     (return (SCM_OBJ ws))))

 "ScmObj Scm_MakeWinSize(ScmWinSize* data) {"
 "	SCM_SET_CLASS(data, &Scm_WinSizeClass);"
 "  SCM_RETURN(SCM_OBJ(data));"
 "}"
 
 (define-type <winsize>
   "ScmWinSize*" "ScmWinSize*"
   "SCM_WINSIZE_P" "SCM_WINSIZE_DATA" "SCM_MAKE_WINSIZE")
 
 (define-cclass <winsize>
   "ScmWinSize*" "Scm_WinSizeClass" ()
   ([size.row :c-name "ws.ws_row"    :type <ushort>]
    [size.col :c-name "ws.ws_col"    :type <ushort>]
    [pixel.x  :c-name "ws.ws_xpixel" :type <ushort>]
    [pixel.y  :c-name "ws.ws_ypixel" :type <ushort>])
   (allocator (c "make_winsize"))
   (printer (Scm_Printf port "#<<winsize> @%p %d:%d>" obj
                        (ref (-> (SCM_WINSIZE_DATA obj) ws) ws_row)
                        (ref (-> (SCM_WINSIZE_DATA obj) ws) ws_col))))

 (define-cproc load-winsize (port-or-fd::<port>) :: <winsize>
   VMDECL
   (LOCK port-or-fd)
   (let* ([fd::int (Scm_GetPortFd (SCM_OBJ port-or-fd) FALSE)]
          [t::ScmWinSize* (SCM_NEW ScmWinSize)])
     (ioctl fd TIOCGWINSZ (& (-> t ws)))
     (UNLOCK port-or-fd)
     (result t)))

 (define-cproc read-winsize (port-or-fd::<port>) :: <pair>
   VMDECL
   (LOCK port-or-fd)
   (let* ([fd::int (Scm_GetPortFd (SCM_OBJ port-or-fd) FALSE)]
          [t::ScmWinSize* (SCM_NEW ScmWinSize)])
     (ioctl fd TIOCGWINSZ (& (-> t ws)))
     (UNLOCK port-or-fd)
     (return (Scm_Cons (Scm_MakeIntegerFromUI (ref (-> t ws) ws_row))
                       (Scm_MakeIntegerFromUI (ref (-> t ws) ws_col))))))
 
 (define-cproc load-winsize! (port-or-fd::<port> t::<winsize>) :: <boolean>
   VMDECL
   (LOCK port-or-fd)
   (let* ([fd::int (Scm_GetPortFd (SCM_OBJ port-or-fd) FALSE)]
          [rv::int (ioctl fd TIOCGWINSZ (& (-> (SCM_WINSIZE_DATA t) ws)))])
     (UNLOCK port-or-fd)
     (if (< rv 0) (result 0) (result 1))))

 (define-cproc set-winsize (port-or-fd::<port> t::<winsize>) :: <boolean>
   VMDECL
   (LOCK port-or-fd)
   (let* ([fd::int (Scm_GetPortFd (SCM_OBJ port-or-fd) FALSE)]
          [rv::int (ioctl fd TIOCSWINSZ (& (-> (SCM_WINSIZE_DATA t) ws)))])
     (UNLOCK port-or-fd)
     (if (< rv 0) (result 0) (result 1))))
 ))

(cond-expand
  (gauche.os.windows)
  (else
   (define-syntax make-winsize
     (syntax-rules ()
       [(_) (make <winsize>)]
       [(_ initargs ...) (make <winsize> initargs ...)]))
   ))

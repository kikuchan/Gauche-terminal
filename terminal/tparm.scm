;;;
;;; tparm.scm
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

(define-module terminal.tparm
  (export tparm)
  )
(select-module terminal.tparm)


(inline-stub
 (declcode "#include \"config.h\"")
 (when "defined(ENABLE_TPARM) && defined(HAVE_CONFIG_H)"
 "#include <curses.h>"
 "#include <term.h>"

 (define-cproc tparm (str::<const-cstring>
   :optional (l1::<long> 0) (l2::<long> 0) (l3::<long> 0) (l4::<long> 0)
   (l5::<long> 0) (l6::<long> 0) (l7::<long> 0) (l8::<long> 0))::<const-cstring>
   (if (SCM_STRING_NULL_P (SCM_MAKE_STR_COPYING str))
       (result str)
       (result (tparm str l1 l2 l3 l4 l5 l6 l7 l8))))
 
 #| On the below code, happens SEGV at the first time calling tparm with "".
 (define-cproc tparm (str::<const-cstring>
   :optional (l1::<long> 0) (l2::<long> 0) (l3::<long> 0) (l4::<long> 0)
   (l5::<long> 0) (l6::<long> 0) (l7::<long> 0) (l8::<long> 0))::<const-cstring>
   tparm)
 |#

 )) ; "defined(ENABLE_TPARM)"

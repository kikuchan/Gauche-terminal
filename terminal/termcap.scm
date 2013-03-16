;;;
;;; termcap.scm
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

(define-module terminal.termcap
  (use srfi-1)
  (use srfi-11)
  (use srfi-13)
  (export load-termcap-source)
  )
(select-module terminal.termcap)


;;;
;;; Parameter
;;;

(define-constant %default-termcap-sources
  (list (x->string (sys-getenv "TERMCAP"))
        "/etc/termcap"
        "/usr/share/misc/termcap"))

;; capability-symbol -> tcap
(define-constant %table-of-booleans
  (hash-table
   'eq?
   '(auto-left-margin . bw)
   '(auto-right-margin . am)
   '(no-esc-ctlc . xb)
   '(ceol-standout-glitch . xs)
   '(eat-newline-glitch . xn)
   '(erase-overstrike . eo)
   '(generic-type . gn)
   '(hard-copy . hc)
   '(has-meta-key . km)
   '(has-status-line . hs)
   '(insert-null-glitch . in)
   '(memory-above . da)
   '(memory-below . db)
   '(move-insert-mode . mi)
   '(move-standout-mode . ms)
   '(over-strike . os)
   '(status-line-esc-ok . es)
   '(dest-tabs-magic-smso . xt)
   '(tilde-glitch . hz)
   '(transparent-underline . ul)
   '(xon-xoff . xo)
   '(needs-xon-xoff . nx)
   '(prtr-silent . 5i)
   '(hard-cursor . HC)
   '(non-rev-rmcup . NR)
   '(no-pad-char . NP)
   '(non-dest-scroll-region . ND)
   '(can-change . cc)
   '(back-color-erase . ut)
   '(hue-lightness-saturation . hl)
   '(col-addr-glitch . YA)
   '(cr-cancels-micro-mode . YB)
   '(has-print-wheel . YC)
   '(row-addr-glitch . YD)
   '(semi-auto-right-margin . YE)
   '(cpi-changes-res . YF)
   '(lpi-changes-res . YG)

   ; old capabilities
   '(linefeed-is-newline . NL)
   '(even-parity . EP)
   '(odd-parity . OP)
   '(half-duplex . HD)
   '(lower-case-only . LC)
   '(upper-case-only . UC)
   '(has-hardware-tabs . pt)
   '(return-does-clr-eol . xr)
   '(tek-4025-insert-line . xx)
   '(backspaces-with-bs . bs)
   '(crt-no-scrolling . ns)
   '(no-correctly-working-cr . nc)
   )
  )

;; tcap -> capability-symbol
(define-constant %table-of-numbers
  (hash-table
   'eq?
   '(co . columns)
   '(it . init-tabs)
   '(li . lines)
   '(lm . lines-of-memory)
   '(sg . magic-cookie-glitch)
   '(pb . padding-baud-rate)
   '(vt . virtual-terminal)
   '(ws . width-status-line)
   '(Nl . num-labels)
   '(lh . label-height)
   '(lw . label-width)
   '(ma . max-attributes)
   '(MW . maximum-windows)
   '(ug . magic-cookie-glitch-ul)
   '(Co . max-colors)
   '(pa . max-pairs)
   '(NC . no-color-video)
   '(Ya . buffer-capacity)
   '(Yb . dot-vert-spacing)
   '(Yc . dot-horz-spacing)
   '(Yd . max-micro-address)
   '(Ye . max-micro-jump)
   '(Yf . micro-char-size)
   '(Yg . micro-line-size)
   '(Yh . number-of-pins)
   '(Yi . output-res-char)
   '(Yj . output-res-line)
   '(Yk . output-res-horz-inch)
   '(Yl . output-res-vert-inch)
   '(Ym . print-rate)
   '(Yn . wide-char-size)
   '(BT . buttons)
   '(Yo . bit-image-entwining)
   '(Yp . bit-image-type)

   ; old capabilities
   '(dB . backspace-delay)
   '(dF . form-feed-delay)
   '(dT . horizontal-tab-delay)
   '(dV . vertical-tab-delay)
   '(kn . number-of-function-keys)
   '(dC . carriage-return-delay)
   '(dN . new-line-delay)
   )
  )

;; tcap -> capability-symbol
(define-constant %table-of-strings
  (hash-table
   'eq?
   '(|bt| . back-tab)
   '(|bl| . bell)
   '(|cr| . carriage-return)
   '(|cs| . change-scroll-region)
   '(|ct| . clear-all-tabs)
   '(|cl| . clear-screen)
   '(|ce| . clr-eol)
   '(|cd| . clr-eos)
   '(|ch| . column-address)
   '(|CC| . command-character)
   '(|cm| . cursor-address)
   '(|do| . cursor-down)
   '(|ho| . cursor-home)
   '(|vi| . cursor-invisible)
   '(|le| . cursor-left)
   '(|CM| . cursor-mem-address)
   '(|ve| . cursor-normal)
   '(|nd| . cursor-right)
   '(|ll| . cursor-to-ll)
   '(|up| . cursor-up)
   '(|vs| . cursor-visible)
   '(|dc| . delete-character)
   '(|dl| . delete-line)
   '(|ds| . dis-status-line)
   '(|hd| . down-half-line)
   '(|as| . enter-alt-charset-mode)
   '(|mb| . enter-blink-mode)
   '(|md| . enter-bold-mode)
   '(|ti| . enter-ca-mode)
   '(|dm| . enter-delete-mode)
   '(|mh| . enter-dim-mode)
   '(|im| . enter-insert-mode)
   '(|mk| . enter-secure-mode)
   '(|mp| . enter-protected-mode)
   '(|mr| . enter-reverse-mode)
   '(|so| . enter-standout-mode)
   '(|us| . enter-underline-mode)
   '(|ec| . erase-chars)
   '(|ae| . exit-alt-charset-mode)
   '(|me| . exit-attribute-mode)
   '(|te| . exit-ca-mode)
   '(|ed| . exit-delete-mode)
   '(|ei| . exit-insert-mode)
   '(|se| . exit-standout-mode)
   '(|ue| . exit-underline-mode)
   '(|vb| . flash-screen)
   '(|ff| . form-feed)
   '(|fs| . from-status-line)
   '(|i1| . init-1string)
   '(|is| . init-2string)
   '(|i3| . init-3string)
   '(|if| . init-file)
   '(|ic| . insert-character)
   '(|al| . insert-line)
   '(|ip| . insert-padding)
   '(|kb| . key-backspace)
   '(|ka| . key-catab)
   '(|kC| . key-clear)
   '(|kt| . key-ctab)
   '(|kD| . key-dc)
   '(|kL| . key-dl)
   '(|kd| . key-down)
   '(|kM| . key-eic)
   '(|kE| . key-eol)
   '(|kS| . key-eos)
   '(|k0| . key-f0)
   '(|k1| . key-f1)
   '(|k;| . key-f10)
   '(|k2| . key-f2)
   '(|k3| . key-f3)
   '(|k4| . key-f4)
   '(|k5| . key-f5)
   '(|k6| . key-f6)
   '(|k7| . key-f7)
   '(|k8| . key-f8)
   '(|k9| . key-f9)
   '(|kh| . key-home)
   '(|kI| . key-ic)
   '(|kA| . key-il)
   '(|kl| . key-left)
   '(|kH| . key-ll)
   '(|kN| . key-npage)
   '(|kP| . key-ppage)
   '(|kr| . key-right)
   '(|kF| . key-sf)
   '(|kR| . key-sr)
   '(|kT| . key-stab)
   '(|ku| . key-up)
   '(|ke| . keypad-local)
   '(|ks| . keypad-xmit)
   '(|l0| . lab-f0)
   '(|l1| . lab-f1)
   '(|la| . lab-f10)
   '(|l2| . lab-f2)
   '(|l3| . lab-f3)
   '(|l4| . lab-f4)
   '(|l5| . lab-f5)
   '(|l6| . lab-f6)
   '(|l7| . lab-f7)
   '(|l8| . lab-f8)
   '(|l9| . lab-f9)
   '(|mo| . meta-off)
   '(|mm| . meta-on)
   '(|nw| . newline)
   '(|pc| . pad-char)
   '(|DC| . parm-dch)
   '(|DL| . parm-delete-line)
   '(|DO| . parm-down-cursor)
   '(|IC| . parm-ich)
   '(|SF| . parm-index)
   '(|AL| . parm-insert-line)
   '(|LE| . parm-left-cursor)
   '(|RI| . parm-right-cursor)
   '(|SR| . parm-rindex)
   '(|UP| . parm-up-cursor)
   '(|pk| . pkey-key)
   '(|pl| . pkey-local)
   '(|px| . pkey-xmit)
   '(|ps| . print-screen)
   '(|pf| . prtr-off)
   '(|po| . prtr-on)
   '(|rp| . repeat-char)
   '(|r1| . reset-1string)
   '(|r2| . reset-2string)
   '(|r3| . reset-3string)
   '(|rf| . reset-file)
   '(|rc| . restore-cursor)
   '(|cv| . row-address)
   '(|sc| . save-cursor)
   '(|sf| . scroll-forward)
   '(|sr| . scroll-reverse)
   '(|sa| . set-attributes)
   '(|st| . set-tab)
   '(|wi| . set-window)
   '(|ta| . tab)
   '(|ts| . to-status-line)
   '(|uc| . underline-char)
   '(|hu| . up-half-line)
   '(|iP| . init-prog)
   '(|K1| . key-a1)
   '(|K3| . key-a3)
   '(|K2| . key-b2)
   '(|K4| . key-c1)
   '(|K5| . key-c3)
   '(|pO| . prtr-non)
   '(|i2| . termcap-init2)
   '(|rs| . termcap-reset)
   '(|rP| . char-padding)
   '(|ac| . acs-chars)
   '(|pn| . plab-norm)
   '(|kB| . key-btab)
   '(|SX| . enter-xon-mode)
   '(|RX| . exit-xon-mode)
   '(|SA| . enter-am-mode)
   '(|RA| . exit-am-mode)
   '(|XN| . xon-character)
   '(|XF| . xoff-character)
   '(|eA| . ena-acs)
   '(|LO| . label-on)
   '(|LF| . label-off)
   '(|@1| . key-beg)
   '(|@2| . key-cancel)
   '(|@3| . key-close)
   '(|@4| . key-command)
   '(|@5| . key-copy)
   '(|@6| . key-create)
   '(|@7| . key-end)
   '(|@8| . key-enter)
   '(|@9| . key-exit)
   '(|@0| . key-find)
   '(|%1| . key-help)
   '(|%2| . key-mark)
   '(|%3| . key-message)
   '(|%4| . key-move)
   '(|%5| . key-next)
   '(|%6| . key-open)
   '(|%7| . key-options)
   '(|%8| . key-previous)
   '(|%9| . key-print)
   '(|%0| . key-redo)
   '(|&1| . key-reference)
   '(|&2| . key-refresh)
   '(|&3| . key-replace)
   '(|&4| . key-restart)
   '(|&5| . key-resume)
   '(|&6| . key-save)
   '(|&7| . key-suspend)
   '(|&8| . key-undo)
   '(|&9| . key-sbeg)
   '(|&0| . key-scancel)
   '(|*1| . key-scommand)
   '(|*2| . key-scopy)
   '(|*3| . key-screate)
   '(|*4| . key-sdc)
   '(|*5| . key-sdl)
   '(|*6| . key-select)
   '(|*7| . key-send)
   '(|*8| . key-seol)
   '(|*9| . key-sexit)
   '(|*0| . key-sfind)
   '(|#1| . key-shelp)
   '(|#2| . key-shome)
   '(|#3| . key-sic)
   '(|#4| . key-sleft)
   '(|%a| . key-smessage)
   '(|%b| . key-smove)
   '(|%c| . key-snext)
   '(|%d| . key-soptions)
   '(|%e| . key-sprevious)
   '(|%f| . key-sprint)
   '(|%g| . key-sredo)
   '(|%h| . key-sreplace)
   '(|%i| . key-sright)
   '(|%j| . key-srsume)
   '(|!1| . key-ssave)
   '(|!2| . key-ssuspend)
   '(|!3| . key-sundo)
   '(|RF| . req-for-input)
   '(|F1| . key-f11)
   '(|F2| . key-f12)
   '(|F3| . key-f13)
   '(|F4| . key-f14)
   '(|F5| . key-f15)
   '(|F6| . key-f16)
   '(|F7| . key-f17)
   '(|F8| . key-f18)
   '(|F9| . key-f19)
   '(|FA| . key-f20)
   '(|FB| . key-f21)
   '(|FC| . key-f22)
   '(|FD| . key-f23)
   '(|FE| . key-f24)
   '(|FF| . key-f25)
   '(|FG| . key-f26)
   '(|FH| . key-f27)
   '(|FI| . key-f28)
   '(|FJ| . key-f29)
   '(|FK| . key-f30)
   '(|FL| . key-f31)
   '(|FM| . key-f32)
   '(|FN| . key-f33)
   '(|FO| . key-f34)
   '(|FP| . key-f35)
   '(|FQ| . key-f36)
   '(|FR| . key-f37)
   '(|FS| . key-f38)
   '(|FT| . key-f39)
   '(|FU| . key-f40)
   '(|FV| . key-f41)
   '(|FW| . key-f42)
   '(|FX| . key-f43)
   '(|FY| . key-f44)
   '(|FZ| . key-f45)
   '(|Fa| . key-f46)
   '(|Fb| . key-f47)
   '(|Fc| . key-f48)
   '(|Fd| . key-f49)
   '(|Fe| . key-f50)
   '(|Ff| . key-f51)
   '(|Fg| . key-f52)
   '(|Fh| . key-f53)
   '(|Fi| . key-f54)
   '(|Fj| . key-f55)
   '(|Fk| . key-f56)
   '(|Fl| . key-f57)
   '(|Fm| . key-f58)
   '(|Fn| . key-f59)
   '(|Fo| . key-f60)
   '(|Fp| . key-f61)
   '(|Fq| . key-f62)
   '(|Fr| . key-f63)
   '(|cb| . clr-bol)
   '(|MC| . clear-margins)
   '(|ML| . set-left-margin)
   '(|MR| . set-right-margin)
   '(|Lf| . label-format)
   '(|SC| . set-clock)
   '(|DK| . display-clock)
   '(|RC| . remove-clock)
   '(|CW| . create-window)
   '(|WG| . goto-window)
   '(|HU| . hangup)
   '(|DI| . dial-phone)
   '(|QD| . quick-dial)
   '(|TO| . tone)
   '(|PU| . pulse)
   '(|fh| . flash-hook)
   '(|PA| . fixed-pause)
   '(|WA| . wait-tone)
   '(|u0| . user0)
   '(|u1| . user1)
   '(|u2| . user2)
   '(|u3| . user3)
   '(|u4| . user4)
   '(|u5| . user5)
   '(|u6| . user6)
   '(|u7| . user7)
   '(|u8| . user8)
   '(|u9| . user9)
   '(|op| . orig-pair)
   '(|oc| . orig-colors)
   '(|Ic| . initialize-color)
   '(|Ip| . initialize-pair)
   '(|sp| . set-color-pair)
   '(|Sf| . set-foreground)
   '(|Sb| . set-background)
   '(|ZA| . change-char-pitch)
   '(|ZB| . change-line-pitch)
   '(|ZC| . change-res-horz)
   '(|ZD| . change-res-vert)
   '(|ZE| . define-char)
   '(|ZF| . enter-doublewide-mode)
   '(|ZG| . enter-draft-quality)
   '(|ZH| . enter-italics-mode)
   '(|ZI| . enter-leftward-mode)
   '(|ZJ| . enter-micro-mode)
   '(|ZK| . enter-near-letter-quality)
   '(|ZL| . enter-normal-quality)
   '(|ZM| . enter-shadow-mode)
   '(|ZN| . enter-subscript-mode)
   '(|ZO| . enter-superscript-mode)
   '(|ZP| . enter-upward-mode)
   '(|ZQ| . exit-doublewide-mode)
   '(|ZR| . exit-italics-mode)
   '(|ZS| . exit-leftward-mode)
   '(|ZT| . exit-micro-mode)
   '(|ZU| . exit-shadow-mode)
   '(|ZV| . exit-subscript-mode)
   '(|ZW| . exit-superscript-mode)
   '(|ZX| . exit-upward-mode)
   '(|ZY| . micro-column-address)
   '(|ZZ| . micro-down)
   '(|Za| . micro-left)
   '(|Zb| . micro-right)
   '(|Zc| . micro-row-address)
   '(|Zd| . micro-up)
   '(|Ze| . order-of-pins)
   '(|Zf| . parm-down-micro)
   '(|Zg| . parm-left-micro)
   '(|Zh| . parm-right-micro)
   '(|Zi| . parm-up-micro)
   '(|Zj| . select-char-set)
   '(|Zk| . set-bottom-margin)
   '(|Zl| . set-bottom-margin-parm)
   '(|Zm| . set-left-margin-parm)
   '(|Zn| . set-right-margin-parm)
   '(|Zo| . set-top-margin)
   '(|Zp| . set-top-margin-parm)
   '(|Zq| . start-bit-image)
   '(|Zr| . start-char-set-def)
   '(|Zs| . stop-bit-image)
   '(|Zt| . stop-char-set-def)
   '(|Zu| . subscript-characters)
   '(|Zv| . superscript-characters)
   '(|Zw| . these-cause-cr)
   '(|Zx| . zero-motion)
   '(|Zy| . char-set-names)
   '(|Km| . key-mouse)
   '(|Mi| . mouse-info)
   '(|RQ| . req-mouse-pos)
   '(|Gm| . get-mouse)
   '(|AF| . set-a-foreground)
   '(|AB| . set-a-background)
   '(|xl| . pkey-plab)
   '(|dv| . device-type)
   '(|ci| . code-set-init)
   '(|s0| . set0-des-seq)
   '(|s1| . set1-des-seq)
   '(|s2| . set2-des-seq)
   '(|s3| . set3-des-seq)
   '(|ML| . set-lr-margin)
   '(|MT| . set-tb-margin)
   '(|Xy| . bit-image-repeat)
   '(|Zz| . bit-image-newline)
   '(|Yv| . bit-image-carriage-return)
   '(|Yw| . color-names)
   '(|Yx| . define-bit-image-region)
   '(|Yy| . end-bit-image-region)
   '(|Yz| . set-color-band)
   '(|YZ| . set-page-length)
   '(|S1| . display-pc-char)
   '(|S2| . enter-pc-charset-mode)
   '(|S3| . exit-pc-charset-mode)
   '(|S4| . enter-scancode-mode)
   '(|S5| . exit-scancode-mode)
   '(|S6| . pc-term-options)
   '(|S7| . scancode-escape)
   '(|S8| . alt-scancode-esc)
   '(|Xh| . enter-horizontal-hl-mode)
   '(|Xl| . enter-left-hl-mode)
   '(|Xo| . enter-low-hl-mode)
   '(|Xr| . enter-right-hl-mode)
   '(|Xt| . enter-top-hl-mode)
   '(|Xv| . enter-vertical-hl-mode)

   ; old capabilities
   '(|ko| . other-non-function-keys)
   '(|ma| . arrow-key-map)
   '(|ml| . memory-lock-above)
   '(|mu| . memory-unlock)
   '(|nl| . linefeed-if-not-lf)
   '(|bc| . backspace-if-not-bs)
   )
  )


;;;
;;; Utility 
;;;

(define (%flush-line iport)
  (until ((^[x] (or (char=? x #\newline) (eof-object? x))) (read-char iport))))


;;;
;;; Get path of Termcap source
;;;

(define (%termcap-source-path term :optional fallback)
  (cond [(find file-is-regular? %default-termcap-sources)]
        [(undefined? fallback)
         (error #`"Can't find termcap source of ',term'. Please set right $TERMCAP environment variable.")]
        [else fallback]))


;;;
;;; Grep the line of the selected term, from iport.
;;; Return the input port which begins the line of capabilities.
;;;

;; faster version. (hard to read to Schemer)
(define (%find-selected-term term iport :optional fallback)
  (let loop ()
    (let1 head (read-char iport)
      (cond [(eof-object? head) #f]
            [(char-whitespace? head) (loop)]
            [(or (char=? head #\:) (char=? head #\#))
             (begin (%flush-line iport) (loop))]
            [else
             (let1 terminal-types
                   (string-split (regexp-replace* #`",head,(read-line iport)"
                                                  #/^\s*/ ""
                                                  #/[:\|]?\\$/ "")
                                 #\|)
               (if (member term terminal-types) iport ;; fixme (cut rest of terminal-type label)
                   (loop)))]
            ))))


;;;
;;; Translation from normal-string to escape-code
;;;

(define (%escape-code-decode str)
  ;; fixme
  )


;;;
;;; <capinfo> := "boolsym" | "numsym#NN" | "strsym=code"
;;; <cap> := tcap-symbol | (tcap-symbol . value)
;;; 
;;; %split-capinfo :: capinfo -> cap
;;;

(define (%split-capinfo capinfo)
  (cond [(string-scan capinfo #\#) ; number
         (call-with-values (^[] (string-scan capinfo #\# 'both))
           (^[x y] (cons (string->symbol x) (string->number y))))]
        [(string-scan capinfo #\=) ; string
         (call-with-values (^[] (string-scan capinfo #\= 'both))
           (^[x y] (cons (string->symbol x) (%escape-code-decode y))))]
        [else (string->symbol capinfo)])) ; boolean


;;;
;;; Parce capabilities from input port
;;;

(define (%parse-capability iport)
  (let loop ([capinfo '()])
    (let* ([line (read-line iport)]
           [cap-line (regexp-replace* line #/^\s*:/ "" #/:?\\?$/ "")])
      (let1 capinfo (append capinfo (string-split cap-line #[:])) ; fixme (for "\\:")
        (if (string-suffix? "\\" line)
            (loop capinfo)
            (map %split-capinfo capinfo)))
      )))


;;;
;;; <caplst> := (cap ...)
;;; <cap> := tcap-symbol | (tcap-symbol value)
;;;
;;; %class-separation :: caplst -> (values true-list number-alist string-alist)
;;;

(define (%class-separation caplst)
  (let loop ([trues '()] [numbers '()] [strings '()] [rest (reverse caplst)])
    (if (null? rest) (values trues numbers strings)
        (let1 head (car rest)
          (cond
           [(symbol? head) ; boolean
            (loop (cons head trues) numbers strings (cdr rest))]
           [(number? (cdr head)) ; number 
            (loop trues (cons head number) strings (cdr rest))]
           [else ; string
            (loop trues number (cons head strings) (cdr rest))])))))


;;;
;;; Load Termcap source (Return capability-symbols receiver)
;;;

(define (load-termcap-source :key (term (sys-getenv "TERM")) path fallback)
  (call/cc (lambda (return)
  (let* ([file-path
          (cond [($ not $ undefined? path) path]
                [(undefined? fallback) (%termcap-source-path (x->string term))]
                [(%termcap-source-path (x->string term) #f)]
                [(return fallback)])]
         [source (open-input-file (x->string file-path))]
         [caplst ($ %parse-capability $ %find-selected-term term source)]) ; fixme (add support tcap-tc)
    (let-values ([(trues-tcap numbers-tcap strings-tcap) (%class-separation caplst)])
      (let ([numbers-alist
             (filter-map (^[dotlist]
                           (cond [(ref %table-of-numbers (car tcap) #f) => (cut cons <> (cdr tcap))]
                                 [else #f])) numbers-tcap)]
            [strings-alist
             (filter-map (^[dotlist]
                           (cond [(ref %table-of-strings (car dotlist) #f) => (cut cons <> (cdr dotlist))]
                                 [else #f])) strings-tcap)]
            [available-numbers (map car numbers-alist)]
            [available-strings (map car strings-alist)]
            [capability-alist (append numbers-alist strings-alist)]
            [true-booleans '()]
            [false-booleans '()])
        (hash-table-for-each %table-of-booleans
          (^[sym tcap] (if (memq tcap trues)
                           (begin (push! sym true-booleans)
                                  (push! (cons sym #t) capability-alist))
                           (begin (push! sym false-booleans)
                                  (push! (cons sym #f) capability-alist))
                                  )))
        (let1 table-of-capabilities (alist->hash-table capability-alist)
          (lambda (sym)
            (case sym
              [(true-booleans)  true-booleans]
              [(false-booleans) false-booleans]
              [(available-numbers)  available-numbers]
              [(available-strings)  available-strings]
              [else (ref table-of-capabilities sym (undefined))]))
          )))))))


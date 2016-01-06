(load "lib/lisp-unit.lisp")
(use-package :lisp-unit)

                                        ;#-quicklisp package position because sbcl --script launch basic sbcl
(let ((quicklisp-init (merge-pathnames "~/quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

                                        ; load tcp/sockets library quietly
(with-open-file (*standard-output* "/dev/null" :direction :output
                                   :if-exists :supersede)
                (ql:quickload "cl-ppcre"))

(load "src/player.lisp")

(define-test
  response-test-suite
  (with-open-file
   (*standard-output* "/dev/null" :direction :output :if-exists :supersede)
   (assert-false
    (get-response "{ sibur phiras, , nourriture nourriture deraumere, sibur thystame}" nil nil nil nil))
   (assert-false
    (get-response "{sibur phiras, , nourriture  nourriture deraumere, sibur thystame}" nil nil nil nil))
   (assert-false
    (get-response "{sibur phiras,  , nourriture nourriture deraumere, sibur thystame}" nil nil nil nil))
   (assert-false
    (get-response "{sibur phiras, , nourriture nourriture deramere, sibur thystame}" nil nil nil nil))
   (assert-false
    (get-response "{sibur phiras, , nourriture nourriture deraumere, sibur thystame }" nil nil nil nil))
   (assert-false
    (get-response "{sibur phis, , nourriture nourriture deraumere, sibur thystame}" nil nil nil nil))
   (assert-false
    (get-response "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame  4}" nil nil nil nil))
   (assert-false
    (get-response "{nourriture 10 , linemate 4, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4}" nil nil nil nil))
   (assert-false
    (get-response "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0, phiras f, thystame 4}" nil nil nil nil))
   (assert-false
    (get-response "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0 , phiras 0, thystame 4}" nil nil nil nil))
   (assert-false
    (get-response "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4 }" nil nil nil nil))
   (assert-false
    (get-response "message 12, rtghjdf" nil nil nil nil))
   (assert-false
    (get-response " message 2, rtghjdf" nil nil nil nil))
   (assert-false
    (get-response "message 2 , rtghjdf" nil nil nil nil))
   (assert-false
    (get-response "messge 2, rtghjdf" nil nil nil nil))
   (assert-false
    (get-response " ok" nil nil nil nil))
   (assert-false
    (get-response " ko" nil nil nil nil))
   (assert-false
    (get-response "ok " nil nil nil nil))
   (assert-false
    (get-response "ko " nil nil nil nil))
   ))

(define-test
  cmd-test-suite
  (let ((x '(0)))
    (get-response "ok" nil nil x nil) (assert-equal '(0) x)
    (get-response "ko" nil nil x nil) (assert-equal '(1) x)
    (get-response "ok" nil nil x nil) (assert-equal '(0) x)
    )
  )

(define-test
  vision-test-suite
  (let (x)
    (setq x '(0))
    (get-response "{linemate sibur, phiras phiras, deraumere, sibur sibur sibur thystame}" x nil nil nil)
    (assert-equal '((0 |linemate| |sibur|) (1 |phiras| |phiras|) (2 |deraumere|) (3 |sibur| |sibur| |sibur| |thystame|)) x)
    (get-response "{sibur, nourriture sibur phiras phiras, nourriture nourriture deraumere, sibur thystame}" x nil nil nil)
    (assert-equal '((0 |sibur|) (1 |nourriture| |sibur| |phiras| |phiras|) (2 |nourriture| |nourriture| |deraumere|) (3 |sibur| |thystame|)) x)
    (get-response "{, nourriture sibur phiras phiras, nourriture nourriture deraumere, sibur thystame}" x nil nil nil)
    (assert-equal '((0) (1 |nourriture| |sibur| |phiras| |phiras|) (2 |nourriture| |nourriture| |deraumere|) (3 |sibur| |thystame|)) x)
    (get-response "{sibur phiras, , nourriture nourriture deraumere, sibur thystame}" x nil nil nil)
    (assert-equal '((0 |sibur| |phiras|) (1) (2 |nourriture| |nourriture| |deraumere|) (3 |sibur| |thystame|)) x)
    )
  (assert-equal
   '((0 |linemate| |sibur|) (1 |phiras| |phiras|) (2 |deraumere|) (3 |sibur| |sibur| |sibur| |thystame|))
   (get-vision "{linemate sibur, phiras phiras, deraumere, sibur sibur sibur thystame}"))
  (assert-equal
   '((0 |sibur|) (1 |nourriture| |sibur| |phiras| |phiras|) (2 |nourriture| |nourriture| |deraumere|) (3 |sibur| |thystame|))
   (get-vision "{sibur, nourriture sibur phiras phiras, nourriture nourriture deraumere, sibur thystame}"))
  (assert-equal
   '((0) (1 |nourriture| |sibur| |phiras| |phiras|) (2 |nourriture| |nourriture| |deraumere|) (3 |sibur| |thystame|))
   (get-vision "{, nourriture sibur phiras phiras, nourriture nourriture deraumere, sibur thystame}"))
  (assert-equal
   '((0 |sibur| |phiras|) (1) (2 |nourriture| |nourriture| |deraumere|) (3 |sibur| |thystame|))
   (get-vision "{sibur phiras, , nourriture nourriture deraumere, sibur thystame}"))
  )

(define-test
  inventory-get-suite
  (let ((x '(0)))
    (get-response "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4}" nil x nil nil)
    (assert-equal '((|nourriture| . 10) (|linemate| . 4) (|deraumere| . 5)(|sibur| . 6)(|mendiane| . 0)(|phiras| . 0)(|thystame| . 4)) x)
    (get-response "{nourriture 5510, linemate 9864, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4}" nil x nil nil)
    (assert-equal '((|nourriture| . 5510) (|linemate| . 9864) (|deraumere| . 5)(|sibur| . 6)(|mendiane| . 0)(|phiras| . 0)(|thystame| . 4)) x)
    )
  (assert-equal '((|nourriture| . 10) (|linemate| . 4) (|deraumere| . 5)(|sibur| . 6)(|mendiane| . 0)(|phiras| . 0)(|thystame| . 4))
                (get-inventory "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4}"))
  (assert-equal '((|nourriture| . 5510) (|linemate| . 9864) (|deraumere| . 5)(|sibur| . 6)(|mendiane| . 0)(|phiras| . 0)(|thystame| . 4))
                (get-inventory "{nourriture 5510, linemate 9864, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4}"))
  )

(define-test
  broadcast-test-suite
  (let ((x '(4)))
    (get-response "message 5, 23456cz" nil nil nil x)
    (assert-equal '(5 "23456cz") x)
    (get-response "message 2, 23456cz" nil nil nil x)
    (assert-equal '(2 "23456cz") x)
    (get-response "message 5, 12345!@#$%QWERqwer" nil nil nil x)
    (assert-equal '(5 "12345!@#$%QWERqwer") x)
    )
  )

(define-test inventory-checking-suite
  (assert-equal '|nourriture| (check-inventory '((|nourriture| 3) (|linemate| 0) (|deraumere| 3)(|sibur| 2)(|mendiane| 0)(|phiras| 0)(|thystame| 1)) 1))
  (assert-false (check-inventory '((|nourriture| 5) (|linemate| 1) (|deraumere| 3)(|sibur| 2)(|mendiane| 0)(|phiras| 0)(|thystame| 1)) 1))
  (assert-equal '|linemate| (check-inventory '((|nourriture| 5) (|linemate| 0) (|deraumere| 3)(|sibur| 2)(|mendiane| 0)(|phiras| 0)(|thystame| 1)) 1))
  (assert-equal '|linemate| (check-inventory '((|nourriture| 5) (|linemate| 1) (|deraumere| 0)(|sibur| 0)(|mendiane| 0)(|phiras| 0)(|thystame| 1)) 3))
  (assert-equal '|deraumere| (check-inventory '((|nourriture| 5) (|linemate| 2) (|deraumere| 0)(|sibur| 2)(|mendiane| 0)(|phiras| 0)(|thystame| 1)) 2))
  (assert-equal '|deraumere| (check-inventory '((|nourriture| 5) (|linemate| 2) (|deraumere| 1)(|sibur| 2)(|mendiane| 0)(|phiras| 0)(|thystame| 1)) 5))
  (assert-equal '|sibur| (check-inventory '((|nourriture| 5) (|linemate| 2) (|deraumere| 2)(|sibur| 0)(|mendiane| 0)(|phiras| 0)(|thystame| 1)) 2))
  (assert-equal '|sibur| (check-inventory '((|nourriture| 5) (|linemate| 2) (|deraumere| 2)(|sibur| 1)(|mendiane| 0)(|phiras| 0)(|thystame| 1)) 4))
  (assert-equal '|mendiane| (check-inventory '((|nourriture| 5) (|linemate| 2) (|deraumere| 2)(|sibur| 3)(|mendiane| 2)(|phiras| 0)(|thystame| 1)) 5))
  (assert-equal '|mendiane| (check-inventory '((|nourriture| 5) (|linemate| 2) (|deraumere| 2)(|sibur| 3)(|mendiane| 0)(|phiras| 0)(|thystame| 1)) 7))
  (assert-equal '|phiras| (check-inventory '((|nourriture| 5) (|linemate| 2) (|deraumere| 2)(|sibur| 3)(|mendiane| 3)(|phiras| 0)(|thystame| 1)) 3))
  (assert-equal '|phiras| (check-inventory '((|nourriture| 5) (|linemate| 2) (|deraumere| 2)(|sibur| 3)(|mendiane| 3)(|phiras| 1)(|thystame| 1)) 7))
  (assert-equal '|thystame| (check-inventory '((|nourriture| 5) (|linemate| 2) (|deraumere| 2)(|sibur| 3)(|mendiane| 3)(|phiras| 2)(|thystame| 0)) 7))
 )


(run-tests)

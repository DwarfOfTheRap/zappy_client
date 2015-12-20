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
  vision-test-list
  (assert-equal
    '("linemate sibur" "phiras phiras" "deraumere" "sibur sibur sibur thystame")
    (get-vision "{linemate sibur, phiras phiras, deraumere, sibur sibur sibur thystame}"))
  (assert-equal
    '("sibur" "nourriture sibur phiras phiras" "nourriture nourriture deraumere" "sibur thystame")
    (get-vision "{sibur, nourriture sibur phiras phiras, nourriture nourriture deraumere, sibur thystame}"))
  (assert-equal
    '("" "nourriture sibur phiras phiras" "nourriture nourriture deraumere" "sibur thystame")
    (get-vision "{, nourriture sibur phiras phiras, nourriture nourriture deraumere, sibur thystame}"))
  (assert-equal
    '("sibur phiras" "" "nourriture nourriture deraumere" "sibur thystame")
    (get-vision "{sibur phiras, , nourriture nourriture deraumere, sibur thystame}"))
  )

(define-test
  inventory-test-list
  (assert-equal '(("nourriture" "10") ("linemate" "4"))
                (get-inventory "{nourriture 10, linemate 4}")
   )
  )

;(print (get-inventory "{nourriture 4, super 5, other 8, string 23, otherthing 56, vxcc 6}"))
(run-tests)

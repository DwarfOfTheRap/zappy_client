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
  response-test
  (with-open-file
   (*standard-output* "/dev/null" :direction :output
                      :if-exists :supersede)
  (assert-false
    (get-response "{ sibur phiras, , nourriture nourriture deraumere, sibur thystame}" nil nil nil))
  (assert-false
    (get-response "{sibur phiras, , nourriture  nourriture deraumere, sibur thystame}" nil nil nil))
  (assert-false
    (get-response "{sibur phiras,  , nourriture nourriture deraumere, sibur thystame}" nil nil nil))
  (assert-false
    (get-response "{sibur phiras, , nourriture nourriture deramere, sibur thystame}" nil nil nil))
  (assert-false
    (get-response "{sibur phiras, , nourriture nourriture deraumere, sibur thystame }" nil nil nil))
  (assert-false
    (get-response "{sibur phis, , nourriture nourriture deraumere, sibur thystame}" nil nil nil))
  (assert-false
    (get-response "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame  4}" nil nil nil))
  (assert-false
    (get-response "{nourriture 10 , linemate 4, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4}" nil nil nil))
  (assert-false
    (get-response "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0, phiras f, thystame 4}" nil nil nil))
  (assert-false
    (get-response "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0 , phiras 0, thystame 4}" nil nil nil))
  (assert-false
    (get-response "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4 }" nil nil nil))
  (assert-true
    (get-response "ok" nil nil nil))
  (assert-true
    (get-response "ko" nil nil nil))
  (assert-true
    (get-response "{linemate sibur, phiras phiras, deraumere, sibur sibur sibur thystame}" nil nil nil))
  (assert-true
    (get-response "{nourriture 5510, linemate 9864, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4}" nil nil nil))
  ))

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
  (assert-equal '(("nourriture" "10") ("linemate" "4") ("deraumere" "5")("sibur" "6")("mendiane" "0")("phiras" "0")("thystame" "4"))
                (get-inventory "{nourriture 10, linemate 4, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4}"))
  (assert-equal '(("nourriture" "5510") ("linemate" "9864") ("deraumere" "5")("sibur" "6")("mendiane" "0")("phiras" "0")("thystame" "4"))
                (get-inventory "{nourriture 5510, linemate 9864, deraumere 5, sibur 6, mendiane 0, phiras 0, thystame 4}"))
  )

(run-tests)

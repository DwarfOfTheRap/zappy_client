(load "lib/lisp-unit.lisp")
(use-package :lisp-unit)

(load "src/client.lisp")

(define-test accurate-coord
             (assert-equal (list 2 5) (get-coordinates "2 5"))
             (assert-equal (list 42 5) (get-coordinates "42 5"))
             (assert-equal (list 2 54) (get-coordinates "2 54"))
             (assert-equal (list 25 52) (get-coordinates "25 52"))
             (assert-equal (list 2006 5678) (get-coordinates "2006 5678"))
             )

;(define-test coordinate-bad-entry
;             (assert-prints "Connection error: unable to connect or corrupt servor message" (get-coordinates "2 5 7"))
;             (assert-prints "Connection error: unable to connect or corrupt servor message" (get-coordinates "2ewwqe 5"))
;             (assert-prints "Connection error: unable to connect or corrupt servor message" (get-coordinates "2 5qwdf"))
;             (assert-prints "Connection error: unable to connect or corrupt servor message" (get-coordinates " 2 5"))
;             (assert-prints "Connection error: unable to connect or corrupt servor message" (get-coordinates "2 5 "))
;             )

(run-tests)

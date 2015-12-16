(load "lib/lisp-unit.lisp")
(use-package :lisp-unit)

(load "src/client.lisp")

(define-test bad-args
          (with-open-file (*standard-output* "/dev/null" :direction :output
                                   :if-exists :supersede)
             (assert-false (main '("")))
             (assert-false (main '("-t" "machin")))
             (assert-false (main '("-n" "machin")))
             (assert-false (main '("-n" "machin" "-y" "truc")))
             (assert-false (main '("-n" "machin" "-p" "truc")))
             (assert-false (main '("-n" "machin" "-p")))
             (assert-false (main '("-n" "machin" "-p" "342ui")))
             (assert-false (main '("-n" "machin" "-h" "localhost")))
             (assert-false (main '("-n" "machin" "-p" "54343" "localhost")))
             (assert-false (main '("-n" "machin" "-p" "54343" "localhost" "test")))
             (assert-false (main '("-n" "-p" "54343")))
             (assert-false (main '("machin" "-n" "-p" "54343")))
             )
          )

(define-test accurate-coord
             (assert-equal (list 2 5) (get-coordinates "2 5"))
             (assert-equal (list 42 5) (get-coordinates "42 5"))
             (assert-equal (list 2 54) (get-coordinates "2 54"))
             (assert-equal (list 25 52) (get-coordinates "25 52"))
             (assert-equal (list 2006 5678) (get-coordinates "2006 5678"))
             )

(define-test coordinate-bad-entry
             (assert-false (get-coordinates "2 5 7"))
             (assert-false (get-coordinates "2ewwqe 5"))
             (assert-false (get-coordinates "2 5qwdf"))
             (assert-false (get-coordinates " 2 5"))
             (assert-false (get-coordinates "2 5 "))
             )

(run-tests)

(load "lib/lisp-unit.lisp")
(use-package :lisp-unit)

(load "src/client.lisp")

(defun create-server (port bienvenue team coord)
  (let* ((socket (usocket:socket-listen "127.0.0.1" port))
         (connection (usocket:socket-accept socket :element-type 'character)))
    (unwind-protect 
        (progn
          (format (usocket:socket-stream connection) "~a~%" bienvenue)
          (force-output (usocket:socket-stream connection))
          (format (usocket:socket-stream connection) "~a~%" team)
          (force-output (usocket:socket-stream connection))
          (format (usocket:socket-stream connection) "~a~%" coord)
          (force-output (usocket:socket-stream connection)))
      (progn
        (usocket:socket-close connection)
        (usocket:socket-close socket)))))

(define-test bad-args
  (with-open-file
   (*standard-output* "/dev/null" :direction :output
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

(define-test create-client-test
  (with-open-file
   (*standard-output* "/dev/null" :direction :output
                      :if-exists :supersede)
   (assert-false (create-client 67878 "localhost" "team"))
   (let ((x (sb-thread:make-thread (lambda () (create-server 7777 "BIENVENUE" "0" "43 654")))))
     (sleep 1)
     (assert-true (create-client 7777 "127.0.0.1" "team"))
     (sb-thread:terminate-thread x)
     )
   (let ((x (sb-thread:make-thread (lambda () (create-server 7778 "BIENvENUE" "0" "43 654")))))
     (sleep 1)
     (assert-false (create-client 7778 "127.0.0.1" "team"))
     (sb-thread:terminate-thread x)
     )
   (let ((x (sb-thread:make-thread (lambda () (create-server 7779 "BIENVENUE" "re0" "43 654")))))
     (sleep 1)
     (assert-false (create-client 7779 "127.0.0.1" "team"))
     (sb-thread:terminate-thread x)
     )
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
(sb-ext:quit)

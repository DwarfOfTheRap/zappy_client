;#-quicklisp package position because sbcl --script launch basic sbcl
(let ((quicklisp-init (merge-pathnames "~/quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

; load tcp/sockets library quietly
(with-open-file (*standard-output* "/dev/null" :direction :output
                                   :if-exists :supersede)
  (ql:quickload "cl-ppcre"))

;Variable object: contain the game object list
(defvar *object* '("food" "linemate" "deraumere" "sibur" "mendiane" "phiras" "thystame"))

(defun get-inventory (str)
  (let ((case-list (cl-ppcre:all-matches-as-strings "[^}{\(, \)]+" str)))
    (loop for x in case-list
          for y = (cl-ppcre:split "^\\s+" x )
          collect y)
    )
  )

(defun get-vision (str)
  (let ((case-list (cl-ppcre:all-matches-as-strings "[^}{\(, \)]+" str)))
    (loop for x in case-list collect x)))

(print (get-inventory "{superstring 4, super 5, other 8, string 23, otherthing 56, vxcc 6}"))
;(defun get-response (str vision inventory help)
;  (cond
;    ((string= "{{" (char str 0))
;     (setf vision (parse-vision str)))
;    (t (progn
;         (format t "Unexpected message: ~a~%" str) (sb-thread:terminate-thread sb-thread:*current-thread*)))
;    )
;  )
;
;(defun game-loop (newcli socket coord)
;  "loop with a throttle until it catch a response from server"
;  (let ((vision nil) (inventory nil) (help nil) (objective nil)) ;should set inventory with 10f
;    (loop
;      (if (listen (usocket:socket-stream socket))
;        ;(progn
;        (get-response (read-line (usocket:socket-stream socket)) vision inventory help)
;        ; )
;        (sleep 0.001)
;        )
;      )
;    )
;  )

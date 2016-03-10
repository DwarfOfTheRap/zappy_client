                                        ;#-quicklisp package position because sbcl --script launch basic sbcl
(let ((quicklisp-init (merge-pathnames "~/quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

                                        ; load tcp/sockets library quietly
(with-open-file (*standard-output* "/dev/null" :direction :output
                                               :if-exists :supersede)
  (ql:quickload "usocket")
  (ql:quickload "cl-ppcre"))

; socket function used in all files
(defun socket-print (str socket)
  "send string through the socket without waiting"
  (format (usocket:socket-stream socket) "~a" str)
  (force-output (usocket:socket-stream socket))
  )

                                        ;load file.
(load "src/player.lisp")

                                        ;get coordinate from string
(defun get-coordinates (str)
  "This function take a string as parameter and return an int pair or call
  connection-error if the parameters are bad"
  (if (/= (count #\Space str :test #'equalp) 1)
      (return-from get-coordinates nil))
  (let ((spc (position #\Space str :test #'equalp)))
    (mapcar (lambda (x) (handler-case (parse-integer x)
                          (error () (return-from get-coordinates nil) nil)))
            (list (subseq str 0 spc) (subseq str (+ 1 spc)))
            )
    )
  )

                                        ;Starter client
(defun create-client (port hostname team)
  "This function create a client waiting for a 'BIENVENUE\n' input
  before sending his team name, and call itself in another thread if the number
  of client send by the server is not null"
  (let ((socket (handler-case (usocket:socket-connect hostname port :element-type 'character)
                  (error () (format t "Socket error: unable to connect to server~%")
                    (return-from create-client nil)))))
    (unwind-protect
         (progn
                                        ;Wait for BIENVENUE
           (usocket:wait-for-input socket)
           (if (string= (read-line (usocket:socket-stream socket)) "BIENVENUE")
               (socket-print (format nil "~a~%" team) socket)
               (progn (format t "Communication error: bad first message~%") (return-from create-client nil)))
                                        ; Get number of new connections
           (usocket:wait-for-input socket)
           (if (> (handler-case (parse-integer (read-line (usocket:socket-stream socket)))
                    (error () (format t "Communication error: <nb-team> not a number~%") (return-from create-client nil))) 1)
               (sb-thread:make-thread (lambda () (create-client port hostname team)))
               )
                                        ; Get map coordonates
           (usocket:wait-for-input socket)
           (let ((coord (get-coordinates (read-line (usocket:socket-stream socket)))))
             (if (not coord)
                 (progn (format t "Communication error: bad coordinates~%") (return-from create-client nil))
                 )
             (game-loop '(port hostname team) socket coord team)
             )
           (return-from create-client t))
      (usocket:socket-close socket))))

                                        ; Usage function
(defun usage ()
  "Usage function: print usage if the user mess with paramaters"
  (format t "Usage: ./client -n <team> -p <port> [-h <hostname>]
          -n team name
          -p port
          -h hosting machine. Localhost by default~%"
          )
  t
  )

;(defun thread-closure ()
;  (let ((main-thread sb-thread:*current-thread*))
;    (lambda (f)
;      (sb-thread:make-thread main-thread (lambda () (funcall f))))))

(defun newloop (port hostname team)
    (sb-thread:make-thread (lambda () (create-client port hostname team)))
    (loop
      (sleep 1)
      (if (= 1 (list-length (sb-thread:list-all-threads)))
        (return-from newloop nil)
        )
    )
  )
                                        ; Entry point: the program start here
(defun main (lst)
  (let ((hostname "localhost") team port)
    (loop for a in lst by #'cddr
          for b in (cdr lst) by #'cddr when (and (evenp (length lst)) (>= 6 (length lst))) ; check if args are even and < 6
          do (cond
               ((string= "-n" a) (setq team b))
               ((string= "-p" a) (setq port (handler-case (parse-integer b)
                                              (error () (or (format t "<port> need to be an int~%")(usage)) (return-from main nil))))) ; Usage sent if port isn't an int : maybe sending an error: bad parameter could be better?
               ((string= "-h" a) (setq hostname b))
               (t (and (usage) (return-from main nil)))
               ))
                                        ;Check if port or team wasnt given
    (or (not (or (null team) (null port)))
        (and (usage) (return-from main nil)))
    (newloop port hostname team))
  )

#!/nfs/zfs-student-2/users/frale-co/.brew/bin/sbcl --script

;#-quicklisp package position because sbcl --script launch basic sbcl
(let ((quicklisp-init (merge-pathnames "~/quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

; load tcp/sockets library quietly
(with-open-file (*standard-output* "/dev/null" :direction :output
                                   :if-exists :supersede)
  (ql:quickload "usocket"))

;Starter client
(defun create-client (port)
  "Basic client"
  (let ((socket (usocket:socket-connect "127.0.0.1" port :element-type 'character)))
    (unwind-protect 
      (progn
        (usocket:wait-for-input socket)
        (format t "~A~%" (read-line (usocket:socket-stream socket))))
      (usocket:socket-close socket))))

; Usage function
(defun usage ()
  "Usage function: print usage if the user mess with paramaters"
  (format t "Usage: ./client -n <team> -p <port> [-h <hostname>]
          -n team name
          -p port
          -h hosting machine. Localhost by default~%"
          )
  )

; Entry point: the program start here
(let (lst team port hostname)
  (setq lst (cdr *posix-argv*))
  (setq hostname "localhost")
  (loop for a in lst by #'cddr
        for b in (cdr lst) by #'cddr when (and (evenp (length lst)) (>= 6 (length lst))) ; check if args are even and < 6
        do (cond
             ((string= "-n" a) (setq team b))
             ((string= "-p" a) (setq port (handler-case (parse-integer b)
                                            (error (c) (or (usage) (sb-ext:exit))
                                                   nil)))) ; Usage sent if port isn't an int
             ((string= "-h" a) (setq hostname b))
             (t (or (usage) (sb-ext:exit)))
             ))
  ;Check if port or team wasnt given
  (or (not (or (null team) (null port)))
      (usage) (sb-ext:exit))

  (format t "team: ~a; port ~d; host ~a ~%" team port hostname))

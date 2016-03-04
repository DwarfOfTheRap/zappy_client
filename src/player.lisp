                                        ; regex variables
(defvar *vision-regex* "^\{(|(nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame)( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))*| )(,(( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))+| ))+\}$")
(defvar *inventory-regex*  "^\{nourriture \\d+, linemate \\d+, deraumere \\d+, sibur \\d+, mendiane \\d+, phiras \\d+, thystame \\d+\}$")
(defvar *broadcast-regex* "^message [1-9], .*$")
(defvar *push-regex* "^deplacement \\d$")
(defvar *take-regex* "^(prend)|(pose) (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame)")
                                        ; Level up needs
(defvar *stone-per-level* '((1 0 0 0 0 0) (1 1 1 0 0 0) (2 0 1 0 2 0) (1 1 2 0 1 0) (1 2 1 3 0 0) (1 2 3 0 1 0) (2 2 2 2 2 1)))
(defvar *symbol-list* '(|nourriture| |linemate| |deraumere| |sibur| |mendiane| |phiras| |thystame|))
                                        ;base-inventory
(defvar *base-inventory* '((|nourriture| . 10)(|linemate| . 0)(|deraumere| . 0)(|sibur| . 0)(|mendiane| . 0)(|phiras| . 0)(|thystame| . 0)))

                                        ;socket force-push function: could be used in broadcast.lisp
(defun force-socket-output (str socket) ;TODO: maybe looping inside this one if needed
  (format (usocket:socket-stream socket) "~a~%" str)
  (force-output (usocket:socket-stream socket))
  )

(load "src/broadcast.lisp")
(load "src/path.lisp")
(load "src/inventory.lisp")

(defun get-broadcast (str)
  "Read the broadcast response and return a tuple (direction . message): (int . str)"
  (cons (parse-integer (subseq str 8 9)) (subseq str 11)))

(load "src/vision.lisp")

(defun game-loop (newcli socket coord team)
  "loop with a throttle until it catch a response from server" ;TODO: better documentation
  (let ((state 'wandering) (vision '()) (inventory *base-inventory*) (command '()) (objective '()) (msg '()) (level 1))
    (loop
      (if (listen (usocket:socket-stream socket))
          (let ((str (read-line (usocket:socket-stream socket))))
            (cond
                                        ;reading and parsing server input
              ((cl-ppcre:scan "^(ok)|(ko)$" str)
               (progn
                 (if (> (list-length command) 10)
                     (force-socket-output (nth 10 command) socket))
                                        ;     (if (and (string= str "ok") (cl-ppcre:scan *take-regex* (car command)))
                                        ;         (setf inventory (update-inventory inventory (car command))))
                 (and (eq state 'wandering )(string= (car command) (format nil "broadcast ~a, ~a" team level))
                     (setf state 'broadcasting))
                 (setf command (cdr command))))
              ((cl-ppcre:scan *inventory-regex* str)
               (progn (setf inventory (get-inventory str))
                      (setf command (cdr command)))
               )
              ((cl-ppcre:scan *vision-regex* str)
               (progn (setf vision (get-vision str))
                      (setf command (cdr command)))
               )
              ((cl-ppcre:scan *broadcast-regex* str)
               (setf msg (get-broadcast str))) ;TODO: create a function that organize messages and drop useless messages and/or change state?
              ((cl-ppcre:scan *push-regex* str)
               (setf command (cdr command)))
              (t (progn (format t "Unexpected message: ~a~%" str) (return-from game-loop nil)))
              )
            )
          (sleep 0.001)
          )
                                        ;State machine
      (if (null command)
          (cond
            ((eq state 'broadcasting)
             (progn (setf command (format nil "broadcast ~a, ~a" team level))
                    (force-socket-output command socket))
             )
                                        ;   ((eq state 'waiting)
                                        ;    (do stuff)
                                        ;    )
            ((null vision)
             (force-socket-output "voir" socket)
             )
                                        ; ((eq state 'joining)
                                        ;  (do stuff)
                                        ;  )
            ((eq state 'wandering)
             (let ((needs (check-inventory inventory level)))
               (if (null needs)
                   (progn (setf command (format nil "broadcast ~a, ~a" team level))
                          (force-socket-output command socket))
                   (progn (setf command (cons (make-path (car (search-in-vision needs vision))) "inventaire"))
                          (setf vision nil)
                          (loop for instruction in command
                                for i from 1 to 10
                                do (force-socket-output instruction socket)))))
             )
            (t nil)
            )
          )
      )
    )
  )

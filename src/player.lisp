                                        ; regex variables
(defvar *vision-regex* "^\{(|(nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame)( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))*| )(,(( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))+| ))+\}$")
(defvar *inventory-regex*  "^\{nourriture \\d+, linemate \\d+, deraumere \\d+, sibur \\d+, mendiane \\d+, phiras \\d+, thystame \\d+\}$")
(defvar *broadcast-regex* "^message [1-9], .*$")
(defvar *push-regex* "^deplacement \\d$")
(defvar *take-regex* "^(prend)|(pose) (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame)")
(defvar *new-level* "niveau actuel : \\d")
                                        ; Level up needs
(defvar *stone-per-level* '((1 0 0 0 0 0) (1 1 1 0 0 0) (2 0 1 0 2 0) (1 1 2 0 1 0) (1 2 1 3 0 0) (1 2 3 0 1 0) (2 2 2 2 2 1)))
(defvar *symbol-list* '(|nourriture| |linemate| |deraumere| |sibur| |mendiane| |phiras| |thystame|))
                                        ;base-inventory
(defvar *base-inventory* '((|nourriture| . 10)(|linemate| . 0)(|deraumere| . 0)(|sibur| . 0)(|mendiane| . 0)(|phiras| . 0)(|thystame| . 0)))

                                        ;socket force-push function: could be used in broadcast.lisp
(defun force-socket-output (command socket)
  "send the 10 first commands to the server
   @rgs: list, usocket
   @return: nil"
  (loop for str in command
        for i from 1 to 10
        do (socket-print (format nil "~a~%" str) socket)))

(defmacro set-and-send (command list socket)
  "Macro used to set a list of string to the command var
   AND sending it to the server through force-socket-output
   @rgs: variable, list, usocket"
  (list 'progn (list 'setq command list) (list 'force-socket-output list socket)))

(defun set-state ()
  "Closure saveing the state and comparing it
   @args: nil
   @return: (func ('sym) -> nil . func ('sym) -> bool)"
  (let ((state 'wandering))
    (cons
     (lambda (x) (setf state x))
     (lambda (x) (if (eq x state) t nil)))))

(load "src/broadcast.lisp")
(load "src/path.lisp")
(load "src/inventory.lisp")
(load "src/vision.lisp")

(defun game-loop (newcli socket coord team)
  "loop with a throttle until it catch a response from server" ;TODO: better documentation
  (let ((state (set-state)) (vision '()) (inventory *base-inventory*)
        (command '()) (objective '()) (msg '()) (level 1) (counter '()))
    (loop
      (if (listen (usocket:socket-stream socket))
          (let ((str (read-line (usocket:socket-stream socket))))
            (cond
                                        ;reading and parsing server input
              ((cl-ppcre:scan "^(ok)|(ko)$" str)
               (progn
                 (if (> (list-length command) 10)
                     (force-socket-output (cons (nth 10 command) nil) socket))
                 (and (funcall (cdr state) 'wandering )
                      (string= (car command) (format nil "broadcast ~a, ~a" team level))
                      (funcall (car state) 'broadcasting))
                 (setf command (cdr command)))
               )
              ((cl-ppcre:scan *inventory-regex* str)
               (setf inventory (get-inventory str) command (cdr command))
               )
              ((cl-ppcre:scan *vision-regex* str)
               (setf vision (get-vision str) command (cdr command))
               )
              ((cl-ppcre:scan *broadcast-regex* str)
               (let ((ret (get-broadcast str team level counter state)))
                 (and ret (setf msg ret)))
               )
              ((cl-ppcre:scan *push-regex* str)
               (setf command (cdr command))
               )
              ((string= str "elevation en cours")
               (progn (and (string= (car command) "incantation")
                           (setf command (cdr command)))
                      (funcall (car state) 'waiting))
               )
              ((cl-ppcre:scan *new-level* str)
               (progn (setf level (parse-integer (subseq str 16)))
                      (funcall (car state) 'wandering)
                      )
               )
              (t (progn (format t "Unexpected message: ~a~%" str)
                        (setf command (cdr command)))))
            )
          (sleep 0.001)
          )
                                        ;State machine
      (if (null command)
          (cond
            ((funcall (cdr state) 'broadcasting)
             (if (= 5 (funcall (third counter)))
                 (set-and-send command (put-down-incantation-stones level) socket)
                 (set-and-send command (cons (format nil "broadcast ~a, ~a" team level) nil) socket))
             )
            ((funcall (cdr state) 'waiting)
             (sleep 0.001)
             )
            ((null vision)
             (set-and-send command '("voir") socket)
             )
            ((funcall (cdr state) 'joining)
             (progn (join-for-incantation (car msg) vision team state level)
                    (setf vision nil))
             )
            ((funcall (cdr state) 'wandering)
             (let ((needs (check-inventory inventory level)))
               (if (null needs)
                   (progn (set-and-send command (cons (format nil "broadcast ~a, ~a" team level) nil) socket)
                          (setf counter (presence-counter)))
                   (progn (set-and-send command (append (make-path (car (search-in-vision needs vision)))
                                                        '("inventaire")) socket)
                          (setf vision nil))))
             )
            (t nil)
            )
          )
      )
    )
  )

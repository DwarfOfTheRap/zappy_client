                                        ; regex variables
(defvar *vision-regex* "^\{(|(nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame)( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))*| )(,(( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))+| ))+\}$")
(defvar *inventory-regex*  "^\{nourriture \\d+, linemate \\d+, deraumere \\d+, sibur \\d+, mendiane \\d+, phiras \\d+, thystame \\d+\}$")
(defvar *broadcast-regex* "^message [0-9],.*$")
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
        for i from 1 to 1
        do (socket-print (format nil "~a~%" str) socket)))

(defmacro set-and-send (command list socket)
  "Macro used to set a list of string to the command var
   AND sending it to the server through force-socket-output
   @rgs: variable, list, usocket"
  (list 'progn (list 'setq command list) (list 'force-socket-output list socket)))

(load "src/closure.lisp")
(load "src/broadcast.lisp")
(load "src/path.lisp")
(load "src/inventory.lisp")
(load "src/vision.lisp")

(defun game-loop (newcli socket coord team)
  "loop with a throttle until it catch a response from server"
  (let ((state (set-state)) (vision '()) (inventory *base-inventory*) (clock 0) (egg 1) (tim 0)
        (command '()) (count-step (set-counter)) (msg '()) (level 1) (counter (set-counter)) (present (set-counter)))
    (loop
      (if (listen (usocket:socket-stream socket))
          (let ((str (read-line (usocket:socket-stream socket))))
            (cond

              ((cl-ppcre:scan "^(ok)|(ko)$" str)
               (progn
                 (if (> (list-length command) 1)
                     (force-socket-output (cons (nth 1 command) nil) socket))
                 (and (funcall (cdr state) 'wandering )
                      (string= (car command) (format nil "broadcast ~a, ~a" team level))
                      (progn (funcall (third counter) 0)
                             (funcall (car state) 'broadcasting)))
                 (and (funcall (cdr state) 'laying) (string= (car command) "fork")
                      (funcall (car state) 'hatching))
                 (setf command (cdr command)))
               )

              ((cl-ppcre:scan *inventory-regex* str)
               (setf inventory (get-inventory str) command (cdr command))
               )

              ((cl-ppcre:scan *vision-regex* str)
               (setf vision (get-vision str) command (cdr command))
               )

              ((cl-ppcre:scan *broadcast-regex* str)
               (let ((ret (get-broadcast str team level counter state present)))
                 (if ret
                     (progn
                       (setf msg ret)
                       (and (funcall (cdr state) 'laying) (>= (funcall (fourth present)) 5)
                            (progn (setf command (remove "fork" command :test #'string=))
                                   (incf egg)
                                   (funcall (car state) 'hatching))))))
               )

              ((cl-ppcre:scan *push-regex* str)
               (setf command (cdr command)))

              ((string= str "elevation en cours")
               (progn (setf command '())
                      (funcall (third counter) 0)
                      (funcall (car state) 'chill))
               )

              ((cl-ppcre:scan *new-level* str)
               (progn (setf level (parse-integer (subseq str 16)))
                      (and (= level 8) (return-from game-loop))
                      (setf command '())
                      (funcall (third present) 0)
                      (funcall (car state) 'wandering)
                      )
               )

              ((cl-ppcre:scan "^\\d$" str)
               (progn (setf command (cdr command))
                      (if (> (parse-integer str) 0)
                          (progn (create-client (car newcli) (second newcli) (third newcli))
                                 (set-and-send command (list (format nil "broadcast connected: ~a, ~a" team level)) socket)
                                 (funcall (car state) 'wandering)))
                      )
               )
              ((string= "mort" str)
               (return-from game-loop nil)
               )
              (t (progn (format t "Unexpected message: ~a~%" str) (setf command (cdr command)))))
            )
          (sleep 0.00001)
          )

                                        ;State machine
      (if (null command)
          (cond
            ((funcall (cdr state) 'chill)
             (sleep 0.001)
             )
            ((funcall (cdr state) 'broadcasting)
             (progn
               (if (> 5 (funcall (fourth present)))
                 (if (and (> clock 77) (< clock 90))
                   (progn (incf clock 20) (set-and-send command (list "connect_nbr") socket))
                   (if (> clock 90)
                       (progn
                         (set-and-send command (list (format nil "broadcast egg: ~a, ~a"
                                                             (- 4 (funcall (fourth present))) team)
                                                     "fork") socket)
                         (funcall (first present))
                         (funcall (car state) 'hatching))
                       (incf clock 7)))
                   (setf clock 0))
               (if (<= 5 (funcall (fourth counter)))
                   (set-and-send command (put-down-incantation-stones level) socket)
                   (if (< (cdar inventory) 4)
                       (progn (funcall (car state) 'wandering)
                              (funcall (third counter) 0)
                              (set-and-send command (list (format nil "broadcast stop ~a, ~a" team level)) socket))
                       (if (> tim 120)
                           (progn (setf tim 0)
                                  (set-and-send command (list (format nil "broadcast ~a, ~a" team level)
                                                              "inventaire") socket))
                           (progn (incf tim 7)
                                  (set-and-send command (list (format nil "broadcast ~a, ~a" team level)) socket))))))
             )
            ((funcall (cdr state) 'laying)
             (if (< (funcall (fourth present)) 5)
                 (set-and-send command (list (format nil "broadcast lay: ~a" team) "fork") socket))
             )
            ((funcall (cdr state) 'waiting)
             (if (< (cdar inventory) 4)
                 (progn (funcall (car state) 'wandering)
                        (set-and-send command (list (format nil "broadcast stop ~a, ~a" team level)) socket))
                 (if (> tim 120)
                     (progn (setf tim 0)
                            (set-and-send command (list (format nil "broadcast ~a, ~a" team level) "inventaire") socket))
                     (progn (incf tim 7)
                            (set-and-send command '("voir") socket)))
                 )
             )
            ((funcall (cdr state) 'respond)
             (progn (funcall (car state) 'joining)
                    (set-and-send command (list (format nil "broadcast present: ~a, ~a" team level)) socket)
                    )
             )
            ((null vision)
             (set-and-send command '("voir") socket)
             )
            ((funcall (cdr state) 'hatching)
             (progn (set-and-send command (append (make-path (car (search-in-vision *symbol-list* vision))
                                                             count-step)
                                                  '("inventaire" "connect_nbr")) socket)
                    (setf vision nil))
             )
            ((funcall (cdr state) 'joining)
             (progn (set-and-send command (join-for-incantation (car msg) vision team state level) socket)
                    (setf vision nil))
             )
            ((funcall (cdr state) 'wandering)
             (let ((needs (check-inventory inventory level)))
               (if (null needs)
                   (progn (set-and-send command (cons (format nil "broadcast ~a, ~a" team level) nil) socket)
                          (funcall (third counter) 0))
                   (progn (set-and-send command (append (make-path (car (search-in-vision needs vision))
                                                                   count-step)
                                                        '("inventaire")) socket)
                          (setf vision nil))))
             )
            (t nil)
            )
          )
      )
    )
  )

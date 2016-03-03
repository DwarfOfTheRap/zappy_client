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
(defun force-socket-output (str socket)
  (format (usocket:socket-stream socket) "~a~%" str)
  (force-output (usocket:socket-stream socket))
  )

(load "src/broadcast.lisp")

(defun make-path-2 (tile element) ;TODO: find a good way ot implement this inside make-path
  "recursive function. Advance to the element then take it"
  (if (= 0 tile)
      (return-from make-path-2 (list (concatenate 'string "prend " (symbol-name element))))
      (append '("avance") (make-path-2 (- tile 2) element))))

(defun make-path (element)
  "create a list of command: take @pair and return @string list"
  (if (null element)
      (return-from make-path '("gauche" "avance")) )
  (loop for i from 1 to 7
        for j = 0 then (+ 1 j)
        if (<= (* i i) (cdr element))
          append '("avance") into ret
        else
          do (let ((tile (- (cdr element) (* j j))))
               (if (= 0 tile)
                   (return-from make-path (append ret (list (concatenate 'string "prend " (symbol-name (car element)))))))
               (if (oddp tile)
                   (return-from make-path (append ret '("gauche") (make-path-2 (+ 1 tile) (car element))))
                   (return-from make-path (append ret '("droite") (make-path-2 tile (car element))))))))

(defun search-in-vision (list vision)
  "for each item in list, search in vision the corresponding key and return a list of pair (item . tile) or nil"
  (loop for item in list
        for x = (loop for sub in vision
                      when (member item sub)
                        return (car sub))
        if x
          collect (cons item x) into ret
        finally (return (sort ret #'< :key #'cdr))))

(defun seek-stone (inventory level)
  "function that check wich object the droid will be looking for"
  (loop for i from 1 to 6
        when (< (cdr (nth i inventory)) (nth (- i 1) (nth (- level 1) *stone-per-level*)))
          collect (nth i *symbol-list*)))

(defun check-inventory (inventory level)
  "look if food is needed and seek stones otherwise"
  (if (< (cdar inventory) 4) (return-from check-inventory '(|nourriture|)))
  (if (< (cdar inventory) 9) (return-from check-inventory (cons '|nourriture| (seek-stone inventory level))))
  (seek-stone inventory level)
  )

(defun get-inventory (str)
  "Take the inventory string response and convert it into a list of list"
  (let ((case-list (cl-ppcre:split ", " (subseq str 1 (- (length str) 1)))))
    (loop for x in case-list
          for y = (cl-ppcre:split "\\s+" x)
          collect (cons (intern (first y)) (parse-integer (second y))))))

(defun get-broadcast (str)
  "Read the broadcast response and return a tuple (direction . message): (int . str)"
  (cons (parse-integer (subseq str 8 9)) (subseq str 11)))

(defun organize-line (vision half)
  "organize vision lines putting the closest tiles first"
  (loop for i from 0 below half
        nconc (list (nth i vision) (nth (- (* half 2) i) vision)) into lst
        finally (return (cons (nth half vision) (nreverse lst)))))

(defun organize-vision (vision)
  "collect vision lines"
  (let ((sav 0) (half 0)) ;maybe a better way t do this
    (loop for item in vision
          for i from 1
          collect item into lst
          when (member i '(1 4 9 16 25 36 49 64))
            append (organize-line (subseq lst sav) half) into ret
            and do (progn (incf half) (setf sav i))
          finally (return ret))))

(defun get-vision (str)
  "Take the vision string response and convert it into a list o strings"
  (let ((tiles-list (cl-ppcre:split ", " (subseq str 1 (- (length str) 1)))))
    (loop for tiles in (organize-vision tiles-list)
          for tile-num from 0
          for object-list = (cl-ppcre:split "\\s+" tiles)
          collect (cons tile-num (loop for object in object-list
                                       collect (intern object))))))

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
                 (if (and (eq state 'wandering )(string= (car command) (format nil "broadcast ~a, ~a" team level)))
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
                                        ;   ((eq state 'broadcasting)
                                        ;    (do stuff)
                                        ;    )
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

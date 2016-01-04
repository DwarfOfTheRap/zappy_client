                                        ; regex variables
(defvar *vision-regex* "^\{(|(nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame)( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))*| )(,(( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))+| ))+\}$")
(defvar *inventory-regex*  "^\{nourriture \\d+, linemate \\d+, deraumere \\d+, sibur \\d+, mendiane \\d+, phiras \\d+, thystame \\d+\}$")
(defvar *broadcast-regex* "^message [1-9], .*$")
(defvar *push-regex* "^deplacement \\d$")
; Level up needs
(defvar *stone-per-level* '((1 0 0 0 0 0) (1 1 1 0 0 0) (2 0 1 0 2 0) (1 1 2 0 1 0) (1 2 1 3 0 0) (1 2 3 0 1 0) (2 2 2 2 2 1)))


(defun replace-list (olist nlist)
  "function that update an old list with a new list"
  (setf (first olist) (first nlist))
  (setf (cdr olist) (cdr nlist))
  )

;will be revamped in experimental
(defun check-inventory (inventory level)
  "function that check wich object the droid will be looking for"
  (cond
   ((< (second (car inventory)) 4) '|nourriture|)
   ((< (second (nth 1 inventory)) (car (nth (- level 1) *stone-per-level*))) '|linemate|)
   ((< (second (nth 2 inventory)) (nth 1 (nth (- level 1) *stone-per-level*))) '|deraumere|)
   ((< (second (nth 3 inventory)) (nth 2 (nth (- level 1) *stone-per-level*))) '|sibur|)
   ((< (second (nth 4 inventory)) (nth 3 (nth (- level 1) *stone-per-level*))) '|mendiane|)
   ((< (second (nth 5 inventory)) (nth 4 (nth (- level 1) *stone-per-level*))) '|phiras|)
   ((< (second (nth 6 inventory)) (nth 5 (nth (- level 1) *stone-per-level*))) '|thystame|)
   (t nil)
   )
  )

(defun get-inventory (str)
  "Take the inventory string response and convert it into a list of list"
  (let ((case-list (cl-ppcre:split ", " (subseq str 1 (- (length str) 1)))))
    (loop for x in case-list
          for y = (cl-ppcre:split "\\s+" x)
          collect (cons (intern (first y)) (parse-integer (second y))) )))

(defun get-broadcast (str)
  (list (parse-integer (subseq str 8 9)) (subseq str 11)))

(defun get-vision (str)
  "Take the vision string response and convert it into a list o strings"
  (let ((case-list (cl-ppcre:split ", " (subseq str 1 (- (length str) 1)))))
    (loop for x in case-list collect x)))

(defun get-response (str vision inventory resp msg)
  (cond
   ((cl-ppcre:scan "^ok$" str)
    (setf (first resp) 0))
   ((cl-ppcre:scan "^ko$" str)
    (setf (first resp) 1))
   ((cl-ppcre:scan *inventory-regex* str)
    (replace-list inventory (get-inventory str)))
   ((cl-ppcre:scan *vision-regex* str)
    (replace-list vision (get-vision str)))
   ((cl-ppcre:scan *broadcast-regex* str)
    (replace-list msg (get-broadcast str)))
   (t (progn(format t "Unexpected message: ~a~%" str) (return-from get-response nil))))
  t)

(defun base-inv ()
  '(("nourriture" 10)("linemate" 0)("deraumere" 0)("sibur" 0)("mendiane" 0)("phiras" 0)("thystame" 0)))



                                        ;(defun game-loop (newcli socket coord)
                                        ;  "loop with a throttle until it catch a response from server"
                                        ;  (let ((vision '(0)) (inventory base-inv) (command '(0)) (objective '(0))) ;should set inventory with 10f
                                        ;    (loop
                                        ;      (if (listen (usocket:socket-stream socket))
                                        ;        ;(progn
                                        ;        (get-response (read-line (usocket:socket-stream socket)) vision inventory resp msg)
                                        ;        ; )
                                        ;        )
                                        ;      (sleep 0.001)
                                        ;      )
                                        ;    )
                                        ;  )

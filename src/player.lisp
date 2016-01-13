                                        ; regex variables
(defvar *vision-regex* "^\{(|(nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame)( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))*| )(,(( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))+| ))+\}$")
(defvar *inventory-regex*  "^\{nourriture \\d+, linemate \\d+, deraumere \\d+, sibur \\d+, mendiane \\d+, phiras \\d+, thystame \\d+\}$")
(defvar *broadcast-regex* "^message [1-9], .*$")
(defvar *push-regex* "^deplacement \\d$")
; Level up needs
(defvar *stone-per-level* '((1 0 0 0 0 0) (1 1 1 0 0 0) (2 0 1 0 2 0) (1 1 2 0 1 0) (1 2 1 3 0 0) (1 2 3 0 1 0) (2 2 2 2 2 1)))
(defvar *symbol-list* '(|nourriture| |linemate| |deraumere| |sibur| |mendiane| |phiras| |thystame|))

(defun replace-list (olist nlist)
  "function that update an old list with a new list"
  (setf (first olist) (first nlist))
  (setf (cdr olist) (cdr nlist))
  )

(defun make-path (search)
  t
  )

(defun search-in-vision (list vision)
  "for each item in list, search in vision the corresponding key and return the pair (tile . item) "
  (loop for item in list
        collect (cons item (loop for sub in vision
              if (member item sub)
              minimize (car sub)))))

(defun seek-stone (inventory level)
  "function that check wich object the droid will be looking for"
  (loop for i from 1 to 6
        when (< (second (nth i inventory)) (nth (- i 1) (nth (- level 1) *stone-per-level*)))
        collect (nth i *symbol-list*)))

(defun check-inventory (inventory level)
  "look if food is needed and seek stones otherwise"
  (if (< (second (car inventory)) 4) (return-from check-inventory '(|nourriture|)))
  (if (< (second (car inventory)) 10) (return-from check-inventory (cons '|nourriture| (seek-stone inventory level))))
  (seek-stone inventory level)
  )

(defun get-inventory (str)
  "Take the inventory string response and convert it into a list of list"
  (let ((case-list (cl-ppcre:split ", " (subseq str 1 (- (length str) 1)))))
    (loop for x in case-list
          for y = (cl-ppcre:split "\\s+" x)
          collect (cons (intern (first y)) (parse-integer (second y))) )))

(defun get-broadcast (str)
  (list (parse-integer (subseq str 8 9)) (subseq str 11)))


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
  '((|nourriture| . 10)(|linemate| . 0)(|deraumere| . 0)(|sibur| . 0)(|mendiane| . 0)(|phiras| . 0)(|thystame| . 0)))



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

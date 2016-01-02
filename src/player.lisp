
; regex variables
(defvar *vision-regex* "^\{(|(nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame)( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))*| )(,(( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))+| ))+\}$")
(defvar *inventory-regex*  "^\{nourriture \\d+, linemate \\d+, deraumere \\d+, sibur \\d+, mendiane \\d+, phiras \\d+, thystame \\d+\}$")
(defvar *broadcast-regex* "^message [1-9], .*$")
(defvar *push-regex* "^deplacement \\d$") ; may need further tsting for \n message

; May be avoided with better conception or unknown function: need further research
(defun replace-list (olist nlist)
  "function that update an old list with a new list"
  (setf (first olist) (first nlist))
  (setf (cdr olist) (cdr nlist))
  )

(defun get-inventory (str)
  "Take the inventory string response and convert it into a list of list"
  (let ((case-list (cl-ppcre:split ", " (subseq str 1 (- (length str) 1)))))
    (loop for x in case-list
          for y = (cl-ppcre:split "\\s+" x )
          collect y)))

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
     (replace-list msg (list (parse-integer (subseq str 8 9)) (subseq str 11))
                   ))
    (t (progn(format t "Unexpected message: ~a~%" str) (return-from get-response nil))))
  t)
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

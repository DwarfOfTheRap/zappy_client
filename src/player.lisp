;Variable object: contain the game object list
;(defvar *object-regex* "^(((nourriture|linemate|deraumere|sibur|mendiane|phiras|thystame)[ ]?)+|^$)$")
(defvar *vision-regex* "^\{(|(nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame)( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))*| )(,(( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))+| ))+\}$")
(defvar *inventory-regex*  "^\{nourriture \\d+, linemate \\d+, deraumere \\d+, sibur \\d+, mendiane \\d+, phiras \\d+, thystame \\d+\}$")
(defvar *broadcast-regex* "^message \\d, .*$")
(defvar *push-regex* "^deplacement \\d$") ; may need further tsting for \n message
(defvar *ok-regex* "^ok$")
(defvar *ko-regex* "^ko$")


(defun get-inventory (str)
  (let ((case-list (cl-ppcre:split ", " (subseq str 1 (- (length str) 1)))))
    (loop for x in case-list
          for y = (cl-ppcre:split "\\s+" x )
          collect y)))

(defun get-vision (str)
  (let ((case-list (cl-ppcre:split ", " (subseq str 1 (- (length str) 1)))))
    (loop for x in case-list collect x)))

(defun get-broadcast (str)
  (if (cl-ppcre:scan *broadcast-regex* str)
    (let
    )))


(defun get-response (str vision inventory cmd)
  (cond
    ((cl-ppcre:scan *ok-regex* str)
     (setf cmd t))
    ((cl-ppcre:scan *ko-regex* str)
     (setf cmd nil))
    ((cl-ppcre:scan *inventory-regex* str)
     (setf inventory (get-inventory str)))
    ((cl-ppcre:scan *vision-regex* str)
     (setf vision (get-vision str)))
    (t (progn
         (format t "Unexpected message: ~a~%" str) (return-from get-response nil)))
    ) t
  )
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

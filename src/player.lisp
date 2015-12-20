;Variable object: contain the game object list
;(defvar *object-regex* "^(((nourriture|linemate|deraumere|sibur|mendiane|phiras|thystame)[ ]?)+|^$)$")
(defvar *object-regex* "^\{(|(nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame)( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))*| )(,(( (nourriture|joueur|linemate|deraumere|sibur|mendiane|phiras|thystame))+| ))+\}$")


(defun get-inventory (str)
  (let ((case-list (cl-ppcre:split ", " (car (cl-ppcre:all-matches-as-strings "[^}{]+" str)))))
    (loop for x in case-list
          for y = (cl-ppcre:split "\\s+" x )
          collect y)))

(defun get-vision (str)
  (if (cl-ppcre:scan *object-regex* str)
  (let ((case-list (cl-ppcre:split ", " (car (cl-ppcre:all-matches-as-strings "[^}{]+" str)))))
    (loop for x in case-list collect x))))


;(defun get-response (str vision inventory help)
;  (cond
;    ((string= "{{" (char str 0))
;     (setf vision (parse-vision str)))
;    (t (progn
;         (format t "Unexpected message: ~a~%" str) (sb-thread:terminate-thread sb-thread:*current-thread*)))
;    )
;  )
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

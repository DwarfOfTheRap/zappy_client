;Variable object: contain the game object list
;(defvar *object* '("food" "linemate" "deraumere" "sibur" "mendiane" "phiras" "thystame"))
;(print *object*)

;(defun get-inventory (str)
;  )

(defun get-response (str newcli coord)
  (cond
    ((string= "{{" (char str 0))
     )
    )
  )

(defun game-loop (newcli socket coord)
  "loop with a throttle until it catch a response from server"
  (loop
    (if (listen (usocket:socket-stream socket))
      ;(progn
        (get-response (read-line (usocket:socket-stream socket)) newcli coord)
       ; )
      (sleep 0.001)
      )
    )
  )

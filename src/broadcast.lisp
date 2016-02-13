(defun elevation-broadcast (team level socket)
  (format (usocket:socket-stream socket) "broadcast ~a, ~a" team level))

(defun analyze-broadcast (str team level)
  "Compare team and level with the broadcast. Return T if it match, nil if it doesn't."
  (and (cl-ppcre:scan (format nil "^~a, ~a$" team level) str) t))

(defun move-toward (point)
  ()
  )

(defun elevation-broadcast (team level socket)
  (format (usocket:socket-stream socket) "~a, ~a" team level))

(defun)

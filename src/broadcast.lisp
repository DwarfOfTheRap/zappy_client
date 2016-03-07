(defun presence-counter ()
  "Closure that count the number of ready robots
   @args: nil
   @return: (function -> nil function -> nil function -> int)"
    (let ((count 0))
      (list
       (lambda () (incf count))
       (lambda () (decf count))
       (lambda () count))))

(defun get-broadcast (str team level counter state)
  "Read the broadcast response, update an elevation closure if needed
and return a tuple (direction . message): (int . symbol) or nil"
  (let ((dir (parse-integer (subseq str 8 9))) (msg (subseq str 11)))
    (cond
      ((string= (format nil "~a, ~a" team level) msg)
       (and (or (funcall (cdr state) 'wandering) (funcall (cdr state) 'wandering)) (funcall (car state) 'joining))
         (cons dir 'elevation))
      ((and (= dir 0) (funcall (cdr state) 'broadcasting) (string= (format nil "ready: ~a" team) msg))
       (funcall (first counter)))
      (t nil))))

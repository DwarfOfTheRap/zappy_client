(defun presence-counter ()
  "Closure that count the number of ready robots
   @args: nil
   @return: (function -> nil function -> nil function -> int)"
  (let ((count 0))
    (list
     (lambda () (incf count))
     (lambda () (decf count))
     (lambda () count)
     (lambda (x) (setf count x)))))

(defun get-broadcast (str team level counter state present)
  "Read the broadcast response, update an elevation closure if needed
and return a tuple (direction . message): (int . symbol) or nil"
  (let ((dir (parse-integer (subseq str 8 9))) (msg (subseq str 11)))
    (cond
      ((string= (format nil "~a, ~a" team level) msg)
       (case (funcall (cdr state))
         ('wandering (progn
                       (funcall (car state) 'respond)
                       (cons dir 'elevation)))
         (('joining 'respond) (cons dir 'elevation))
           )
       )
      ((and (funcall (cdr state) 'joining) (cl-ppcre:scan (format nil "egg: \\d, ~a" team) msg))
       (let ((egg (parse-integer (subseq msg 5 6))))
         (funcall (fourth present) (- 5 egg))
         (if (> egg 0)
             (funcall (car state) 'laying))
        )
       )
      ((and (funcall (cdr state) 'broadcasting) (string= (format nil "present: ~a, ~a" team level) msg))
       (funcall (first present))
       )
      ((string= msg (format nil "lay: ~a" team))
       (progn (funcall (first present))
              (cons dir 'laying))
       )
      ((and (= dir 0) (funcall (cdr state) 'broadcasting) (string= (format nil "ready: ~a" team) msg))
       (funcall (first counter)))
      (t nil))))


(defun get-broadcast (str team level counter state present)
  "Read the broadcast response, update an elevation closure if needed
and return a tuple (direction . message): (int . symbol) or nil"
  (let ((dir (parse-integer (subseq str 8 9))) (msg (subseq str 10)))
    (con
     ((string= (format nil "~a, ~a" team level) msg)
      (cond
        ((or (funcall (cdr state) 'wandering) (funcall (cdr state) 'hatching))
         (progn
           (funcall (car state) 'respond)
           (cons dir 'elevation)))
        ((funcall (cdr state) 'joining) (cons dir 'elevation))
        )
      )
     ((and (funcall (cdr state) 'joining) (cl-ppcre:scan (format nil "egg: \\d, ~a" team) msg))
      (let ((egg (parse-integer (subseq msg 5 6))))
        (funcall (third present) (- 5 egg))
        (if (> egg 0)
            (funcall (car state) 'laying))
        )
      )
     ((string= (format nil "stop ~a, ~a" team level))
      (progn
        (funcall (third counter) 0)
        (funcall (car state) 'wandering)
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

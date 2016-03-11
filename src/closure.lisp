(defun set-counter ()
  "Closure that count the number of ready robots
   @args: nil
   @return: (function -> nil function -> nil function -> int)"
  (let ((count 0))
    (list
     (lambda () (incf count))
     (lambda () (decf count))
     (lambda (x) (setf count x))
     (lambda () count))))

(defun set-state ()
  "Closure saveing the state and comparing it
   @args: nil
   @return: (func ('sym) -> nil . func ('sym) -> bool)"
  (let ((state 'wandering))
    (cons
     (lambda (x) (setf state x))
     (lambda (x) (if (eq x state) t nil)))))

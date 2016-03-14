(defun make-path-2 (tile element) ;TODO: find a good way ot implement this inside make-path
  "recursive function. Advance to the element then take it"
  (if (= 0 tile)
      (return-from make-path-2 (list (concatenate 'string "prend " (symbol-name element))))
      (append '("avance") (make-path-2 (- tile 2) element))))

(defun make-path (element count-step)
  "create a list of command: take @pair and return @string list"
  (if (null element)
      (progn (funcall (first count-step))
       (return-from make-path (cons "gauche" (loop repeat (funcall (fourth count-step)) collect "avance"))))
      )
  (funcall (third count-step) 0)
  (loop for i from 1 to 7
        for j = 0 then (+ 1 j)
        if (<= (* i i) (cdr element))
          append '("avance") into ret
        else
          do (let ((tile (- (cdr element) (* j j))))
               (if (= 0 tile)
                   (return-from make-path (append ret (list (concatenate 'string "prend " (symbol-name (car element)))))))
               (if (oddp tile)
                   (return-from make-path (append ret '("gauche") (make-path-2 (+ 1 tile) (car element))))
                   (return-from make-path (append ret '("droite") (make-path-2 tile (car element))))))))

(defun search-in-vision (list vision)
  "for each item in list, search in vision the corresponding key and return a list of pair (item . tile) or nil"
  (loop for item in list
        for x = (loop for sub in vision
                      when (member item sub)
                        return (car sub))
        if x
          collect (cons item x) into ret
        finally (return (sort ret #'< :key #'cdr))))

(defun find-player (vision level dir turn)
  (loop for i from 2 to (+ level 2)
        for j = (- (* i i) dir)
        collect "avance" into ret
        until (member '|joueur| (nth j vision))
        finally (return (append ret (append turn ret)))))

(defun join-for-incantation (dir vision team state level)
  "Function that set path to the broadcasting droid and tell him when he is ready
   @args: int, nil, string, (function ('symbol) -> nil . function ('sym) -> bol)
   @return (list string string ...)"
  (case dir
    (1 '("avance" "inventaire"))
    (2 (append (find-player vision level 1 '("gauche")) '("inventaire")))
    (8 (append (find-player vision level 2 '("droite")) '("inventaire")))
    ((3 4) '("gauche" "inventaire"))
    ((6 7) '("droite" "inventaire"))
    (5 '("gauche" "gauche" "avance" "inventaire"))
    (0 (progn (funcall (car state) 'waiting)
         (cons (format nil "broadcast ready: ~a" team) nil)))))

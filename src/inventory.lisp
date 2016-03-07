(defun put-down-incantation-stones (level)
  (let ((stone (nth (- level 1) *stone-per-level*)))
    (loop for i upto 5
          append (loop for j from (nth i stone) downto 1
                        collect (format nil "pose ~a" (nth (+ 1 i) *symbol-list*))
                        ) into ret
          finally (return (append ret '("incantation")))
          )
      )
  )

(defun seek-stone (inventory level)
  "function that check wich object the droid will be looking for"
  (loop for i from 1 to 6
        when (< (cdr (nth i inventory)) (nth (- i 1) (nth (- level 1) *stone-per-level*)))
          collect (nth i *symbol-list*)))

(defun check-inventory (inventory level)
  "look if food is needed and seek stones otherwise"
  (if (< (cdar inventory) 4) (return-from check-inventory '(|nourriture|)))
  (if (< (cdar inventory) 9) (return-from check-inventory (cons '|nourriture| (seek-stone inventory level))))
  (seek-stone inventory level)
  )

(defun get-inventory (str)
  "Take the inventory string response and convert it into a list of list"
  (let ((case-list (cl-ppcre:split ", " (subseq str 1 (- (length str) 1)))))
    (loop for x in case-list
          for y = (cl-ppcre:split "\\s+" x)
          collect (cons (intern (first y)) (parse-integer (second y))))))
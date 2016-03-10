(defun organize-line (vision half)
  "organize vision lines putting the closest tiles first"
  (loop for i from 0 below half
        nconc (list (nth i vision) (nth (- (* half 2) i) vision)) into lst
        finally (return (cons (nth half vision) (nreverse lst)))))

(defun organize-vision (vision)
  "collect vision lines"
  (let ((sav 0) (half 0)) ;maybe a better way t do this
    (loop for item in vision
          for i from 1
          collect item into lst
          when (member i '(1 4 9 16 25 36 49 64))
            append (organize-line (subseq lst sav) half) into ret
            and do (progn (incf half) (setf sav i))
          finally (return ret))))


(defun get-vision (str)
  "Take the vision string response and convert it into a list o strings"
  (let ((tiles-list (cl-ppcre:split ", " (subseq str 1 (- (length str) 1)))))
    (loop for tiles in (organize-vision tiles-list)
          for tile-num from 0
          for object-list = (cl-ppcre:split "\\s+" tiles)
          collect (cons tile-num (loop for object in object-list
                                       collect (intern object))))))

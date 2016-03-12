;Entry point in another file for testing purpose

(load "src/client.lisp")
(declaim (optimize (speed 3) (safety 0) (space 0)))
(sb-ext:save-lisp-and-die "client" :toplevel #'main :executable t)

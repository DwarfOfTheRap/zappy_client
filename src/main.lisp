;Entry point in another file for testing purpose

(load "src/client.lisp")
(sb-ext:save-lisp-and-die "hello.exe" :toplevel #'main :executable t)

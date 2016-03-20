NAME := client
CL := sbcl
SRC := src/main.lisp

DEP := \
	src/broadcast.lisp \
	src/client.lisp \
	src/closure.lisp \
	src/inventory.lisp \
	src/main.lisp \
	src/path.lisp \
	src/player.lisp \
	src/vision.lisp

FLAGS := --script

all: $(NAME)

$(NAME): $(DEP)
	@echo [build]: creating $@
	$(CL) $(FLAGS) $(SRC)
	@echo [build]: created $@

clean:

fclean:
	rm -f $(NAME)

re: fclean all

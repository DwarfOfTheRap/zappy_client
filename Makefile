NAME := client
CL := sbcl
SRC := src/main.lisp
FLAGS := --script

all: $(NAME)

$(NAME):
	@echo [build]: creating $@
	$(CL) $(FLAGS) $(SRC)
	@echo [build]: created $@

fclean:
	rm -f $(NAME)

re: fclean all

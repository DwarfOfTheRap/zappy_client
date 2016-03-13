NAME := client
CL := sbcl
SRC := src/main.lisp
FLAGS := --script

all: $(NAME)

$(NAME):
	$(CL) $(FLAGS) $(SRC)

fclean:
	rm $(NAME)

re: fclean all

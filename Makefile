##
# BEMAne
#
# @file
# @version 0.1

LISP ?= sbcl

build:
	$(LISP) --eval '(ql:quickload :bemane)' \
		--eval '(asdf:make :bemane)' \
		--eval '(quit)'

# end

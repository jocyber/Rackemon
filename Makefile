SRC_PATH:=./rackemon
MAIN:=${SRC_PATH}/main.rkt
OS_TYPE:=$(shell uname)

.PHONY: test 
test:
	raco test -t ./rackemon

.PHONY: setup
setup: 
ifeq ($(OS_TYPE),Darwin)
	brew install raylib
endif
	raco pkg install --auto -t dir ${SRC_PATH}

.PHONY: build
build:
	raco make ${MAIN}

.PHONY: run
run: 
	racket ${MAIN}

.PHONY: battle
battle: 
	racket ${SRC_PATH}/battle/display.rkt

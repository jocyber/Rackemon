SRC_PATH:=./rackemon

.PHONY: test 
test:
	raco test -t ./rackemon

.PHONY: setup
setup: 
	raco pkg install --auto -t dir ${SRC_PATH}

.PHONY: build
build:
	raco make ${SRC_PATH}/main.rkt

.PHONY: run
run: 
	racket rackemon/main.rkt

.PHONY: battle
battle: 
	racket rackemon/battle/display.rkt

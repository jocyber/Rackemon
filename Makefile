.PHONY: test 
test:
	raco test -t ./rackemon

.PHONY: run
run: 
	racket rackemon/main.rkt

.PHONY: battle
battle: 
	racket rackemon/battle/display.rkt

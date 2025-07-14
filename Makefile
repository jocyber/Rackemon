.PHONY: test 
test:
	raco test -t ./rackemon

run: 
	racket rackemon/main.rkt

battle: 
	racket rackemon/battle/display.rkt

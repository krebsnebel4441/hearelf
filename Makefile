all: hearelf

HAREFLAGS=

.PHONY: all clean hearelf

hearelf:
	hare build $(HAREFLAGS) cmd/hearelf/

clean:
	rm -rf hearelf

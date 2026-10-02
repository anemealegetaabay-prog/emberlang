CC      ?= cc
CFLAGS  ?= -std=c11 -O2 -g -Wall -Wextra -Iinclude -Isrc
BUILD   := build

# CLI build: every src/*.c (main.c provides the entry point).
SRCS    := $(wildcard src/*.c)
OBJS    := $(patsubst src/%.c,$(BUILD)/%.o,$(SRCS))

emberlang: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)

$(BUILD)/%.o: src/%.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD):
	mkdir -p $(BUILD)

.PHONY: test clean
test: emberlang
	@tests/run_tests.sh

clean:
	rm -rf $(BUILD) emberlang

SHELL = /bin/bash

.DEFAULT_GOAL := help

.PHONY: cppcheck elixir erlang help
cppcheck:
	src/deploy-cppcheck.sh

cppcheck:
	src/deploy-elixir.sh

cppcheck:
	src/deploy-erlang.sh

help:
	@echo make cppcheck elixir erlang help

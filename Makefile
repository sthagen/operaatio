SHELL = /bin/bash

.DEFAULT_GOAL := help

.PHONY: cmake cppcheck elixir erlang gcc help

cmake:
	src/deploy-cmake.sh 3.23.2

cppcheck:
	src/deploy-cppcheck.sh

elixir:
	src/deploy-elixir.sh

erlang:
	src/deploy-erlang.sh

gcc:
	src/deploy-gcc.sh 12.1.0

help:
	@echo make cmake cppcheck elixir erlang gcc help

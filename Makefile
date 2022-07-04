SHELL = /bin/bash

.DEFAULT_GOAL := help

.PHONY: cmake cppcheck elixir emacs erlang gcc help v

cmake:
	src/deploy-cmake.sh 3.23.2

cppcheck:
	src/deploy-cppcheck.sh

elixir:
	src/deploy-elixir.sh

emacs:
	src/deploy-emacs.sh 28.1

erlang:
	src/deploy-erlang.sh

gcc:
	src/deploy-gcc.sh 12.1.0

help:
	@echo make cmake cppcheck elixir emacs erlang gcc help v

v:
	src/deploy-v.sh

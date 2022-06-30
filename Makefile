SHELL = /bin/bash

.DEFAULT_GOAL := cppcheck

.PHONY: cppcheck
cppcheck:
	src/deploy-cppcheck.sh

.PHONY: help
help:
	@echo make cppcheck help

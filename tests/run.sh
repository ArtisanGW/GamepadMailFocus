#!/bin/sh
# Runs every test outside the game. From anywhere: tests/run.sh
cd "$(dirname "$0")/.." || exit 1
luajit tests/run.lua

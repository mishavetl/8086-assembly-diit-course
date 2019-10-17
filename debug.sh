#!/usr/bin/env bash

./compile.sh $1

dosemu TD.EXE $1.exe
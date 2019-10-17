#!/usr/bin/env bash

./compile.sh $1

dosemu -dumb $1.exe
#!/usr/bin/env bash

dosemu -dumb TASM.EXE /l $1
dosemu -dumb TASM.EXE /zi $1
dosemu -dumb TLINK.EXE /v /d $1
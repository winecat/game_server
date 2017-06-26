#!/usr/env bash
cd /config/
ulimit -s 262140
LC_CTYPE=en_US.UTF-8
  \
    -name game_test_{1}@ \
        -setcookie alsdewio23s  \
        -config elog -pa ../ebin -pa ../cbin \
        -s game start \
        -extra 127.0.0.1 7001

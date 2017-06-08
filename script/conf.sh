#!/usr/env sh
# author x-mars

PROJECT_DIR=/data/workspace
GAME_DIR=${PROJECT_DIR}/server
GAME_VAR_DIR=${GAME_DIR}/var
HOST_PUBLISH_IP=127.0.0.1       # 游戏公网IP
HOST_INTERNAL_IP=127.0.0.1  # 游戏内网IP
GAME_PORT=7001  # 游戏网关端口
APP_NAME=game   # 游戏应用名字(跟程序代码挂钩，不能随意变动)
GAME_NAME=game    # 游戏名
PLATFORM=test   # 游戏平台
SERVER_ID=1     # 游戏当前区服号
ERL_PORT_MIN=40001  #erl节点间通信端口
ERL_PORT_MAX=42000  #erl节点间通信端口
ERL_OPT="-kernel inet_dist_listen_min ${ERL_PORT_MIN} -kernel inet_dist_listen_max ${ERL_PORT_MAX} +P 1024000 +K true -smp auto -boot start_sasl"
ERL_GAME_COOKIE=alsdewio23s     # 游戏节点启动cookie
ERL_CENTER_COOKIE=3209SDLEI     # 跨服节点启动cookie
IS_CROSS=0              # 是否为跨服服务器




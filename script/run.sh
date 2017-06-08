#!/usr/env sh
# author x-mars


source `pwd`/conf.sh
echo "start game server..."

case ${1} in
    script) fun_script;; # 生成相关脚本
    start) fun_start;; # 启动所有设定的节点
    stop) fun_stop;; # 关闭所有节点
    hot) fun_hot ${2};; # 热更新beam文件
    *)
        use_help;
        exit 1
        ;;
esac


use_help() {
    echo "control switch"
    echo "用法:"
    echo "./`basename $0` [command]"
    echo ""
    echo " command 有效命令："
    echo " script - 生成相关脚本"
    echo " start_all - 启动所有设定的节点"
    echo " stop_all - 关闭所有节点"
    echo ""
}

fun_script(){
    if [ "${IS_IS_CROSS}" == "1" ]; then
        echo "生成跨服启动脚本..."
        fun_center_script
    else
       echo "生成游戏服启动脚本..."
       fun_game_script
    fi
}

fun_game_script(){
    rm -rf game_*.sh
    cat > game_init.sh <<EOF
#!/usr/env bash
cd ${SERVER_PATH}/config/
ulimit -s 262140
LC_CTYPE=en_US.UTF-8
${ERL} ${ERL_OPTION} \\
    -name ${GAME_NAME}_${PLATFORM}_{$SERVER_ID}@${MACHINE_INTRANET} \\
        -setcookie ${ERL_GAME_COOKIE}  \\
        -config elog -pa ../ebin -pa ../cbin \\
        -s game start \\
        -extra ${HOST_PUBLISH_IP} ${GAME_PORT}
EOF

cat > game_start.sh <<EOF
#!/usr/env bash
source `dirname $0`/conf.sh
mkdir -p ${GAME_VAR_DIR}/logs
SCREEN_RC_FILE=\${GAME_VAR_DIR}/logs/screenrc_game
LOG_OPTION="-L -c \${SCREEN_RC_FILE}"
\cp \${SCRIPT_PATH}/screenrc \${SCREEN_RC_FILE}
sed -i -e 's#gameserver#'\${VAR_PATH}'/logs/${start}'`date +".%Y-%m-%d_%H-%M-%S"`'.log#' \${SCREEN_RC_FILE}
echo "游戏启动中..."
${SCREEN} -d -m -S ${start} -s \${SCRIPT_PATH}/game_init.sh \${LOG_OPTION}
sleep 2
EOF
    }
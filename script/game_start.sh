#!/usr/env bash
source ./conf.sh
mkdir -p /data/workspace/server/var/logs
SCREEN_RC_FILE=${GAME_VAR_DIR}/logs/screenrc_game
LOG_OPTION="-L -c ${SCREEN_RC_FILE}"
\cp ${SCRIPT_PATH}/screenrc ${SCREEN_RC_FILE}
sed -i -e 's#gameserver#'${VAR_PATH}'/logs/'.2017-06-14_16-28-32'.log#' ${SCREEN_RC_FILE}
echo " game start ..."
 -d -m -S  -s ${SCRIPT_PATH}/game_init.sh ${LOG_OPTION}
sleep 2

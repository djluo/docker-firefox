#!/bin/bash
# vim:set et ts=2 sw=2:

current_dir=`dirname $0`
current_dir=`readlink -f $current_dir`
cd ${current_dir} && export current_dir

app="firefox"
port=""

is_exists() {
  sudo docker inspect --format='{{ .State.Running }}' $app | egrep "true|false" >/dev/null
  if [ $? -ne 0 ] ;then
    return 1
  fi
  return 0
}
run() {
  local mode="-d"
  local app_name=$app

  if [ "x$1" == "xdebug" ];then
    local mode="-ti --rm"
    local app_name="debug_$app"
    unset port
    shift
  fi

  local cmd="$@"

  sudo docker run $mode $port           \
       --link ssh-proxy:ssh_proxy       \
       -e DISPLAY=$DISPLAY              \
       -e XMODIFIERS=$XMODIFIERS        \
       -e GTK_IM_MODULE=$GTK_IM_MODULE  \
       -e QT_IM_MODULE=$QT_IM_MODULE    \
       -e QT4_IM_MODULE=$QT4_IM_MODULE  \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       -v ${HOME}/.mozilla/:/home/browser/.mozilla/   \
       -v ${HOME}/downloads/:/home/browser/downloads/ \
      -e "TZ=Asia/Shanghai"        \
      --name ${app_name} ${app}         \
      /bin/sh -c "exec /usr/bin/firefox"
}
usage() {
  echo "Usage: $0 [start|stop|debug|rebuild]"
  exit 127
}
_start() {
  if is_exists $app;then
    sudo docker start $app
  else
    run
  fi
}
###############
case "$1" in
  start)
    _start
    ;;
  stop)
    sudo docker stop -t 300 $app
    ;;
  debug)
    run debug /bin/bash -l
    ;;
  rebuild)
    sudo docker stop -t 300 $app
    sudo docker rm $app
    _start
    ;;
  *)
    usage
    ;;
esac

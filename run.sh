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
is_running() {
  sudo docker inspect --format='{{ .State.Running }}' $app | grep "true" >/dev/null
  if [ $? -ne 0 ] ;then
    return 1
  fi
  return 0
}
set_menu() {
  #local icons="/usr/share/icons/hicolor/"
  #local icons="~/.kde/share/icons/"
  #mkdir
  #cp ./icons/16x16.png   $icons/16x16/apps/
  #cp ./icons/32x32.png   $icons/32x32/apps/
  #cp ./icons/48x48.png   $icons/48x48/apps/
  #cp ./icons/128x128.png $icons/128x128/apps/
  local apps=~/.local/share/applications
  [ -d $apps ] || mkdir -p $apps
  sed "s@CURRENT_DIR@${current_dir}@" firefox.desktop >  $apps/firefox.desktop
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
       -e LANG="zh_CN.utf8"             \
       -e LC_ALL="zh_CN.utf8"           \
       -e DISPLAY=$DISPLAY              \
       -e XMODIFIERS=$XMODIFIERS        \
       -e GTK_IM_MODULE=$GTK_IM_MODULE  \
       -e QT_IM_MODULE=$QT_IM_MODULE    \
       -e QT4_IM_MODULE=$QT4_IM_MODULE  \
       -e "TZ=Asia/Shanghai"            \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       -v ${HOME}/.mozilla/:/home/browser/.mozilla/   \
       -v ${HOME}/downloads/:/home/browser/downloads/ \
       --dns="223.5.5.5"     \
       --dns="223.6.6.6"     \
       --name ${app_name} ${app}:1 \
       /bin/sh -c "exec $cmd"
}
usage() {
  echo "Usage: $0 [start|stop|debug|rebuild]"
  exit 127
}
_start() {
  local url="$@"
  if is_exists $app;then
    if ! is_running $app;then
      sudo docker start $app
      sleep 3
    fi
    [ "x$url" == "x" ] || sudo docker exec $app /usr/bin/firefox "$url"
  else
    run /usr/bin/firefox "$url"
  fi
}
###############
case "$1" in
  start)
    shift
    set_menu
    _start "$@"
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

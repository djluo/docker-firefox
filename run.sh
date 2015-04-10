#!/bin/bash
# vim:set et ts=2 sw=2:

# Author : djluo
# version: 4.0(20150107)

# chkconfig: 3 90 19
# description:
# processname: yys-sh global admin container

process_name=$(basename $0)
if [ "x${process_name}" == "xfirefox" ];then
  release_dir=`readlink -f $0`
  release_dir=`dirname $release_dir`
  cd $release_dir
fi

[ -r "/etc/baoyu/functions"  ] && source "/etc/baoyu/functions" && _current_dir
[ -f "${current_dir}/docker" ] && source "${current_dir}/docker"

# ex: ...../dir1/dir2/run.sh
# container_name is "dir1-dir2"
#_container_name ${current_dir}
container_name="desktop-firefox"

images="firefox"
#default_port="172.17.42.1:3306:3306"

action="$1"    # start or stop ...

if [ "x${process_name}" == "xfirefox" ];then
  _check_container
  cstatus=$?
  if [ $cstatus -eq 0 ];then
    action="exec"
  else
    action="start"
  fi
  exec_cmd="/entrypoint.pl /usr/bin/firefox $@"
  unset cstatus
fi

_run() {
  local mode="-d"
  local name="$container_name"
  local cmd="/usr/bin/firefox"

  [ "x$1" == "xdebug" ] && _run_debug

  sudo docker run $mode $port \
    -w "/home/docker"         \
    -e "TZ=Asia/Shanghai"     \
    -e "LANG=zh_CN.utf8"      \
    -e "LC_ALL=zh_CN.utf8"    \
    -e HOME="/home/docker"    \
    -e DISPLAY=unix$DISPLAY   \
    -e XMODIFIERS=$XMODIFIERS \
    -e QT_IM_MODULE=$QT_IM_MODULE    \
    -e QT4_IM_MODULE=$QT4_IM_MODULE  \
    -e GTK_IM_MODULE=$GTK_IM_MODULE  \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev/snd/:/dev/snd/ \
    -v ${HOME}/.mozilla/:/home/docker/.mozilla/   \
    -v ${HOME}/downloads/:/home/docker/downloads/ \
    -h "djluo-hp"     \
    --dns="223.5.5.5" \
    --dns="223.6.6.6" \
    --name ${name} ${images} \
    $cmd
}
###############
_call_action $action

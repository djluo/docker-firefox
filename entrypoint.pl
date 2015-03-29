#!/usr/bin/perl
# vim:set et ts=2 sw=2:

# Author : djluo
# version: 1.0(20141227)
#
# 初衷: 每个容器用不同用户运行程序,已方便在宿主中直观的查看.
# 需求: 1. 动态添加用户,不能将添加用户的动作写死到images中.
#       2. 容器内尽量不留无用进程,保持进程树干净.
# 问题: 如用shell的su命令切换,会遗留一个su本身的进程.
# 最终: 使用perl脚本进行添加和切换操作. 从环境变量User_Id获取用户信息.

use strict;
#use English '-no_match_vars';

my $uid = 1000;
my $gid = 1000;

$uid = $gid = $ENV{'User_Id'} if $ENV{'User_Id'} =~ /\d+/;

unless (getpwuid("$uid")){
  system("/usr/sbin/useradd", "-U", "-u $uid", "-m", "docker");
  system("/bin/chown", "docker.docker", "/home/docker");
  system("/bin/chown", "docker.docker", "-R", "/home/docker/.mozilla");
  system("/usr/sbin/usermod", "-a", "-G", "audio", "docker");
}

# 切换当前运行用户,先切GID.
#$GID = $EGID = $gid;
#$UID = $EUID = $uid;
$( = $) = $gid; die "switch gid error\n" if $!;
$< = $> = $uid; die "switch uid error\n" if $!;

$SIG{CHLD} = 'IGNORE';
exec(@ARGV);

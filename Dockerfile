# run firefox
#
FROM debian:latest
#MAINTAINER djluo <dj.luo@baoyugame.com>

ADD ./sources.list /etc/apt/
# 使用iceweasel来解决依然问题
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3EE67F3D0FF405B2 \
    && apt-get update  \
    && apt-get install -y fonts-wqy-microhei fonts-wqy-zenhei fonts-dejavu locales \
    && apt-get install -y iceweasel \
    && apt-get remove  -y iceweasel \
    && apt-get install -y firefox firefox-l10n-zh \
    && /usr/sbin/useradd -u 1000 -m browser

# 设置中文环境
RUN sed -e '/en_US.UTF-8/s/^# //' -e '/zh_CN.UTF-8/s/^# //' /etc/locale.gen -i \
    && locale-gen && export LANG=zh_CN.utf8 LC_ALL=zh_CN.utf8

# 安装flashplayer
RUN apt-get install -y flashplugin-nonfree
RUN /usr/sbin/update-flashplugin-nonfree --install --quiet

USER browser
ENV  HOME   /home/browser
ENV  LANG   zh_CN.utf8
ENV  LC_ALL zh_CN.utf8
CMD  /usr/bin/firefox

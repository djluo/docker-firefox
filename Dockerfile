# run firefox
#
FROM       docker.xlands-inc.com/baoyu/debian
MAINTAINER djluo <dj.luo@baoyugame.com>

ADD ./sources.list /etc/apt/
# 使用iceweasel来解决dep问题
RUN export http_proxy="http://172.17.42.1:8080/" \
    && export DEBIAN_FRONTEND=noninteractive     \
    && apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3EE67F3D0FF405B2 \
    && apt-get update  \
    && apt-get install -y fonts-wqy-microhei fonts-wqy-zenhei fonts-dejavu libasound2-plugins \
    && apt-get install -y iceweasel \
    && apt-get remove  -y iceweasel \
    && apt-get install -y firefox firefox-l10n-zh \
    && apt-get install -y flashplugin-nonfree \
    && /usr/sbin/update-flashplugin-nonfree --install --quiet \
    && apt-get clean \
    && unset http_proxy DEBIAN_FRONTEND \
    && localedef -c -i zh_CN -f UTF-8 zh_CN.UTF-8 \
    && localedef -c -i en_US -f UTF-8 en_US.UTF-8

ADD        ./asound.conf   /etc/asound.conf
ADD        ./entrypoint.pl /entrypoint.pl
ENTRYPOINT ["/entrypoint.pl"]
CMD        ["/usr/bin/firefox"]

#!/bin/bash
sudo apt update -q
sudo apt-get install subversion build-essential libncurses5-dev \
    zlib1g-dev gawk git ccache gettext libssl-dev xsltproc zip \
    libncursesw5-dev python unzip -q -y

exit 0

#
# Image Ubuntu + Oracle JDK pour l'environnement de développement Vivado de Xilinx.
#
# Version 0.0.1
#

FROM n3ziniuka5/ubuntu-oracle-jdk
MAINTAINER Joachim Schmidt "joachim.schmidt@openmailbox.org"

#
# Ajout de l'architecture i386 utilie pour NavDoc.
#

RUN dpkg --add-architecture i386
RUN apt-get update

#
# Installation des paquets utils pour l'environnement Vivado.
#

RUN apt-get install -y -q libusb-1.0.0 libusb-1.0.0-dev libusb-1.0-doc libxtst6 libxtst-dev libxtst-doc libxrender1 libxrender-dev libxext6 libxext-dev libxext-doc fxload
RUN apt-get install -y -q libstdc++6:i386 libfontconfig1:i386 libxext6:i386 libxrender1:i386 libglib2.0-0:i386 libsm6:i386

#
# Ajout d'un dépôt pour l'installation de GHDL.
#

RUN add-apt-repository ppa:pgavin/ghdl
RUN apt-get update
RUN apt-get install -y -q ghdl vim gtkwave

#
# Mise à jour du système.
#

RUN apt-get dist-upgrade -y -q

#
# Lancement du shell Bash.
#

CMD ["/bin/bash"]
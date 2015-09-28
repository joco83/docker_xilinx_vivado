#!/bin/bash

#
# Auteur : Joachim Schmidt <joachim.schmidt@openmailbox.org>
#
# Date : 27 septembre 2015
#
# Version : 0.1
#

#
# Fonctions à sourcer dans le fichier ~/.bashrc
#

#
# Fonction pour exécuter l'environnement de développement Vivado de Xilinx.
#

function dock_vivado()
{
    run_dockapp -d FT2232C -i joco/xilinx-vivado -f /home/joco/docker_share:/home/joco/Documents/ITI4/VHDL_FPGA -c /opt/Xilinx/Vivado/2015.2/bin/vivado
}

#
# Fonction pour exécuter un shell bash qui se trouve dans l'image Docker destinée à l'environnement
# de développement Vivado de Xilinx.
#

function dock_bash()
{
    run_dockapp -d FT2232C -i joco/xilinx-vivado -f /home/joco/docker_share:/home/joco/Documents/ITI4/VHDL_FPGA -c /bin/bash
}

#
# Fonction pour exécuter l'application GtkWave qui se trouve dans l'image Docker destinée à l'environnement
# de développement Vivado de Xilinx.
#

function dock_gtkwave()
{
    run_dockapp -d FT2232C -i joco/xilinx-vivado -f /home/joco/docker_share:/home/joco/Documents/ITI4/VHDL_FPGA -c /usr/bin/gtkwave
}

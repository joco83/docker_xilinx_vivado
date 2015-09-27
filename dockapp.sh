#!/bin/bash

#
# Auteur : Joachim Schmidt <joachim.schmidt@openmailbox.org>
#
# Date : 27 septembre 2015
#

# Script pour exécuter l'environnement de développement Vivado de la
# société Xilinx dans un conteneur.

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"

function print_help
{
    echo -e "Commande : ${JAUNE}run.sh${NORMAL} ${VERT}<liste des paramètres> <...>${NORMAL}"
    echo -e ""
    echo -e "Liste des paramètres :"
    echo -e ""
    echo -e " ${BLEU}-d${NORMAL} ${VERT}<nom du device>${NORMAL}"
    echo -e "    Voir le résultat de la commande ${ROUGE}lsusb${NORMAL}."
    echo -e " ${BLEU}-p${NORMAL} ${VERT}<périphérique_1>:<périphérique_2>:<...>${NORMAL}"
    echo -e "    Mappage de la liste des périphériques."
    echo -e "    ${ROUGE}Les périphérique de type /dev/ttyUSB*${NORMAL}"
    echo -e "    ${ROUGE}ainsi que le périphérique associé à la${NORMAL}"
    echo -e "    ${ROUGE}carte de développement sont automatiquement${NORMAL}"
    echo -e "    ${ROUGE}mappé.${NORMAL}"
    echo -e " ${BLEU}-i${NORMAL} ${VERT}<nom de l'image Docker>${NORMAL}"
    echo -e " ${BLEU}-c${NORMAL} ${VERT}<nom de la commande à exécuter par Docker>${NORMAL}"
    echo -e " ${BLEU}-f${NORMAL} ${VERT}<Dossier_1>:<Dossier_2>:<...>${NORMAL}"
    echo -e "    Mappage de la liste des dossiers."
    echo -e "    ${ROUGE}Le dossier $X11FOLD est automatiquement${NORMAL}"
    echo -e "    ${ROUGE}mappé.${NORMAL}"
    echo -e " ${BLEU}-h${NORMAL}"
    echo -e "    Affichage de l'aide en ligne."
    echo -e " ${BLEU}-v${NORMAL}"
    echo -e "    Affichage de la version du script."
}

function print_version
{
    echo -e "Version :"
    echo -e "(run.sh 0.1)"
}

function run_dockapp
{
    local USB_BOARD="" # Variable désignant la carte de développement.
    local BUS=""
    local DEV=""
    local DEVLST=""
    local FOLDLST=""
    local DOCKIMG=""
    local CMD="/bin/bash"
    local X11FOLD="/tmp/.X11-unix"

    #
    # Liste des arguments du script
    #
    # -p <nom du périphérique>
    # -i <nom de l'image Docker>
    # -c <commande à exécuter par Docker>
    # -f <dossier à monter dans Docker>
    # -h <Aide>
    #

    local OPTLST=":d:p:i:c:f:hv:"
    
    local opt_dev=0
    local opt_periph=0
    local opt_img=0
    local opt_cmd=0
    local opt_fold=0
    local opt
    
    OPTERR=0
    
    #
    # On afficher l'aide si il n'y a aucun argument.
    #
    
    if [[ $# -eq 0 ]] ; then
        print_help
        return 1
    fi

    #
    # Bouche pour analyser les options reçus en paramètre.
    #
    
    while getopts $OPTLST opt ; do
        case $opt in
            d ) opt_dev=1
                USB_BOARD=$OPTARG ;;
            p ) opt_perif=1
                DEVLST=$OPTARG ;;
            i ) opt_img=1
                DOCKIMG=$OPTARG ;;
            c ) opt_cmd=1
                CMD=$OPTARG ;;
            f ) opt_fold=1
                FOLDLST=$OPTARG ;;
            h ) print_help
                return 0 ;;
            v ) print_version
                return 0 ;;
            ? ) echo -e "${ROUGE}*${NORMAL} option illégale -$OPTARG" >&2
                return 1 ;;
        esac
    done

    shift $(($OPTIND - 1))
    unset opt

    #
    # On vérifie qu'un périphérique a été mentionné en arguement et
    # on récupère les numéros de bus et du périphérique USB.
    #
    local res=0
    
    if [[ $opt_dev -ne 0 ]] ; then
        BUS_DEV=$(lsusb | grep $USB_BOARD)
        res=$?
        unset opt_dev
    else
        echo -e "${ROUGE}*${NORMAL} Aucune carte de développement n'a été spécifiée." >&2
        echo -e ""
        print_help
        unset OPTIND
        unset OPTARG
        unset OPTERR
        return 1
    fi

    #
    # On vérifie le bon déroulement de la commande lsusb.
    #
    
    if [[ $res -ne 0 ]] ; then
        echo -e "${ROUGE}*${NORMAL} Aucune carte de développement correspondante à ${ROUGE}${USB_BOARD}${NORMAL} n'est connectée." >&2
        echo -e ""
        print_help
        unset OPTIND
        unset OPTARG
        unset OPTERR
        return 1
    fi

    unset res

    #
    # On vérifie qu'un image Docker a été mentionnée en argument.
    #

    if [[ $opt_img -ne 0 ]] ; then
        echo -e "${VERT}*${NORMAL} Image Docker ${VERT}${DOCKIMG}${NORMAL}"
        unset opt_img
    else
        echo -e "${ROUGE}*${NORMAL} Aucune image Docker n'a été spécifiée." >&2
        echo -e ""
        print_help
        unset OPTIND
        unset OPTARG
        unset OPTERR
        return 1
    fi

    #
    # On vérifie qu'une commande Docker a été mentionnée en argument.
    #

    if [[ $opt_cmd -ne 0 ]] ; then
        echo -e "${VERT}*${NORMAL} Command à exécuter par Docker ${VERT}${CMD}${NORMAL}"
        unset opt_cmd
    else
        echo -e "${ROUGE}*${NORMAL} Aucune command n'a été spécifiée." >&2
        echo -e "${ROUGE}*${NORMAL} La commande par défaut est ${VERT}${CMD}${NORMAL}" >&2
    fi

    #
    # On génère la liste de périphériques à mapper entre l'environnement
    # hôte et l'environnement du conteneur.
    #

    if [[ $opt_perif -ne 0 ]] ; then
        local TMP=$DEVLST
        
        BUS_DEV=$(echo $BUS_DEV | awk 'BEGIN{FS=" "} {print $2 " " $4}' | awk 'BEGIN{FS=":"} {print $1}')

        BUS=$(echo $BUS_DEV | awk 'BEGIN{FS=" "} {print $1}')
        DEV=$(echo $BUS_DEV | awk 'BEGIN{FS=" "} {print $2}')

        echo -e "${VERT}*${NORMAL} Numéro de bus du périphérique usb ${ROUGE}$USB_BOARD${NORMAL} : ${VERT}${BUS}${NORMAL}"
        echo -e "${VERT}*${NORMAL} Numéro du périphérique usb ${ROUGE}$USB_BOARD${NORMAL} : ${VERT}${DEV}${NORMAL}"

        DEVLST="--device=/dev/bus/usb/$BUS/$DEV:/dev/bus/usb/$BUS/$DEV "
        echo -e "${VERT}*${NORMAL} Mappage du périphérique ${VERT}/dev/bus/usb/$BUS/$DEV${NORMAL}"

        if [[ -c /dev/ttyUSB0 ]] ; then
            DEVLST="$DEVLST --device=/dev/ttyUSB0:/dev/ttyUSB0 "
            echo -e "${VERT}*${NORMAL} Mappage du périphérique ${VERT}/dev/ttyUSB0${NORMAL}"
        fi

        if [[ -c /dev/ttyUSB1 ]] ; then
            DEVLST="$DEVLST --device=/dev/ttyUSB1:/dev/ttyUSB1"
            echo -e "${VERT}*${NORMAL} Mappage du périphérique ${VERT}/dev/ttyUSB1${NORMAL}"
        fi
    
        TMP=$(echo $TMP | awk 'BEGIN{FS=":"} {NF=NF; print $0}')

        for i in $TMP ; do
            DEVLST=$(echo "$DEVLST --device=${i}:${i}")
            echo -e "${VERT}*${NORMAL} Mappage du périphérique ${VERT}${i}${NORMAL}"
        done
        
        unset TMP
        unset opt_perif
    fi

    #
    # On génère la liste des dossiers à mapper entre l'environnement hôte
    # et l'environnement du conteneur.
    #

    if [[ $opt_fold -ne 0 ]] ; then
        local TMP=$FOLDLST
    
        FOLDLST=$(echo "-v $X11FOLD:$X11FOLD")
        echo -e "${VERT}*${NORMAL} Mappage du dossier ${VERT}${X11FOLD}${NORMAL}"

        TMP=$(echo $TMP | awk 'BEGIN{FS=":"} {NF=NF; print $0}')

        for i in $TMP ; do
            FOLDLST=$(echo "$FOLDLST -v ${i}:${i}")
            echo -e "${VERT}*${NORMAL} Mappage du dossier ${VERT}${i}${NORMAL}"
        done

        unset TMP
        unset opt_fold
    fi

    #
    # On exécute la commande dans le conteneur Docker.
    #

    echo -e "${VERT}*${NORMAL} Démarrage d'une nouvelle instance de l'image Docker..."
    echo -e ""

    eval "docker run --name xilinx_vivado --rm -i -t $DEVLST -e DISPLAY=$DISPLAY $FOLDLST $DOCKIMG $CMD"

    echo -e "${VERT}*${NORMAL} Fermeture et suppression de l'instance de l'image Docker."

    #
    # On supprime les variables locales
    #
    
    unset USB_BOARD
    unset BUS
    unset DEV
    unset DEVLST
    unset FOLDLST
    unset DOCKIMG
    unset CMD
    unset X11FOLD

    #
    # On supprime également les variables globales liées à la gestion
    # des options.
    #
    
    unset OPTIND
    unset OPTARG
    unset OPTERR
}

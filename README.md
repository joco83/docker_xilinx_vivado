# docker_xilinx_vivado
Docker Ubuntu + Oracle JDK pour l'exécution d'un environnement de développement Xilinx Vivado.

## Dockerfile

Le fichier Dockerfile contenu dans ce dépôt permet de générer une image contenant les dépendances pour l'environnement de développement Vivado de Xilinx.

```bash
docker build -t joco/ubuntu-for-xilinx-vivado .
```

Bien entendu, l'installation de l'environnement de développement Vivado de Xilinx, ainsi que l'obtention d'une licence (WebPak est gratuite) est laissé au soin de l'utilisateur.

## Les scripts bash

Le script dockapp.sh permet de simplifier le lancement d'une instance de l'image Docker précédemment décrite.
Le second script script.sh contient différentes configuration pour appeler la fonction run_dockapp contenu dans le script dockapp.sh.

Ceci afin d'éviter à l'utilisateur de devoir saisir une commande comme la suivante et sachant qu'il faut la modifier à chaque fois que l'on débranche et rebranche la carte de développement.

```bash
docker run --name xilinx_vivado --rm -i -t \ 
--device=/dev/bus/usb/002/008:/dev/bus/usb/002/008 \
--device=/dev/ttyUSB0:/dev/ttyUSB0 \
--device=/dev/ttyUSB1:/dev/ttyUSB1 \
-e DISPLAY=:0 \
-v /home/joco/docker_share:/home/joco/docker_share \
-v /home/joco/Documents/ITI4/VHDL_FPGA:/home/joco/Documents/ITI4/VHDL_FPGA \
-v /tmp/.X11-unix:/tmp/.X11-unix \
joco/xilinx-vivado /opt/Xilinx/Vivado/2015.2/bin/vivado
```

Il faut dans un premier temps sourcer les deux fichiers scripts dans le fichier ~/.bashrc.

Ensuite l'appel des fonctions s'effectue comme suit :

Lancement du conteneur avec la commande bash :

```bash
dock_bash
```

Lancement du conteneur avec la commande vivado :

```bash
dock_vivado
```

Lancement du conteneur avec des paramètres spécifiques :

```bash
run_dockapp -d <nom du device> \
-p <périphérique_1>:<périphérique_2>:<...> \
-i <nom de l'image Docker> \
-c <nom de la commande à exécuter par Docker> \
-f <Dossier_1>:<Dossier_2>:<...>
```

Une aide est également disponible :

```bash
run_dockapp -h
```

```bash
Commande : run_dockapp <liste des paramètres> <...>

Liste des paramètres :

 -d <nom du device>
    Voir le résultat de la commande lsusb.
 -p <périphérique_1>:<périphérique_2>:<...>
    Mappage de la liste des périphériques.
    Les périphérique de type /dev/ttyUSB*
    ainsi que le périphérique associé à la
    carte de développement sont automatiquement
    mappé.
 -i <nom de l'image Docker>
 -c <nom de la commande à exécuter par Docker>
 -f <Dossier_1>:<Dossier_2>:<...>
    Mappage de la liste des dossiers.
    Le dossier /tmp/.X11-unix est automatiquement
    mappé.
 -h
    Affichage de l'aide en ligne.
 -v
    Affichage de la version du script.
```

Bien évidemment, le script peut être modifier selon les besoins de l'utilisateur.

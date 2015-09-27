#!/bin/bash

function dock_vivado()
{
    run_dockapp -d FT -i joco/xilinx-vivado -p /dev/sdb1 -f /home/joco/docker:/opt/docker:/tmp -c /opt/Xilinx/Vivado/2015.2/bin/vivado
}

function dock_bash()
{
    run_dockapp -d FT -i joco/xilinx-vivado -p /dev/sdb1 -f /home/joco/docker:/opt/docker:/tmp -c /bin/bash
}

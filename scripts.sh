#!/bin/bash

function dock_vivado()
{
    run_dockapp -d FT -i joco/xilinx-vivado -f ~/docker_share -c /opt/Xilinx/Vivado/2015.2/bin/vivado
}

function dock_bash()
{
    run_dockapp -d FT -i joco/xilinx-vivado -f ~/docker_share -c /bin/bash
}

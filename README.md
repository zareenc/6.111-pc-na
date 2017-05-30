# La PC-na

For our 6.111 Final Project, my partner Matt Basile and I made a pool table that incorporated physical and virtual interaction. The balls and pool table were virtually displayed on a screen that was horizontally laid down like a real pool table. The virtual balls were interacted with using a physical cue stick, which was tracked with an IR camera. 

## Hardware Overview
The cue was outfitted with two rings of IR LEDs. We used an NTSC camera with an IR filter for position and speed tracking of the cue stick. The camera feed was inputted into an FPGA, which outputted the game display to the TV screen over VGA. 

## Software Overview
The FPGA was used for all computation, including initial screen calibration, tracking cue stick and calculating its speed, and simulating ball physics for the pool game. This repo contains the FPGA Verilog code. 

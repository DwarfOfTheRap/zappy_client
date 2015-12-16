#!/bin/bash
ARGS[0]=""
ARGS[1]="-t machin"
ARGS[2]="-n machin"
ARGS[3]="-n machin -y bonhomme"
ARGS[4]="-n machin -h bonhomme"
ARGS[5]="-n machin -p bonhomme"
ARGS[6]="-n machin -p 6543" #success
ARGS[7]="-p 6543 -n machin " #success
ARGS[8]="-n machin -p 6543 -h truc" #success
ARGS[9]="-n machin -h truc -p 6543" #success
ARGS[10]="-h truc -n machin -p 6543" #success
ARGS[11]="-n machin -p 6543 -u truc"
ARGS[12]="-h -n machin -p 6543"
ARGS[13]="-h -n -p 6543"

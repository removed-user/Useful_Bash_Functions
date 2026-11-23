# Check a socket, in `/proc/net/unix` using named column variables

 awk -v sock="${SOCKET}" '
 NR>1{ num=$1; ref=$2; proto=$3; flags=$4; type=$5; st=$6; inode=$7; path=$8
if (path == sock && flags == "00010000" && st == "01") {
found = 1
 exit
 }
 }
 END { exit !found} ' /proc/net/unix

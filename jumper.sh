#!/bin/bash
# TO do
# Colocar switch case com opcao de trocar o nó(restart), parar ou iniciar.
# Verificar se chmod 0400  /etc/openvpn/ipvanish/credentials.txt
#set -x
LOGPATH='/var/log/jumper/'
LOGFILE='logtrace'
pathDirFiles='/opt/jumper/'
NODESDIR="nodes"

function delTun(){
  echo "[+] Cleaning tun routes"
  ROUTEFILE='/tmp/routes'
  ip route show | grep -i tun > $ROUTEFILE
  while read line 
  do
    echo "[!] Deleting route: $line"
    ip route del $line
  done < $ROUTEFILE
  rm $ROUTEFILE
}

function route(){
  echo "[*] Configuring routes" 
  WORKS=$(ps aux | grep -i openvpn | grep -v grep)
  if [ -z "${WORKS}" ];then
    echo $WORKS
  fi
  IFACE=$(ifconfig  | grep -i tun| cut -d ':' -f 1)
  echo IFACE $IFACE
  if [ -z $IFACE ]
  then 
    echo '[-] Cannot found tun interface, aborting now!' 
    exit 1
  else
    echo "[-] VPN Interface is: $IFACE"
    ip route del default
    ip route add default dev $IFACE
    echo "[*] Done!"
  fi
}

function configFiles(){
  for i in $(ls); do sudo sed -i "s/auth-user-pass/auth-user-pass \/etc\/openvpn\/ipvanish\/credentials.txt/g" $i ;done
  for i in $(ls  nodes/);do sed -i 's/ca ca.ipvanish.com.crt/ca ..\/ca.ipvanish.com.crt/g' nodes/$i ;done
}

function getIP(){
  IP=$(curl -s meuip.com | grep -i '#FF0000'  | cut -d '>' -f 2 | cut -d '<' -f 1)
  COUNTRY=$(curl -s  http://ip-api.com/json/$IP | jq .'country')
  echo "[**] SUCCESS: Connect with $IP located at $COUNTRY at `date +%D_%T`" | tee -a $LOGPATH$LOGFILE 
} 

function checkCred(){
  if [ -d /etc/openvpn/ipvanish/ ]
  then
    if [ -f /etc/openvpn/ipvanish/credentials.txt ]
    then
      echo "[!] File with credentials OK, ready to go" 		
    else
      echo "[-] Missing file with credentials /etc/openvpn/ipvanish/credentials.txt"
      echo "Please, put your credentials at /etc/openvpn/ipvanish/credentials.txt using the format above:"
      echo -e "username\npassword"
   fi
  else
    echo "[-] Missing directory /etc/openvpn/ipvanish/"
  fi
}

function conVPN(){
  FILES=($NODESDIR/*)
  FILE="${FILES[RANDOM % ${#FILES[@]}]}"
  shortName=$(echo $FILE | cut -d '/' -f 2 | cut -d '.' -f1)
  echo "[**] Attempt to connect to IPVANISH using $shortName"
  openvpn $FILE &>/dev/null &
  sleep 7 
  echo "[***] Openvpn is running at PID $(pidof openvpn)"
  route
  getIP 
}

function logCheck(){
  if [ -d $LOGPATH ]
  then
    echo "[!] Log Directory Checked"
  else
    echo "[!] Missing Directory $LOGPATH, then creating"
    mkdir $LOGPATH
    echo "[+] Created"
  fi
}

function backUpRoute(){
  echo "[-] BackUp routine for network routes"
  ip route show default > .route.bkp
  echo "[+] Done"
}

function check(){
  PID=$(ps -C openvpn | tail -n +2 | tr -s ' '  | cut -d ' ' -f 2 )
  PID_COUNT=$(ps -C openvpn | wc -l)
  if [ $PID_COUNT -gt 1 ];then
    read -p "[!!] IPVANISH IS ALREADY RUNNING PID $PID, WANT TO KILL?[Y/n]"
      if [ $(echo $REPLY | tr A-Z a-z) == 'y' ];then
        for proc in $PID;do
	  echo "[!!] Killing $proc"
	  kill -s SIGTERM $PID
	  read -p '[-] Interface to reset: '
  	  delTun
	  dhclient -r $REPLY
	  sleep 2
	  dhclient -4 $REPLY
	done
        conVPN			
      fi
  else
    echo "[-] No vpn tunel running, starting one right NOW"
    conVPN
  fi
}

if [ $(id -u ) -ne 0 ];then
  echo "[+] Need root, fucker"
  exit 1

else
  logCheck
  checkCred
  check
fi

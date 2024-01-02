#!/bin/bash

echo "  _____      _   _       _ _    _____      _           _       _             _ "
echo " |  __ \    | | (_)     | (_)  / ____|    | |         | |     | |           (_)"
echo " | |__) |___| |_ _    __| |_  | |     __ _| | ___ ___ | | __ _| |_ ___  _ __ _ "
echo " |  _  // _ \ __| |  / _' | | | |    / _' | |/ __/ _ \| |/ _ | __/ _ \| '__| |"
echo " | | \ \  __/ |_| | | (_| | | | |___| (_| | | (_| (_) | | (_| | || (_) | |  | |"
echo " |_|  \_\___|\__|_|  \__,_|_|  \_____\__,_|_|\___\___/|_|\__,_|\__\___/|_|  |_|"
echo "                                                                               "

echo " - Università degli Studi di Milano A.A. 2022/23 - "
echo


# MIT License
#  
# Copyright (c) 2018 Patrizio Tufarolo
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##

Color_Off='\e[0m'
bldgrn='\e[1;32m'

ok_colorato_per_log() {
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        NORMAL=$(tput sgr0)
        LENMSG="$1"
        let COL=$(tput cols)-${LENMSG}
        printf "%${COL}s%s%s%s%s%s" "$NORMAL" "[" "$GREEN" "OK" "$NORMAL" "]"
}
do_cmd() {
        local cmd;
        local msg;
        cmd="$1"
        msg="$2"
        echo
        echo -e ${bldgrn}"${cmd}"${Color_Off}
        eval "$cmd" 2>/dev/null
        echo
        echo -n "$msg"
        ok_colorato_per_log ${#msg}
        read -rsp $'\nPremere invio per continuare...\n'
}
do_cmd_pid() {
        local cmd;
        local msg;
        local pid;
        local __resultvar=$3;
        cmd="$1"
        msg="$2"

        echo
        echo -e $bldgrn $cmd $Color_Off;
        eval "$cmd & "
        pid=$!
        echo -n "$msg"
        ok_colorato_per_log ${#msg}
        read -rsp $'\nPremere invio per continuare...\n'
        eval $__resultvar=$pid;
}

sudo -i exit

########################################
##### IMPOSTO INDIRIZZI IP STATICI #####
########################################

do_cmd "sudo himage DHCP ip addr add 192.168.0.1/27 dev eth0" "Assegno l'indirizzo 192.168.0.1 al server DHCP"
do_cmd "sudo himage router1 ip addr add 192.168.0.30/27 dev eth0" "Assegno l'indirizzo 192.168.0.30 al router sull'interfaccia eth0"

do_cmd "sudo himage FTP ip addr add 192.168.0.33/29 dev eth0" "Assegno l'indirizzo 192.168.0.33 al server FTP"
do_cmd "sudo himage HTTP ip addr add 192.168.0.34/29 dev eth0" "Assegno l'indirizzo 192.168.0.34 al server HTTP"
do_cmd "sudo himage DNS ip addr add 192.168.0.35/29 dev eth0" "Assegno l'indirizzo 192.168.0.35 al server DNS"
do_cmd "sudo himage router1 ip addr add 192.168.0.38/29 dev eth2" "Assegno l'indirizzo 192.168.0.38 al router sull'interfaccia eth2"

do_cmd "sudo himage pc3 ip addr add 192.168.0.41/29 dev eth0" "Assegno l'indirizzo 192.168.0.41 al pc3"
do_cmd "sudo himage router1 ip addr add 192.168.0.46/29 dev eth1" "Assegno l'indirizzo 192.168.0.46 al router sull'interfaccia eth1"

###########################################################
##### IMPOSTO IL SERVER DHCP E FILE DI CONFIGURAZIONE #####
###########################################################

do_cmd "sudo himage DHCP sh -c 'echo > /etc/dhcp/dhcpd.conf'" "Svuoto il file di configurazione /etc/dhcp/dhcpd.conf"
do_cmd "sudo himage DHCP sh -c 'cat > /etc/dhcp/dhcpd.conf << EOF
option domain-name-servers 192.168.0.35;
option subnet-mask 255.255.255.224;
option routers 192.168.0.30;

subnet 192.168.0.0 netmask 255.255.255.224 {
	range 192.168.0.3 192.168.0.30;
	host admin_laptop {
		hardware ethernet 42:00:aa:00:00:02;
		fixed-address 192.168.0.2;
	}
}
EOF'" "Configuro il server DHCP"
do_cmd_pid "sudo xterm -e 'himage DHCP dhcpd -d'" "Avvio il server DHCP" pid1
do_cmd "sudo himage pc2 dhclient eth0" "Avvio il client DHCP su pc2"
do_cmd "sudo himage admin_laptop dhclient eth0" "Avvio il client DHCP su admin_laptop"

##################################################
##### IMPOSTO LE ROTTE VERSO LE ALTRE SUBNET #####
##################################################

do_cmd "sudo himage pc2 ip route add 192.168.0.40/29 via 192.168.0.30 dev eth0" "Imposto la rotta da Amministrazione verso Utenti per pc2"
do_cmd "sudo himage pc2 ip route add 192.168.0.32/29 via 192.168.0.30 dev eth0" "Imposto la rotta da Amministrazione verso DMZ per pc2"

do_cmd "sudo himage admin_laptop ip route add 192.168.0.40/29 via 192.168.0.30 dev eth0" "Imposto la rotta da Amministrazione verso Utenti per admin_laptop"
do_cmd "sudo himage admin_laptop ip route add 192.168.0.32/29 via 192.168.0.30 dev eth0" "Imposto la rotta da Amministrazione verso DMZ per admin_laptop"

do_cmd "sudo himage pc3 ip route add 192.168.0.0/27 via 192.168.0.46 dev eth0" "Imposto la rotta da Utenti verso Amministrazione per pc3"
do_cmd "sudo himage pc3 ip route add 192.168.0.32/29 via 192.168.0.46 dev eth0" "Imposto la rotta da Utenti verso DMZ per pc3"

do_cmd "sudo himage FTP ip route add 192.168.0.40/29 via 192.168.0.38 dev eth0" "Imposto la rotta da DMZ verso Utenti per FTP"
do_cmd "sudo himage FTP ip route add 192.168.0.0/27 via 192.168.0.38 dev eth0" "Imposto la rotta da DMZ verso Amministrazione per FTP"

do_cmd "sudo himage HTTP ip route add 192.168.0.40/29 via 192.168.0.38 dev eth0" "Imposto la rotta da DMZ verso Utenti per HTTP"
do_cmd "sudo himage HTTP ip route add 192.168.0.0/27 via 192.168.0.38 dev eth0" "Imposto la rotta da DMZ verso Amministrazione per HTTP"

do_cmd "sudo himage DNS ip route add 192.168.0.40/29 via 192.168.0.38 dev eth0" "Imposto la rotta da DMZ verso Utenti per DNS"
do_cmd "sudo himage DNS ip route add 192.168.0.0/27 via 192.168.0.38 dev eth0" "Imposto la rotta da DMZ verso Amministrazione per DNS"

######################################
##### FACCIO DEI TEST CON PING #####
######################################

do_cmd "sudo himage pc2 ping -c 1 192.168.0.33" "Amministrazione comunica con DMZ"
do_cmd "sudo himage admin_laptop ping -c 1 192.168.0.41" "Amministrazione comunica con Utenti"
do_cmd "sudo himage pc3 ping -c 1 192.168.0.34" "Utenti comunica con DMZ"

#######################################
##### IMPOSTO E TESTO SERVER HTTP #####
#######################################

do_cmd "sudo himage HTTP iptables -t filter -P INPUT DROP" "Modifico la policy per fare un deny-all"
do_cmd "sudo himage HTTP iptables -t filter -I INPUT -s 192.168.0.0/27 -p tcp --dport 80 -j ACCEPT" "Imposto la rules per accettare il traffico verso HTTP  dalla subnet Amministrazione"
do_cmd "sudo himage HTTP iptables -t filter -I INPUT -s 192.168.0.40/29 -p tcp --dport 80 -j ACCEPT" "Imposto la rules per accettare il traffico verso HTTP  dalla subnet Utenti"
do_cmd "sudo himage HTTP iptables -L -n" "Mostro le rules della tabella filter"
do_cmd "sudo himage HTTP service lighttpd start" "Starto il server HTTP"
do_cmd "sudo himage HTTP service lighttpd status" "Controllo lo stato del servizio"
do_cmd "sudo himage pc2 curl 192.168.0.34" "Amministrazione raggiunge il sito web (PER ORA NO DNS, QUINDI USO IP)"
do_cmd "sudo himage pc3 curl -I 192.168.0.34" "Utenti raggiunge il sito web (NO DNS)"

######################################
##### IMPOSTO E TESTO SERVER DNS #####
#########################Co#############

do_cmd "sudo himage DNS iptables -t filter -P INPUT DROP" "Modifico la policy per fare un deny-all"
do_cmd "sudo himage DNS iptables -t filter -I INPUT -s 192.168.0.0/27 -p tcp --dport 53 -j ACCEPT" "Imposto la rules per accettare il traffico verso DNS dalla subnet Amministrazione"
do_cmd "sudo himage DNS iptables -t filter -I INPUT -s 192.168.0.40/29 -p tcp --dport 53 -j ACCEPT" "Imposto la rules per accettare il traffico verso DNS  dalla subnet Utenti"
do_cmd "sudo himage DNS iptables -t filter -I INPUT -s 192.168.0.0/27 -p udp --dport 53 -j ACCEPT" "Imposto la rules per accettare il traffico verso DNS dalla subnet Amministrazione"
do_cmd "sudo himage DNS iptables -t filter -I INPUT -s 192.168.0.40/29 -p udp --dport 53 -j ACCEPT" "Imposto la rules per accettare il traffico verso DNS  dalla subnet Utenti"
do_cmd "sudo himage DNS iptables -L -n" "Mostro le rules della tabella filter"
do_cmd "sudo himage DNS sh -c 'cat > /etc/bind/named.conf.local << EOF
zone \"progetto.com\" {
	type master;
	file \"/etc/bind/db.progetto.com\";
};
EOF'" "Imposto il file /etc/bind/named.conf.local"

do_cmd "sudo hcp dns/db.progetto.com DNS:/etc/bind/db.progetto.com" "Importo il file /etc/bind/db.progetto.com dalla cartella dns"

do_cmd "sudo himage DNS named-checkconf /etc/bind/named.conf.local" "Controllo i file di configurazione named.conf.local"
do_cmd "sudo himage DNS named-checkzone progetto.com. /etc/bind/db.progetto.com" "Controllo i file di configurazione db.progetto.com"
do_cmd "sudo himage DNS named" "Starto il servizio DNS"

do_cmd "sudo himage pc3 sh -c 'echo nameserver 192.168.0.35 > /etc/resolv.conf'" "Specifico il server DNS per pc3" #per pc2 e admin non c'è bisogno che lo fa il DHCP.

do_cmd "sudo himage pc2 curl -I www.progetto.com" "Testo il server DNS mandando una richiesta al server HTTP tramite il nome di dominio"
do_cmd "sudo himage pc3 nslookup ftp.progetto.com" "Testo il server DNS tramite nslookup"
do_cmd "sudo himage admin_laptop dig http.progetto.com" "Testo il server DNS tramite dig"

#########################################
##### IMPOSTO E TESTO IL SERVER FTP #####
#########################################

do_cmd "sudo himage FTP useradd -m -p saq7YKO/y2eaI Omar" "Creo l'utente Omar"
do_cmd "sudo himage FTP usermod -aG sudo Omar" "Inserisco l'utente Omar nel gruppo sudo"
do_cmd "sudo himage pc2 touch test.txt" "Creo file di prova da utilizzare con FTP"
do_cmd "sudo himage pc2 sh -c 'cat > test.txt << EOF
FILE DI TESTO DI PROVA
PER SERVIZIO FTP
PROGETTO RETI DI CALCOLATORI
EOF'" "Riempio il file di prova"
do_cmd "sudo xterm -e 'himage pc2 ftp 192.168.0.33'" "Avvio servizio FTP"

################################
##### IPTABLES E FILTERING #####
################################

do_cmd "sudo xterm -e 'himage pc3 ftp 192.168.0.33'" "Avvio servizio FTP su pc3 e vedo che funziona correttamente"
do_cmd "Simuliamo la compromissione di un host, ad esempio pc3. L'amministrazione insieme al SOC nota che sono state effettuate delle azioni sul server FTP, allora bloccano l'accesso a tutti e lo permettono solo all'amministrazione per cercare di risolvere il problema"
do_cmd "sudo himage FTP iptables -t filter -P INPUT DROP" "Imposto la policy su deny-all"
do_cmd "sudo himage FTP iptables -t filter -I INPUT -s 192.168.0.0/27 -p tcp --dport 21 -j ACCEPT" "Imposto la rules per accettare il traffico verso FTP solo dalla subnet Amministrazione"
do_cmd "sudo himage FTP iptables -t filter -A INPUT -s 192.168.0.0/27 -p tcp --dport 20 -j ACCEPT" "Imposto la rules per accettare il traffico verso FTP solo dalla subnet Amministrazione"
do_cmd "sudo xterm -e 'himage pc3 ftp 192.168.0.33'" "Provo a connettermi al server FTP dal pc compromesso e vedo che è bloccato"
do_cmd "sudo xterm -e 'himage admin_laptop ftp 192.168.0.33'" "Provo a connettermi al server FTP da un pc dell'Amministrazione e vedo che funziona"
do_cmd "sudo himage FTP iptables -L -n" "Mostro le rules della tabella filter"

echo

#!/bin/bash
#set -x -v
##get all interfaces
ints_all=$(diff <(ip address show up type vlan | awk '/"inet"/ || /bond/' ) <(ip address show up type vlan | awk '/inet/ && /bond/') | egrep -o "bond[0-9].([0-9.*])+" )
##get interfaces with IP
ints_ip=$(ip address show up type vlan | awk '/inet/ && /bond/' | egrep -o "bond[0-9]+.([0-9.*])+")
##get interfaces without IP
ints=$(diff <(echo "$ints_all") <(echo "$ints_ip") | egrep -o "bond[0-9]+.([0-9.*])+")
##get interfaces with default gateway
WITH_GATEWAY=`ip route show table all|grep default|awk '{print $3 " " $5}'`
int_WITH_GATEWAY=`ip route show table all|grep default|awk '{print $5}'`
list_int_with_gateway=( $( echo $int_WITH_GATEWAY ) )
list_ints_all=( $( echo $ints_all ) )
declare -A table_status=()
get_ping_getway() {
	while
        	read line
	do
        	WITH_GATEWAY_IP=`echo $line|awk '{print $1}'`
	        WITH_GATEWAY_INTERFACE=`echo $line|awk '{print $2}'`
        	ping -q -c 3 -W 1 $WITH_GATEWAY_IP 2>&1 > /dev/null
	        if [    "$?" = "0"      ]; then
        	        echo -e "\033[0;32m Gateway Network Conectivity is ok in $WITH_GATEWAY_INTERFACE\033[0m"
			table_status+=( [$WITH_GATEWAY_INTERFACE"pg"]="OK" )
	        else
        	        echo -e "\033[0;31m Gateway Network Conectivity is FAILED in $WITH_GATEWAY_INTERFACE \033[0m" 
			table_status+=( [$WITH_GATEWAY_INTERFACE"pg"]="DOWN" )
	        fi
	done <<<"$WITH_GATEWAY"
}

get_ping() {
IP_LIST=()
NUM=2
INTERFACE=$1
NETWORK=$2
while [ $NUM -lt 10  ];do
    ping -q -c 1 -W 1 -I $INTERFACE  $NETWORK$NUM 2>&1 > /dev/null
    
    if [ "$?" = "0" ]; then
           IP_LIST+=("$NETWORK$NUM")
           if [ "${#IP_LIST[@]}" -le "3"  ]; then
		   net=$(ip r | egrep "$INTERFACE" | awk '{print $1}')
                   echo -e "\033[0;32m Network Conectivity is ok in "$INTERFACE" , "$net" \033[0m"
		   table_status+=( [$INTERFACE"ps"]="OK" )
                   break
	   else
		  net=$(ip r | egrep "$INTERFACE" | awk '{print $1}')
                  echo -e "\033[0;31m Network Conectivity is Failed in "$INTERFACE" , "$net" \033[0m"
		  table_status+=( [$INTERFACE"ps"]="Failed" )
                  break
           fi
    fi
    NUM=$(expr $NUM + 1)
done

}
set_ip_config() {
        list_ints=( $( echo $ints ) )
        num_exit=$(("${#list_ints[@]}" + 1))
        select option in $ints exit
        do
                if [[ $REPLY -le "${#list_ints[@]}" ]];then
                        i=$((REPLY - 1))
                        int=$(echo ${list_ints[i]})
			read -p "please enter the IP of $int interface with netmask (ex.192.168.1.2/24): " ip_int
			read -p "please enter the Gateway IP " gtw
			if [[ -n $int ]]; then
				sudo ip addr add $ip_int dev $int
				ping -q -c 4 -W 1 -I $int  $gtw 2>&1 > /dev/null
				if [ "$?" = "0" ]; then
					 echo -e "\033[0;32m Network Conectivity is ok in "$int" , "$gtw" \033[0m"
				else
					echo -e "\033[0;31m Failed To ping Gateway $gtw \033[0m"
				fi
			fi
			sudo ip addr del $ip_int dev $int
                elif [[ $REPLY == "$num_exit" ]];then
                        exit 1
                else
                        echo "Invalid Input\n"
                        echo "Enter an interface again..."
                        return
                fi
        done
}
get_interface() {
	list_no_gateway=()
	for i in "${list_ints_all[@]}"; do
	    skip=
	    for j in "${list_int_with_gateway[@]}"; do
        	[[ $i == $j ]] && { skip=1; break; }
	    done
	    [[ -n $skip ]] || list_no_gateway+=("$i")
	done

	declare -A list_int_ip=()
	for k in ${list_no_gateway[@]}
	do
		int_ip=$(ip r | grep -w $k | awk '{print $1}' | awk -F '.' '{print $1"."$2"."$3"."}')
		list_int_ip+=( [$k]=$int_ip )
	done

	for INT in "${!list_int_ip[@]}";do
		if [	-n "${list_int_ip[${INT}]}"	];then
			get_ping ${INT} ${list_int_ip[${INT}]}
		fi
	done
}
show_status() {
	    echo -e "BOND\tINTERFACE\tINTERFACE STATUS\tBOND STATUS"
        echo -e "--------------------------------------------------------------------------"
        bondname=$(ip link show type bond | egrep -o "bond([0-9.*])+")
        list_bondname=( $( echo $bondname ) )
        for name in ${list_bondname[@]}
        do
                int_bond=$(ip link show  | egrep "$name" | awk '{print $2}' | grep -v bond | awk -F ':' '{print $1}')
                while
                        read line
                do
                        int_bond_status=$(ip a | egrep "$line" | egrep -o "state ([A-Z])+" | awk '{print $2}')
			bond_status=$(ip link show type bond | egrep "$name" | egrep -o "state ([A-Z])+" | awk '{print $2}')
                        echo -e "$name\t$line\t\t$int_bond_status\t\t\t$bond_status"
                done <<<"$int_bond"
        done
	echo -e "\n--------------------------------------------------------------------------"
	echo -e "INTERFACE\tSTATUS\tPING\tIP\t\t\tGATEWAY "
	echo -e "--------------------------------------------------------------------------"
	for l in ${list_ints_all[@]}
	do
		int_ip=$(ip a |  awk "/inet/ && /$l/" | awk '{print $2}')
		int_status=$(ip address show type vlan |  awk "/inet/ || /$l/" | egrep -o "state ([A-Z])+" | awk '{print $2}')
		if [[ -n ${table_status[$l"ps"]} ]]; then
			int_ping=${table_status[$l"ps"]}
		else
			int_ping=${table_status[$l"pg"]}
		fi
		int_gw=$(ip route show table all | grep $l  | egrep -o "via ([0-9.*])+" | awk '{print $2}') 
		#echo -e "$l\t$int_status\t$int_ip\t${table_status[$l"ps"]}\t${table_status[$l"pg"]}"
		echo -e "$l\t$int_status\t$int_ping\t$int_ip\t$int_gw"
		echo -e "--------------------------------------------------------------------------"
	done
}
select option in 'check all interfaces' 'set ip' 'exit'
do
	if [ $REPLY == '1' ]; then
		get_ping_getway
		get_interface
		show_status
	elif [ $REPLY == '2' ]; then
		set_ip_config
	elif [ $REPLY == '3' ]; then
		exit 0
	else
		echo "Invalid Input\n"
	        echo "Run the Network Script Again..."
	fi
done

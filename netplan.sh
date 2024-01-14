 #!/bin/bash

#title           :Netplan_Configuration.sh
#description     :This script executes the network configuration and interfaces based on the server type.
#author          :Setareh Nazeri
#version         :1.0
#usage           :bash Netplan_Configuration.sh
#notes           :Vim and Emacs are needed to use this script.
#===============================================================================

#HOW IT WORKS
#1st get all the needed variables
#2nd set the input variables
#3rd run final configuration of network using netplan
#===============================================================================


get_mgmt_info(){
    read -p "Management VLAN ID: " MGMT_VLAN_ID
    read -p "Management IP Address: " MGMT_VLAN_IP

    MGMT_VLAN_ID="${MGMT_VLAN_ID:-176}"
    MGMT_VLAN_IP="${MGMT_VLAN_IP:-172.31.4.108}"


    MGMT_VLAN_PREFIX=24
    read -e -i "$MGMT_VLAN_PREFIX" -p "Management Prefix: " input
    MGMT_VLAN_PREFIX="${input:-$MGMT_VLAN_PREFIX}"

    MGMT_VLAN_Gateway=$(echo $MGMT_VLAN_IP | awk '{print $1}' | cut -d'.' -f1-3).1
    read -e -i "$MGMT_VLAN_Gateway" -p "Management VLAN Gateway: " input
    MGMT_VLAN_Gateway="${input:-$MGMT_VLAN_Gateway}"

    MGMT_VLAN_Network=$(echo $MGMT_VLAN_IP | awk '{print $1}' | cut -d'.' -f1-3).0/$MGMT_VLAN_PREFIX
    read -e -i "$MGMT_VLAN_Network" -p "Management VLAN Network: " input
    MGMT_VLAN_Network="${input:-$MGMT_VLAN_Network}"

    show_mgmt_input

}

get_occ_info(){
    read -p "Cloud Component VLAN ID: " OCC_VLAN_ID
    read -p "Cloud Component IP Address: " OCC_VLAN_IP

    OCC_VLAN_ID="${OCC_VLAN_ID:-96}"
    OCC_VLAN_IP="${OCC_VLAN_IP:-192.168.96.10}"

    OCC_VLAN_PREFIX=24
    read -e -i "$OCC_VLAN_PREFIX" -p "Cloud Component Prefix: " input
    OCC_VLAN_PREFIX="${input:-$OCC_VLAN_PREFIX}"

    OCC_VLAN_Gateway=$(echo $OCC_VLAN_IP | awk '{print $1}' | cut -d'.' -f1-3).1
    read -e -i "$OCC_VLAN_Gateway" -p "Cloud Component VLAN Gateway: " input
    OCC_VLAN_Gateway="${input:-$OCC_VLAN_Gateway}"

    OCC_VLAN_Network=$(echo $OCC_VLAN_IP | awk '{print $1}' | cut -d'.' -f1-3).0/$OCC_VLAN_PREFIX
    read -e -i "$OCC_VLAN_Network" -p "OCC VLAN Network: " input
    OCC_VLAN_Network="${input:-$OCC_VLAN_Network}"

    show_occ_input

}

get_overlay_info(){
    read -p "Overlay VLAN ID: " OVERLAY_VLAN_ID
    read -p "Overlay IP Address: " OVERLAY_VLAN_IP

    OVERLAY_VLAN_ID="${OVERLAY_VLAN_ID:-97}"
    OVERLAY_VLAN_IP="${OVERLAY_VLAN_IP:-192.168.97.10}"

    OVERLAY_VLAN_PREFIX=24
    read -e -i "$OVERLAY_VLAN_PREFIX" -p "Overlay Prefix: " input
    OVERLAY_VLAN_PREFIX="${input:-$OVERLAY_VLAN_PREFIX}"

    OVERLAY_VLAN_Gateway=$(echo $OVERLAY_VLAN_IP | awk '{print $1}' | cut -d'.' -f1-3).1
    read -e -i "$OVERLAY_VLAN_Gateway" -p "Overlay VLAN Gateway: " input
    OVERLAY_VLAN_Gateway="${input:-$OVERLAY_VLAN_Gateway}"

    show_overlay_input

}

get_cephfront_info(){
    read -p "Ceph Public VLAN ID: " CEPH_PUB_VLAN_ID
    read -p "Ceph Public IP: " CEPH_PUB_VLAN_IP

    CEPH_PUB_VLAN_ID="${CEPH_PUB_VLAN_ID:-98}"
    CEPH_PUB_VLAN_IP="${CEPH_PUB_VLAN_IP:-192.168.98.10}"

    CEPH_PUB_VLAN_PREFIX=24
    read -e -i "$CEPH_PUB_VLAN_PREFIX" -p "Ceph Public Prefix: " input
    CEPH_PUB_VLAN_PREFIX="${input:-$CEPH_PUB_VLAN_PREFIX}"


    CEPH_PUB_VLAN_Gateway=$(echo $CEPH_PUB_VLAN_IP | awk '{print $1}' | cut -d'.' -f1-3).1
    read -e -i "$CEPH_PUB_VLAN_Gateway" -p "Ceph Public VLAN Gateway: " input
    CEPH_PUB_VLAN_Gateway="${input:-$CEPH_PUB_VLAN_Gateway}"

    show_cephpub_input
}

get_cephbackend_info(){

    read -p "Ceph Private VLAN ID: " CEPH_PRV_VLAN_ID
    read -p "Ceph Priavte IP: " CEPH_PRV_VLAN_IP

    CEPH_PRV_VLAN_ID="${CEPH_PRV_VLAN_ID:-99}"
    CEPH_PRV_VLAN_IP="${CEPH_PRV_VLAN_IP:-192.168.99.10}"

    CEPH_PRV_VLAN_PREFIX=24
    read -e -i "$CEPH_PRV_VLAN_PREFIX" -p "Ceph Private Prefix: " input
    CEPH_PRV_VLAN_PREFIX="${input:-$CEPH_PRV_VLAN_PREFIX}"


    CEPH_PRV_VLAN_Gateway=$(echo $CEPH_PRV_VLAN_IP | awk '{print $1}' | cut -d'.' -f1-3).1
    read -e -i "$CEPH_PRV_VLAN_Gateway" -p "Ceph Private VLAN Gateway: " input
    CEPH_PRV_VLAN_Gateway="${input:-$CEPH_PRV_VLAN_Gateway}"

    show_cephprv_input

}

get_pubedgevip_info(){
    read -p "External Edge VLAN ID: " EXT_EDG_VLAN_ID
    read -p "External Edge IP Address: " EXT_EDG_VLAN_IP

    EXT_EDG_VLAN_ID="${EXT_EDG_VLAN_ID:-4}"
    EXT_EDG_VLAN_IP="${EXT_EDG_VLAN_IP:-192.168.4.10}"

    EXT_EDG_VLAN_PREFIX=24
    read -e -i "$EXT_EDG_VLAN_PREFIX" -p "External Edge VLAN Prefix: " input
    EXT_EDG_VLAN_PREFIX="${input:-$EXT_EDG_VLAN_PREFIX}"

    EXT_EDG_VLAN_Gateway=$(echo $EXT_EDG_VLAN_IP | awk '{print $1}' | cut -d'.' -f1-3).1
    read -e -i "$EXT_EDG_VLAN_Gateway" -p "External Edge VLAN Gateway: " input
    EXT_EDG_VLAN_Gateway="${input:-$EXT_EDG_VLAN_Gateway}"

    EXT_EDG_VLAN_Network=$(echo $EXT_EDG_VLAN_IP | awk '{print $1}' | cut -d'.' -f1-3).0/$EXT_EDG_VLAN_PREFIX
    read -e -i "$EXT_EDG_VLAN_Network" -p "External Edge VLAN Network: " input
    EXT_EDG_VLAN_Network="${input:-$EXT_EDG_VLAN_Network}"

    show_edg_input

}

get_pubprovider_info(){
    read -p "External Floating VLAN ID: " EXT_FIP_VLAN_ID
    EXT_FIP_VLAN_ID="${EXT_FIP_VLAN_ID:-2}"

    show_fip_input
}

get_lbaas_info(){
    read -p "LoadBalancer Private VLAN ID: " LBaaS_VLAN_ID
    LBaaS_VLAN_ID="${LBaaS_VLAN_ID:-101}"

    show_lbaas_input
}

get_dbaas_info(){

    read -p "Trove Private VLAN ID: " TROVE_VLAN_ID
    TROVE_VLAN_ID="${TROVE_VLAN_ID:-41}"

    show_trove_input
}

get_ironic_info(){
    read -p "Ironic Private VLAN ID: " IRONIC_VLAN_ID
    IRONIC_VLAN_ID="${IRONIC_VLAN_ID:-42}"

    show_ironic_input
}

show_mgmt_input(){
  echo -e "\033[1;33m \n--------------Confirmation--------------\n \033[0m"
  echo -e "\033[1;32mManagement VLAN ID: $MGMT_VLAN_ID \033[0m"
  echo -e "\033[1;32mManagement IP Address: $MGMT_VLAN_IP \033[0m"
  echo -e "\033[1;32mManagement Prefix: $MGMT_VLAN_PREFIX \033[0m"
  echo -e "\033[1;32mManagement GateWay: $MGMT_VLAN_Gateway \033[0m"
  echo -e "\033[1;32mManagement NetWork: $MGMT_VLAN_Network \033[0m \n"

  read -p "Please Confirm Inputed Variable(s), Is that ok?  [Yes=0 No=1, Default=yes]: " CONFIRM_INPUT
  CONFIRM_INPUT="${CONFIRM_INPUT:-0}"
  if [    "$CONFIRM_INPUT" = "0"     ];then
    echo -e "\033[0;32mInput Confirmed \033[0m \n"


  else
    echo -e "\033[0;31mPlease Enter value(s) again\033[0m"
    get_mgmt_info
  fi
}

show_occ_input(){
  echo -e "\033[1;33m \n--------------Confirmation--------------\n \033[0m"
  echo -e "\033[1;33mOCC VLAN ID: $OCC_VLAN_ID \033[0m"
  echo -e "\033[1;33mOCC IP Address: $OCC_VLAN_IP \033[0m"
  echo -e "\033[1;33mOCC Prefix: $OCC_VLAN_PREFIX \033[0m"
  echo -e "\033[1;33mOCC GateWay: $OCC_VLAN_Gateway \033[0m"
  echo -e "\033[1;33mOCC NetWork: $OCC_VLAN_Network \033[0m \n"

  read -p "Please Confirm Inputed Variable(s), Is that ok?  [Yes=0 No=1, Default=yes]: " CONFIRM_INPUT
  CONFIRM_INPUT=${CONFIRM_INPUT:-"0"}
  if [    "$CONFIRM_INPUT" = "0"     ];then
    echo -e "\033[0;32mInput Confirmed \033[0m \n"
  else
    echo -e "\033[0;31mPlease Enter values again\033[0m"
    get_occ_info
  fi  
}

show_overlay_input(){
  echo -e "\033[1;33m \n--------------Confirmation--------------\n \033[0m"
  echo -e "\033[1;34mOverlay VLAN ID: $OVERLAY_VLAN_ID \033[0m"
  echo -e "\033[1;34mOverlay IP Address: $OVERLAY_VLAN_IP \033[0m"
  echo -e "\033[1;34mOverlay Prefix: $OVERLAY_VLAN_PREFIX \033[0m"
  echo -e "\033[1;34mOverlay GateWay: $OVERLAY_VLAN_Gateway \033[0m"
#  echo -e "\033[1;34mOverlay NetWork: $OVERLAY_VLAN_Network \033[0m \n"

  read -p "Please Confirm Inputed Variable(s), Is that ok?  [Yes=0 No=1, Default=yes]: " CONFIRM_INPUT
  CONFIRM_INPUT=${CONFIRM_INPUT:-"0"}
  if [    "$CONFIRM_INPUT" = "0"     ];then
    echo -e "\033[0;32mInput Confirmed \033[0m \n"
  else
    echo -e "\033[0;31mPlease Enter values again\033[0m"
    get_overlay_info
  fi  
}


show_cephpub_input(){
  echo -e "\033[1;33m \n--------------Confirmation--------------\n \033[0m"
  echo -e "\033[1;35mCephfront VLAN ID: $CEPH_PUB_VLAN_ID \033[0m"
  echo -e "\033[1;35mCephfront IP Address: $CEPH_PUB_VLAN_IP \033[0m"
  echo -e "\033[1;35mCephfront Prefix: $CEPH_PUB_VLAN_PREFIX \033[0m"
  echo -e "\033[1;35mCephfront GateWay: $CEPH_PUB_VLAN_Gateway \033[0m"
#  echo -e "\033[1;35mCephfront NetWork: $CEPH_PUB_VLAN_Network \033[0m \n"

  read -p "Please Confirm Inputed Variable(s), Is that ok?  [Yes=0 No=1, Default=yes]: " CONFIRM_INPUT
  CONFIRM_INPUT=${CONFIRM_INPUT:-"0"}
  if [    "$CONFIRM_INPUT" = "0"     ];then
    echo -e "\033[0;32mInput Confirmed \033[0m \n"
  else
    echo -e "\033[0;31mPlease Enter values again\033[0m"
    get_cephfront_info
  fi  
}


show_cephprv_input(){
  echo -e "\033[1;33m \n--------------Confirmation--------------\n \033[0m"
  echo -e "\033[1;36mCephbackend VLAN ID: $CEPH_PRV_VLAN_ID \033[0m"
  echo -e "\033[1;36mCephbackend IP Address: $CEPH_PRV_VLAN_IP \033[0m"
  echo -e "\033[1;36mCephbackend Prefix: $CEPH_PRV_VLAN_PREFIX \033[0m"
  echo -e "\033[1;36mCephbackend GateWay: $CEPH_PRV_VLAN_Gateway \033[0m"
#  echo -e "\033[1;36mCephbackend NetWork: $CEPH_PRV_VLAN_Network \033[0m \n"

  read -p "Please Confirm Inputed Variable(s), Is that ok?  [Yes=0 No=1, Default=yes]: " CONFIRM_INPUT
  CONFIRM_INPUT=${CONFIRM_INPUT:-"0"}
  if [    "$CONFIRM_INPUT" = "0"     ];then
    echo -e "\033[0;32mInput Confirmed \033[0m \n"
  else
    echo -e "\033[0;31mPlease Enter values again\033[0m"
    get_cephbackend_info
  fi  
}


show_edg_input(){
  echo -e "\033[1;33m \n--------------Confirmation--------------\n \033[0m"
  echo -e "\033[1;37mPubedgevip VLAN ID: $EXT_EDG_VLAN_ID \033[0m"
  echo -e "\033[1;37mPubedgevip IP Address: $EXT_EDG_VLAN_IP \033[0m"
  echo -e "\033[1;37mPubedgevip Prefix: $EXT_EDG_VLAN_PREFIX \033[0m"
  echo -e "\033[1;37mPubedgevip GateWay: $EXT_EDG_VLAN_Gateway \033[0m"
#  echo -e "\033[1;37mPubedgevip NetWork: $EXT_EDG_VLAN_Network \033[0m \n"

  read -p "Please Confirm Inputed Variable(s), Is that ok?  [Yes=0 No=1, Default=yes]: " CONFIRM_INPUT
  CONFIRM_INPUT=${CONFIRM_INPUT:-"0"}
  if [    "$CONFIRM_INPUT" = "0"     ];then
    echo -e "\033[0;32mInput Confirmed \033[0m \n"
  else
    echo -e "\033[0;31mPlease Enter values again\033[0m"
    get_pubedgevip_info
  fi  
}


show_fip_input(){
  echo -e "\033[1;33m \n--------------Confirmation--------------\n \033[0m"
  echo -e "\033[1;37mPubprovider VLAN ID: $EXT_FIP_VLAN_ID \033[0m \n"

  read -p "Please Confirm Inputed Variable(s), Is that ok?  [Yes=0 No=1, Default=yes]: " CONFIRM_INPUT
  CONFIRM_INPUT="${CONFIRM_INPUT:-0}"
  if [    "$CONFIRM_INPUT" = "0"     ];then
    echo -e "\033[0;32mInput Confirmed \033[0m \n"
  else
    echo -e "\033[0;31mPlease Enter values again\033[0m"
    get_pubprovider_info
  fi  
}

show_lbaas_input(){
  echo -e "\033[1;33m \n--------------Confirmation--------------\n \033[0m"
  echo -e "\033[1;37mLoadBalancer VLAN ID: $LBaaS_VLAN_ID \033[0m \n"

  read -p "Please Confirm Inputed Variable(s), Is that ok?  [Yes=0 No=1, Default=yes]: " CONFIRM_INPUT
  CONFIRM_INPUT=${CONFIRM_INPUT:-"0"}
  if [    "$CONFIRM_INPUT" = "0"     ];then
    echo -e "\033[0;32mInput Confirmed \033[0m \n"
  else
    echo -e "\033[0;31mPlease Enter values again\033[0m"
    get_lbaas_info
  fi  
}

show_trove_input(){
  echo -e "\033[1;33m \n--------------Confirmation--------------\n \033[0m"
  echo -e "\033[1;37mTrove Private VLAN ID: $TROVE_VLAN_ID \033[0m \n"

  read -p "Please Confirm Inputed Variable(s), Is that ok?  [Yes=0 No=1, Default=yes]: " CONFIRM_INPUT
  CONFIRM_INPUT=${CONFIRM_INPUT:-"0"}
  if [    "$CONFIRM_INPUT" = "0"     ];then
    echo -e "\033[0;32mInput Confirmed \033[0m \n"
  else
    echo -e "\033[0;31mPlease Enter values again\033[0m"
    get_dbaas_info
  fi  
}

show_ironic_input(){
  echo -e "\033[1;33m \n--------------Confirmation--------------\n \033[0m"
  echo -e "\033[1;37mIronic Private VLAN ID: $IRONIC_VLAN_ID \033[0m \n"

  read -p "Please Confirm Inputed Variable(s), Is that ok?  [Yes=0 No=1, Default=yes]: " CONFIRM_INPUT
  CONFIRM_INPUT=${CONFIRM_INPUT:-"0"}
  if [    "$CONFIRM_INPUT" = "0"     ];then
    echo -e "\033[0;32mInput Confirmed \033[0m \n"
  else
    echo -e "\033[0;31mPlease Enter values again\033[0m"
    get_ironic_info
  fi  
}

set_controller(){
# Creates a backup of old netplan config
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bk_`date +%Y%m%d%H%M`
cat > /etc/netplan/00-installer-config.yaml <<EOT
network:
  bonds:
    $BOND0_NAME:
      interfaces:
      - $NET_1G_1
      - $NET_1G_2
      nameservers:
        addresses: [$DNS_SERVERS]
        search: []
      parameters:
        mode: balance-rr
        mii-monitor-interval: 100
    $BOND1_NAME:
      interfaces:
      - $NET_10G_1
      - $NET_10G_2
      parameters:
        mode: balance-rr
        mii-monitor-interval: 100
  ethernets:
    $NET_1G_1: {}
    $NET_1G_2: {}
    $NET_10G_1: {}
    $NET_10G_2: {}
  version: 2
  renderer: networkd
  vlans:
    $BOND0_NAME.$MGMT_VLAN_ID: #MGMT
      addresses:
      - $MGMT_VLAN_IP/$MGMT_VLAN_PREFIX
      gateway4: $MGMT_VLAN_Gateway
      id: $MGMT_VLAN_ID
      link: $BOND0_NAME
      nameservers:
        addresses: [$DNS_SERVERS]
        search: []

    $BOND0_NAME.$OCC_VLAN_ID: #OCC
      id: $OCC_VLAN_ID
      link: $BOND0_NAME
      addresses:
      - $OCC_VLAN_IP/$OCC_VLAN_PREFIX   
      routes:
      - to: 0.0.0.0/0
        via: $OCC_VLAN_Gateway
        table: 101
      - to: $OCC_VLAN_Network
        scope: link
        from: $OCC_VLAN_IP
        table: 101
      routing-policy:
      - from: $OCC_VLAN_IP
        table: 101


    $BOND1_NAME.$OVERLAY_VLAN_ID: #Overlay
      id: $OVERLAY_VLAN_ID
      link: $BOND1_NAME
      addresses:
      - $OVERLAY_VLAN_IP/$OVERLAY_VLAN_PREFIX

    $BOND0_NAME.$CEPH_PUB_VLAN_ID: #Cephfront
      id: $CEPH_PUB_VLAN_ID
      link: $BOND0_NAME
      addresses:
      - $CEPH_PUB_VLAN_IP/$CEPH_PUB_VLAN_PREFIX
    
  
    $BOND1_NAME.$EXT_FIP_VLAN_ID: #Float IP
      id: $EXT_FIP_VLAN_ID
      link: $BOND1_NAME
    
    $BOND1_NAME.$LBaaS_VLAN_ID: #LBaaS
      id: $LBaaS_VLAN_ID
      link: $BOND1_NAME

    $BOND1_NAME.$TROVE_VLAN_ID: #DBaaS
      id: $TROVE_VLAN_ID
      link: $BOND1_NAME

    $BOND1_NAME.$IRONIC_VLAN_ID: #Ironid
      id: $IRONIC_VLAN_ID
      link: $BOND1_NAME

EOT
}

set_compute(){
# Creates a backup of old netplan config
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bk_`date +%Y%m%d%H%M`
cat > /etc/netplan/00-installer-config.yaml <<EOT
network:
  bonds:
    $BOND0_NAME:
      interfaces:
      - $NET_1G_1
      - $NET_1G_2
      nameservers:
        addresses: [$DNS_SERVERS]
        search: []
      parameters:
        mode: balance-rr
        mii-monitor-interval: 100
    $BOND1_NAME:
      interfaces:
      - $NET_10G_1
      - $NET_10G_2
      parameters:
        mode: balance-rr
        mii-monitor-interval: 100
  ethernets:
    $NET_1G_1: {}
    $NET_1G_2: {}
    $NET_10G_1: {}
    $NET_10G_2: {}
  version: 2
  renderer: networkd
  vlans:
    $BOND0_NAME.$MGMT_VLAN_ID: #MGMT
      addresses:
      - $MGMT_VLAN_IP/$MGMT_VLAN_PREFIX
      gateway4: $MGMT_VLAN_Gateway
      id: $MGMT_VLAN_ID
      link: $BOND0_NAME
      nameservers:
        addresses: [$DNS_SERVERS]
        search: []

    $BOND0_NAME.$OCC_VLAN_ID: #OCC
      id: $OCC_VLAN_ID
      link: $BOND0_NAME
      addresses:
      - $OCC_VLAN_IP/$OCC_VLAN_PREFIX
      routes:
      - to: 0.0.0.0/0
        via: $OCC_VLAN_Gateway
        table: 101
      - to: $OCC_VLAN_Network
        scope: link
        from: $OCC_VLAN_IP
        table: 101
      routing-policy:
      - from: $OCC_VLAN_IP
        table: 101


    $BOND1_NAME.$OVERLAY_VLAN_ID: #Overlay
      addresses:
      - $OVERLAY_VLAN_IP/$OVERLAY_VLAN_PREFIX
      id: $OVERLAY_VLAN_ID
      link: $BOND1_NAME

    $BOND0_NAME.$CEPH_PUB_VLAN_ID: #Cephfront
      id: $CEPH_PUB_VLAN_ID
      link: $BOND0_NAME
      addresses:
      - $CEPH_PUB_VLAN_IP/$CEPH_PUB_VLAN_PREFIX
    
    $BOND1_NAME.$EXT_FIP_VLAN_ID: #Float
      id: $EXT_FIP_VLAN_ID
      link: $BOND1_NAME
    
    $BOND1_NAME.$LBaaS_VLAN_ID: #LBaaS
      id: $LBaaS_VLAN_ID
      link: $BOND0_NAME

    $BOND1_NAME.$TROVE_VLAN_ID: #DBaaS
      id: $TROVE_VLAN_ID
      link: $BOND1_NAME

    $BOND1_NAME.$IRONIC_VLAN_ID: #Ironid
      id: $IRONIC_VLAN_ID
      link: $BOND1_NAME
EOT
}



set_cephmon(){
# Creates a backup of old netplan config
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bk_`date +%Y%m%d%H%M`
cat > /etc/netplan/00-installer-config.yaml <<EOT
network:
  bonds:
    $BOND0_NAME:
      interfaces:
      - $NET_1G_1
      - $NET_1G_2
      nameservers:
        addresses: [$DNS_SERVERS]
        search: []
      parameters:
        mode: balance-rr
        mii-monitor-interval: 100
    $BOND1_NAME:
      interfaces:
      - $NET_10G_1
      - $NET_10G_2
      parameters:
        mode: balance-rr
        mii-monitor-interval: 100
  ethernets:
    $NET_1G_1: {}
    $NET_1G_2: {}
    $NET_10G_1: {}
    $NET_10G_2: {}
  version: 2
  renderer: networkd
  vlans:
    $BOND0_NAME.$MGMT_VLAN_ID: #MGMT
      addresses:
      - $MGMT_VLAN_IP/$MGMT_VLAN_PREFIX
      gateway4: $MGMT_VLAN_Gateway
      id: $MGMT_VLAN_ID
      link: $BOND0_NAME
      nameservers:
        addresses: [$DNS_SERVERS]
        search: []
    
    $BOND0_NAME.$OCC_VLAN_ID: #OCC
      id: $OCC_VLAN_ID
      link: $BOND0_NAME
      addresses:
      - $OCC_VLAN_IP/$OCC_VLAN_PREFIX
      routes:
      - to: 0.0.0.0/0
        via: $OCC_VLAN_Gateway
        table: 101
      - to: $OCC_VLAN_Network
        scope: link
        from: $OCC_VLAN_IP
        table: 101
      routing-policy:
      - from: $OCC_VLAN_IP
        table: 101


    $BOND1_NAME.$CEPH_PUB_VLAN_ID: #Cephfront
      id: $CEPH_PUB_VLAN_ID
      link: $BOND1_NAME
      addresses:
      - $CEPH_PUB_VLAN_IP/$CEPH_PUB_VLAN_PREFIX

EOT
}

set_cephosd(){
# Creates a backup of old netplan config
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bk_`date +%Y%m%d%H%M`
cat > /etc/netplan/00-installer-config.yaml <<EOT
network:
  bonds:
    $BOND0_NAME:
      interfaces:
      - $NET_1G_1
      - $NET_1G_2
      nameservers:
        addresses: [$DNS_SERVERS]
        search: []
      parameters:
        mode: balance-rr
        mii-monitor-interval: 100
    $BOND1_NAME:
      interfaces:
      - $NET_10G_1
      - $NET_10G_2
      parameters:
        mode: balance-rr
        mii-monitor-interval: 100
  ethernets:
    $NET_1G_1: {}
    $NET_1G_2: {}
    $NET_10G_1: {}
    $NET_10G_2: {}
  version: 2
  renderer: networkd
  vlans:

    $BOND0_NAME.$MGMT_VLAN_ID: #MGMT
      addresses:
      - $MGMT_VLAN_IP/$MGMT_VLAN_PREFIX
      gateway4: $MGMT_VLAN_Gateway
      id: $MGMT_VLAN_ID
      link: $BOND0_NAME
      nameservers:
        addresses: [$DNS_SERVERS]
        search: []

    $BOND0_NAME.$CEPH_PUB_VLAN_ID: #CephFront
      id: $CEPH_PUB_VLAN_ID
      link: $BOND0_NAME
      addresses:
      - $CEPH_PUB_VLAN_IP/$CEPH_PUB_VLAN_PREFIX

    $BOND1_NAME.$CEPH_PRV_VLAN_ID: #CephBackend
      id: $CEPH_PRV_VLAN_ID
      link: $BOND1_NAME
      addresses:
      - $CEPH_PRV_VLAN_IP/$CEPH_PRV_VLAN_PREFIX
EOT
}

set_runner(){
# Creates a backup of old netplan config
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bk_`date +%Y%m%d%H%M`
cat > /etc/netplan/00-installer-config.yaml <<EOT
network:
  ethernets:
    $VM_INT: {}
  version: 2
  renderer: networkd
  vlans:
    mgmt:
      id: $MGMT_VLAN_ID #MGMT
      link: $VM_INT
      addresses:
      - $MGMT_VLAN_IP/$MGMT_VLAN_PREFIX
      routes:
      - to: 0.0.0.0/0
        via: $MGMT_VLAN_Gateway
        table: 100
      - to: $MGMT_VLAN_Network
        scope: link
        from: $MGMT_VLAN_IP
        table: 100
        #git route must be here !!!!!
      routing-policy:
      - from: $MGMT_VLAN_IP
        table: 100

    occintvip: #OCC
      id: $OCC_VLAN_ID
      link: $VM_INT
      addresses:
      - $OCC_VLAN_IP/$OCC_VLAN_PREFIX   
      routes:
      - to: 0.0.0.0/0
        via: $OCC_VLAN_Gateway
        table: 101
      - to: $OCC_VLAN_Network
        scope: link
        from: $OCC_VLAN_IP
        table: 101
      routing-policy:
      - from: $OCC_VLAN_IP
        table: 101

    cephfront: #CephFront
      id: $CEPH_PUB_VLAN_ID
      link: $VM_INT
      addresses:
      - $CEPH_PUB_VLAN_IP/$CEPH_PUB_VLAN_PREFIX
    
    publicedgevip: #pubedgevip 4
      id: $EXT_EDG_VLAN_ID
      link: $VM_INT
      addresses:
      - $EXT_EDG_VLAN_IP/$EXT_EDG_VLAN_PREFIX
      gateway4: $EXT_EDG_VLAN_Gateway
      nameservers:
        addresses: [$DNS_SERVERS]
EOT
}

set_ha(){
# Creates a backup of old netplan config
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bk_`date +%Y%m%d%H%M`
cat > /etc/netplan/00-installer-config.yaml <<EOT
network:
  ethernets:
    $VM_INT: {}
  version: 2
  renderer: networkd
  vlans:
    mgmt:
      id: $MGMT_VLAN_ID #MGMT
      link: $VM_INT
      addresses:
      - $MGMT_VLAN_IP/$MGMT_VLAN_PREFIX
      routes:
      - to: 0.0.0.0/0
        via: $MGMT_VLAN_Gateway
        table: 100
      - to: $MGMT_VLAN_Network
        scope: link
        from: $MGMT_VLAN_IP
        table: 100
        #git route must be here !!!!!
      routing-policy:
      - from: $MGMT_VLAN_IP
        table: 100



    occintvip: #OCC
      id: $OCC_VLAN_ID
      link: $VM_INT
      addresses:
      - $OCC_VLAN_IP/$OCC_VLAN_PREFIX   
      routes:
      - to: 0.0.0.0/0
        via: $OCC_VLAN_Gateway
        table: 101
      - to: $OCC_VLAN_Network
        scope: link
        from: $OCC_VLAN_IP
        table: 101
      routing-policy:
      - from: $OCC_VLAN_IP
        table: 101

    cephfront: #CephFront
      id: $CEPH_PUB_VLAN_ID
      link: $VM_INT
      addresses:
      - $CEPH_PUB_VLAN_IP/$CEPH_PUB_VLAN_PREFIX
    
    publicedgevip: #Pubedgevip
      id: $EXT_EDG_VLAN_ID
      link: $VM_INT
      addresses:
      - $EXT_EDG_VLAN_IP/$EXT_EDG_VLAN_PREFIX
      gateway4: $EXT_EDG_VLAN_Gateway
      nameservers:
        addresses: [$DNS_SERVERS]
EOT
}

set_telemetry(){
# Creates a backup of old netplan config
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bk_`date +%Y%m%d%H%M`
cat > /etc/netplan/00-installer-config.yaml <<EOT
network:
  ethernets:
    $VM_INT: {}
  version: 2
  renderer: networkd
  vlans:
    mgmt:
      id: $MGMT_VLAN_ID #mgmt 21
      link: $VM_INT
      addresses:
      - $MGMT_VLAN_IP/$MGMT_VLAN_PREFIX
      gateway4: $MGMT_VLAN_Gateway
      nameservers:
        addresses: [$DNS_SERVERS]
        search: []

    occintvip: #occ 96
      id: $OCC_VLAN_ID
      link: $VM_INT
      addresses:
      - $OCC_VLAN_IP/$OCC_VLAN_PREFIX   
      routes:
      - to: 0.0.0.0/0
        via: $OCC_VLAN_Gateway
        table: 101
      - to: $OCC_VLAN_Network
        scope: link
        from: $OCC_VLAN_IP
        table: 101
      routing-policy:
      - from: $OCC_VLAN_IP
        table: 101

    cephfront: #CephFront
      id: $CEPH_PUB_VLAN_ID
      link: $VM_INT
      addresses:
      - $CEPH_PUB_VLAN_IP/$CEPH_PUB_VLAN_PREFIX

    lbaas: #LBaaS
      id: $LBaaS_VLAN_ID
      link: $VM_INT

    dbaas: #DBaaS
      id: $TROVE_VLAN_ID
      link: $VM_INT

    ironic: #Ironid
      id: $IRONIC_VLAN_ID
      link: $VM_INT
EOT
}

set_repo(){
# Creates a backup of old netplan config
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bk_`date +%Y%m%d%H%M`
cat > /etc/netplan/00-installer-config.yaml <<EOT
network:
  ethernets:
    $VM_INT: {}
  version: 2
  renderer: networkd
  vlans:
    mgmt:
      id: $MGMT_VLAN_ID #MGMT
      link: $VM_INT
      addresses:
      - $MGMT_VLAN_IP/$MGMT_VLAN_PREFIX
      gateway4: $MGMT_VLAN_Gateway
      nameservers:
        addresses: [$DNS_SERVERS]
        search: []

    occintvip: #OCC
      id: $OCC_VLAN_ID
      link: $VM_INT
      addresses:
      - $OCC_VLAN_IP/$OCC_VLAN_PREFIX   
      routes:
      - to: 0.0.0.0/0
        via: $OCC_VLAN_Gateway
        table: 101
      - to: $OCC_VLAN_Network
        scope: link
        from: $OCC_VLAN_IP
        table: 101
      routing-policy:
      - from: $OCC_VLAN_IP
        table: 101
EOT
}

get_phy_int(){

#   read -p "Management Temporary Interface name: " MGMT_TEMP_VLAN_Interface

    echo -e " \e[30;48;5;56m \e[1m \e[38;5;15mNetwork Interfaces Name:\e[0m"
    ip -o link show | awk '{ if($8=="state") {print $2, $9, $(NF-2)} else {print $2, $11, $(NF-2)}}' |  egrep -v 'lo|vir*|bond*'

    read -p "Bond0 NIC1: " NET_1G_1
    read -p "Bond0 NIC2: " NET_1G_2

    NET_1G_1="${NET_1G_1:-ens160}"
    NET_1G_2="${NET_1G_2:-ens256}"

    BOND0_NAME=bond0
    #read -e -i "$BOND0_NAME" -p "1G Bond Name: " input
    #BOND0_NAME="${input:-$BOND0_NAME}"

    read -p "Bond1 NIC1: " NET_10G_1
    read -p "Bond1 NIC2: " NET_10G_2

    NET_10G_1="${NET_10G_1:-ens192}"
    NET_10G_2="${NET_10G_2:-ens224}"

    BOND1_NAME=bond1
}

get_vm_int(){
ip -o link show | awk '{ if($8=="state") {print $2, $9, $(NF-2)} else {print $2, $11, $(NF-2)}}' |  egrep -v 'lo|vir*|bond*'
read -p "Enter Interface Name of the Server: " VM_INT
VM_INT="${VM_INT:-ens160}"
}

apply_netplan(){

  netplan apply
  if [    "$?" = "0"     ];then
    echo -e "\033[0;32m\"NETPLAN APPLY\" was Successful \033[0m \n"
    echo -e "\033[0;33mServer will be reboot in 10 sec\033[0m"
    echo -e "\033[5;33mRebooting... \033[0m"

    sleep 10
    reboot -f
  else
    echo -e "\033[0;31mNETPLAN APPLY has Failed. \033[0m"
  fi
    
    
}


######### Check Root access ##########
if [[ $EUID -ne 0 ]]; then
    echo -e "\033[0;31mThis Script Must Be Run As Root! \033[0m"
    exit 1
fi

read -p "Please Enter Comma-Separated List Of DNS Servers IP(s),Example And Default: '185.174.251.2,185.174.251.22,185.120.162.10' :" DNS_SERVERS
DNS_SERVERS="${DNS_SERVERS:-185.174.251.2,185.174.251.22,185.120.162.10}"

echo -e "Select desired number of node type below (just type the number):\n"
select option in 'Controller_Nodes' 'Compute_Nodes' 'Ceph_MON_Nodes' 'Ceph_OSD_Nodes' 'Runner_Nodes' 'HA-Proxty Nodes' 'Telemetry Nodes' 'Repo Tester Exporter Monitoring Status' 'Exit'
do
    if [ $REPLY == '1' ]; then

        echo -e "\nController node selected\n"
        get_phy_int
        get_mgmt_info
        get_occ_info
        get_overlay_info
        get_cephfront_info
        get_pubprovider_info
        get_lbaas_info
        get_dbaas_info
        get_ironic_info 
        set_controller

        apply_netplan

    elif [ $REPLY == '2' ]; then

        echo -e "\nCompute node selected\n"
        get_phy_int

        get_mgmt_info
        get_occ_info
        get_overlay_info
        get_cephfront_info
        get_pubprovider_info
        get_lbaas_info
        get_dbaas_info
        get_ironic_info
        set_compute

        apply_netplan

    elif [ $REPLY == '3' ]; then

        echo -e "\nCeph_MON node selected\n"
        get_phy_int
        get_mgmt_info
        get_occ_info
        get_cephfront_info
        set_cephmon

        apply_netplan

    elif [ $REPLY == '4' ]; then

        echo -e "\nCeph_OSD node selected\n"
        get_phy_int
        get_mgmt_info
        get_cephfront_info
        get_cephbackend_info
        set_cephosd

        apply_netplan


    elif [ $REPLY == '5' ]; then

        echo -e "\nRunner node selected\n"
        get_vm_int
        get_mgmt_info
        get_occ_info
        get_cephfront_info
        get_pubedgevip_info
        set_runner

        apply_netplan


    elif [ $REPLY == '6' ]; then

        echo -e "HA-Proxy node selected\n"
        get_vm_int
        get_mgmt_info
        get_occ_info
        get_cephfront_info
        get_pubedgevip_info
        set_ha

        apply_netplan

    elif [ $REPLY == '7' ]; then

        echo -e "\nTelemetry node selected\n"
        get_vm_int
        get_mgmt_info
        get_occ_info
        get_cephfront_info
        get_lbaas_info
        get_dbaas_info
        get_ironic_info
        set_telemetry

        apply_netplan
    
    elif [ $REPLY == '8' ]; then

        echo -e "\nRepo Tester Exporter Monitoring Status node selected\n"
        get_vm_int
        get_mgmt_info
        get_occ_info
        set_repo
        
        apply_netplan

    elif [ $REPLY == '9' ]; then

        exit 0
    
    else
        echo "Invalid Input\n"
        echo "Run the Network Script Again..."
        return
        
    fi
done

#!/usr/bin/env bash
#set -e

usage="$(basename "$0") [-H] [-h]
Connect development machine with remote nodes to allow initial communication (i.e. riaps_fab). 
Use -H to specify a comma separated list of remote nodes to connect.
Arguments are:
    -h show this help text
    -H comma separate list of remote nodes using hostname or IP addresses (optional)"

use_hostfile="true"

while getopts hH option
do
  case "$option" in 
    h) echo "$usage"; exit;;
    H) echo "Remote Nodes Provided"; use_hostfile="false"; remote_nodes=$2;;
  esac
done

# Determine controller hostname and IP addresses
controller=$(hostname).local
echo "Controller hostname: $controller"
ctrl_ips=$(hostname -I)
echo "Controller IPs: $ctrl_ips"
IFS=' ' read -ra ctrl_ips_array <<< "$ctrl_ips"

# uses the system "/etc/riaps/riaps-hosts.conf" file to determine remote nodes
if [[ $use_hostfile == "true" ]]; then
  echo ">>>>> Using /etc/riaps/riaps-hosts.conf file to determine remote nodes <<<<<"
  # check if /etc/riaps/riaps-hosts.conf exists
  if [ -f "/etc/riaps/riaps-hosts.conf" ]; then
    while IFS= read -r line; do
      if [[ "$line" =~ ^[[:space:]]*nodes[[:space:]]*=[[:space:]]*\[\"(.*)\"\] ]]; then
        # Remove unnecessary characters and split into elements
        line="${line//nodes = /}"           # Remove 'nodes = '
        line="${line//[\[\]\"]/}"           # Remove '[', ']', and '"'
        IFS=',' read -ra node_array <<< "$line"  # Split into array elements

        # Copy the development VM public key to the authorized keys of the remote nodes
        connects_succeeded="true"
        for node in "${node_array[@]}"; do
          # Only perform on remote nodes, so skip the controller
          if [[ !$(echo ${ctrl_ips_array[@]} | fgrep -w $node) ]] && [[ $node != $controller ]]; then
            echo ">>>>> Setting up remote node: $node (you must enter a password for each remote node) <<<<<"
            scp ~/.ssh/id_rsa.pub riaps@$node:/home/riaps/.ssh/authorized_keys
            # Check that scp command succeeded
            if [ $? -eq 0 ]; then 
              echo ">>>>> Connection between $node and controller has succeeded <<<<<" 
            else 
              echo ">>>>> Connection failed between $node and controller <<<<<"
              connects_succeeded="false" 
            fi
          fi
        done
      fi
    done < "/etc/riaps/riaps-hosts.conf"
  else
    echo ">>>>> RIAPS is not install (riaps-pycom-dev), please install this package before establishing connections with remote nodes <<<<<"
    exit 1
  fi
  if [[ $connects_succeeded = "true" ]]; then
    riaps_fab sys.check
    echo ">>>>> If a response exists from all remote nodes, then remote node are now successfully communicating <<<<<" 
  else
    echo ">>>>> Check /etc/riaps/riaps-hosts.conf file for correct hostnames, also check nodes that failed connections are running and network connected <<<<<"
    echo ">>>>> Remote node connection failed <<<<<"
  fi
# uses the specified remote node list (assumes user did not include the controller)
else
  echo "Remote Nodes: $remote_nodes"
  IFS=',' read -ra remote_nodes_array <<< "$remote_nodes"
  connects_succeeded="true"
  for node in "${remote_nodes_array[@]}"; do
    echo ">>>>> Setting up remote node: $node (you must enter a password for each remote node) <<<<<"
    scp ~/.ssh/id_rsa.pub riaps@$node:/home/riaps/.ssh/authorized_keys
    # Check that scp command succeeded
    if [ $? -eq 0 ]; then 
      echo ">>>>> Connection between $node and controller has succeeded <<<<<" 
    else 
      echo ">>>>> Connection failed between $node and controller <<<<<"
      connects_succeeded="false"  
    fi
  done
  if [[ $connects_succeeded = "true" ]]; then
    riaps_fab sys.check -H $remote_nodes
    echo ">>>>> If a response exists from all remote nodes, then remote nodes are now successfully communicating <<<<<" 
  else
    echo ">>>>> Check if the remote nodes with failed connections are running and network connected <<<<<"
    echo ">>>>> Remote node connection failed <<<<<"
  fi
fi



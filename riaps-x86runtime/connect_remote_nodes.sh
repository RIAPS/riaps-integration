#!/usr/bin/env bash
#set -e

usage="$(basename "$0") [-H] [-h]
Connect development machine with remote nodes to allow initial communication (i.e. riaps_fab). 
Use -H to specify a comma separated list of remote nodes to connect.
Arguments are:
    -h show this help text
    -H comma separate list of remote nodes using hostname or IP addresses (optional)"

use_hostfile="true"
hostfilename="/etc/riaps/riaps-hosts.conf"

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

# Using "/etc/riaps/riaps-hosts.conf" file to either determine remote nodes or to update the file given a list of hostnames
# So, check that file exists, if not ask user to make sure "riaps-pycom-dev" is installed.
if [ -f "$hostfilename" ]; then
  # Determine what nodes are listed already in the riaps-hosts.conf file
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*nodes[[:space:]]*=[[:space:]]*\[\"*(.*)\"*\] ]]; then
      # Save node line for use when adding new nodes
      node_line=$line
      # Remove unnecessary characters and split into elements
      line="${line//nodes = /}"           # Remove 'nodes = '
      line="${line//[\[\]\"]/}"           # Remove '[', ']', and '"'
      IFS=',' read -ra node_array <<< "$line"  # Split into array elements
    fi
  done < $hostfilename

  # uses the system "/etc/riaps/riaps-hosts.conf" file to determine remote nodes
  if [[ $use_hostfile == "true" ]]; then
    if [[ ${node_array[@]} ]]; then
      echo ">>>>> Using /etc/riaps/riaps-hosts.conf file to determine remote nodes <<<<<"
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
      if [[ $connects_succeeded = "true" ]]; then
        riaps_fab sys.check
        echo ">>>>> If a response exists from all remote nodes, then remote node are now successfully communicating <<<<<" 
      else
        echo ">>>>> Check /etc/riaps/riaps-hosts.conf file for correct hostnames, also check nodes that failed connections are running and network connected <<<<<"
        echo ">>>>> Remote node connection failed <<<<<"
      fi
    else
      echo ">>>>> There are no hosts listed in the /etc/riaps/riaps-hosts.conf file, please add desired hostnames to this file and try again <<<<<"
      echo ">>>>> Remote node connection failed <<<<<"
    fi

  # uses the specified remote node list (assumes user did not include the controller)
  else
    echo "Remote Nodes: $remote_nodes"
    IFS=',' read -ra remote_nodes_array <<< "$remote_nodes"
    connects_succeeded="true"
    new_node_line=$node_line
    for node in "${remote_nodes_array[@]}"; do
      echo ">>>>> Setting up remote node: $node (you must enter a password for each remote node) <<<<<"
      scp ~/.ssh/id_rsa.pub riaps@$node:/home/riaps/.ssh/authorized_keys
      # Check that scp command succeeded
      if [ $? -eq 0 ]; then 
        echo ">>>>> Connection between $node and controller has succeeded <<<<<" 
        # Add new nodes to /etc/riaps/riaps-hosts.conf file as a "node", do nothing if it already exists

        if [[ "$node_line" != *"\"$node\""* ]]; then
          new_node_line=$(echo "$new_node_line" | sed "s/[]]/,\"$node\"]/")
        fi
      else 
        echo ">>>>> Connection failed between $node and controller <<<<<"
        connects_succeeded="false"  
      fi
    done
    # If some or all nodes connected, add them to the riaps-hosts.conf file
    if [[ "$new_node_line" != "$node_line" ]]; then
      # Make remove any leading comma from node line if the list was originally empty
      if [[ "$new_node_line" == *"[,"* ]]; then
        new_node_line=$(echo "$new_node_line" | sed 's/\[,/\[/g')
      fi
      sudo sed -i '/^nodes =/c\'"$new_node_line" $hostfilename
    fi
    if [[ $connects_succeeded = "true" ]]; then
      riaps_fab sys.check -H $remote_nodes
      echo ">>>>> If a response exists from all remote nodes, then remote nodes are now successfully communicating <<<<<" 
    else
      echo ">>>>> Check if the remote nodes with failed connections are running and network connected <<<<<"
      echo ">>>>> Remote node connection failed <<<<<"
    fi
  fi

# Missing /etc/riaps/riaps-hosts.conf file
else
  echo ">>>>> RIAPS is not install (riaps-pycom-dev), please install this package before establishing connections with remote nodes <<<<<"
  exit 1
fi

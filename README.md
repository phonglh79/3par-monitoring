# ABOUT
3par monitoring is a shell based client to obtain and gather 3par StoreServ storage array statistics by using HPE 3PAR OS Command Line Interface and ssh. This consists of a daemon and a command. The daemon keeps connections to storage arrays open by using OpenSSH multiplexing to ensure performance.

# COMPATIBILITY

### Linux
This was tested on RHEL7/CentOS7 however it should work correctly on other distros that use systemd and keeps similar FHS and directories layout.

### HPE 3par storage array
This is compatible with StoreServe family and OS release 3.2.2.

# INSTALL
A user on storage arrays side is required. Also, that user has to be able to access storage arrays via SSH by using keys in RSA or DSA formats. Please refer to HPE 3Par StoreServe manuals for that.

This requires root privileges.
```
wget https://raw.githubusercontent.com/robertmholyst/3par-monitoring/master/3par-install.sh
chmod +x 3par-install.sh
./3par-install.sh
```

Edit /etc/3par/3par.cfg once all is installed.

ARRAY  - IP/FQDN which points storage array's management host/node.  
USER   - User defined on the storage array side, a 'browse' role is required to be granted to the user.  
KEY    - A path to ssh identity file required to access storage array. The pub key must be configured on the array side.  
SOCKET - A path to ssh multiplexer socket. A shared memory device is recommended to be used.  

ARRAY[0]="\<IP/FQDN\>"  
USER[0]="\<user\>"  
KEY[0]="\<path to identity file\>"  
SOCKET[0]="\<path to socket file\>"

For instance
```
ARRAY[0]="array1.example.com"
USER[0]="3par"
KEY[0]="/root/.ssh/3par"
SOCKET[0]="/dev/shm/3par_1.socket"

ARRAY[1]="array2.example.com"
USER[1]="3par"
KEY[1]="/root/.ssh/3par"
SOCKET[1]="/dev/shm/3par_2.socket"
```

Ensure the daemon is up and running.
```
systemctl start 3par.service
systemctl enable 3par.service
```

# GETTING STARTED
Perform a simple query for all configured storage arrays, for instance
```
3par sys_serial
3par -a 1 sys_serial
```

# PARAMETERS
### NAME
3par - obtain 3par StoreServ storage array statistics

### SYNOPSIS
**3par** [**-a** _array_] **parameter** [_arguments_]

### DESCRIPTION
3par monitoring is a shell based client to obtain and gather 3par StoreServ storage array statistics by using CLI and ssh.

### OPTIONS
**-a** _array_  
Storage array number in config file. If not specified 0 will be used.

### PARAMETERS

**sys_serial**  
Storage array serial number

**sys_id**  
Storage array ID

**sys_node_number**  
A total number of nodes

**sys_node_master**  
A node number which acts as a master

**sys_node_online**  
A list of all nodes that are online

**sys_node_cluster**  
A list of all nodes that are clustered

**capacity_total**  
Total storage array capacity in MiB

**capacity_allocated_total**  
Total allocated space in MiB

**capacity_allocated_volumes**  
Total allocated volumes space in MiB

**capacity_allocated_system**  
Total allocated system space in MiB

**capacity_free**  
Total free space in MiB

**capacity_unavailable**  
Total unavailable space in MiB

**capacity_failed**  
Total failed capacity in MiB

**node_state** _node_  
Node state. Node number is required

**node_temp_ambient** _node_  
A node ambient temperature in degrees of C. Node number is required

**node_temp_midplane** _node_  
A node midplane temperature in degrees of C. Node number is required

**ps_state** _node_ _ps_  
A power supply state. Node and PS numbers are required

**ps_ac_state** _node_ _ps_  
A power supply AC state. Node and PS numbers are required

**ps_dc_state** _node_ _ps_  
A power supply DC state. Node and PS numbers are required

**ps_bat_state** _node_ _ps_  
A power supply battery state. Node and PS numbers are required

**ps_fan_state** _node_ _ps_  
A power supply fan state. Node and PS numbers are required

**ps_charge_level** _node_ _ps_  
A power supply battery charge level in %. Node and PS numbers are required

### EXAMPLES

Obtaining serial number for storage array which is configured as ARRAY[0]  
```
3par sys_serial
```

Obtaining serial number for storage array which is configured as ARRAY[1]  
```
3par -a 1 sys_serial
```

Obtaining node 2 ambient temperature for storage array ARRAY[1]  
```
3par -a 1 node_temp_ambient 2
```

# Licence
3par monitoring

Copyright (C) 2017 Robert M Holyst

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

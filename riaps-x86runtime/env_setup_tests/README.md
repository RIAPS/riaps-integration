This folder contains a generic application to test that the development environment is setup and able to talk with the configured BBBs.  If you do not see the expected results, please send an email to riap@list.isis.vanderbilt.edu describing the situation and any include any output log information.

## First Test VM with application on local node (VM)
1. Open 3 terminal windows

   a. ``` rpyc_registry ```
   
   b. ``` riaps_ctrl ```
   
   c. ``` riaps_deplo ```

2. With the 'riaps_ctrl' command, the RIAPS control GUI will come up.  You should see the IP address of your VM added as a node.
    
    MM TODO:  TBD - add control GUI image
    
3. In the control GUI, select the **WeatherMonitor** located under **~/env_setup_tests** folder using the **wmonitor_vm_only.depl** file.  Then **Load** (button on the right) and click on the loaded WeatherMonitor application to **Launch** it.
    
    MM TODO:  add this copy to the bootstrap code
    
4. When you launch this application, you should see the following output on the RIAPS control GUI and from the different windows.
   
   MM TODO:  add control GUI image
```
   riaps@riapsvbox719:~$ rpyc_registry.py 
   DEBUG:REGSRV/UDP/18811:server started on 0.0.0.0:18811
   DEBUG:REGSRV/UDP/18811:registering 192.168.1.101:8888 as RIAPSCONTROL
   DEBUG:REGSRV/UDP/18811:querying for 'RIAPSCONTROL'
   DEBUG:REGSRV/UDP/18811:replying with [('192.168.1.101', 8888)]
   DEBUG:REGSRV/UDP/18811:querying for 'RIAPSCONTROL'
   DEBUG:REGSRV/UDP/18811:replying with [('192.168.1.101', 8888)]
   DEBUG:REGSRV/UDP/18811:registering 192.168.1.101:8888 as RIAPSCONTROL
   DEBUG:REGSRV/UDP/18811:registering 192.168.1.101:8888 as RIAPSCONTROL
   
   
   riaps@riapsvbox719:~$ riaps_ctrl 
   2436:M 20 Jul 11:01:25.336 * Increased maximum number of open files to 10032 (it was originally set to 1024).
                   _._                                                  
              _.-``__ ''-._                                             
         _.-``    `.  `_.  ''-._           Redis 3.2.5 (00000000/0) 64 bit
     .-`` .-```.  ```\/    _.,_ ''-._                                   
    (    '      ,       .-`  | `,    )     Running in standalone mode
    |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379 
    |    `-._   `._    /     _.-'    |     PID: 2436
     `-._    `-._  `-./  _.-'    _.-'                                   
    |`-._`-._    `-.__.-'    _.-'_.-'|                                  
    |    `-._`-._        _.-'_.-'    |           http://redis.io        
     `-._    `-._`-.__.-'_.-'    _.-'                                   
    |`-._`-._    `-.__.-'    _.-'_.-'|                                  
    |    `-._`-._        _.-'_.-'    |                                  
     `-._    `-._`-.__.-'_.-'    _.-'                                   
         `-._    `-.__.-'    _.-'                                       
             `-._        _.-'                                           
                 `-.__.-'                                               

   2436:M 20 Jul 11:01:25.338 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set
   to the lower value of 128.
   2436:M 20 Jul 11:01:25.338 # Server started, Redis version 3.2.5
   2436:M 20 Jul 11:01:25.338 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this    issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this
   to take effect.
   2436:M 20 Jul 11:01:25.338 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency
   and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as
   root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
   2436:M 20 Jul 11:01:25.338 * The server is now ready to accept connections on port 6379
   WARNING:2017-07-20 13:17:00,291:riaps.ctrl.ctrl_tab:added key /usr/local/riaps/keys/id_rsa.key
   WARNING:2017-07-20 13:17:00,292:riaps.ctrl.ctrl_tab:added key /home/riaps/.ssh/id_rsa.key
   WARNING:2017-07-20 13:17:00,292:riaps.ctrl.ctrl_tab:Trying user riaps ssh-agent key 7feb12cc1603be715fb8f95d43457627
   WARNING:2017-07-20 13:17:00,339:riaps.ctrl.ctrl_tab:Trying user riaps ssh-agent key 48a8cab1f25160567dc00138863b032a


   riaps@riapsvbox719:~$ riaps_deplo
   Starting RIAPS DISCOVERY SERVICE v0.8.0
    * 192.168.1.101
    * 080027557bad
   Start DHT node.
   DHT node started.
   Stored ips: 10.0.2.15; 
   INFO:13:17:00,587:TempSensor:(PID 2580, IP 192.168.1.101)-starting TempSensor, Thu Jul 20 13:17:00 2017
   INFO:13:17:00,587:TempSensor:Initial temp:65, Thu Jul 20 13:17:00 2017
   Register actor with PID - 2580 : /WeatherMonitor/WeatherIndicator/
   Register service: /WeatherMonitor/TempData/pub
   INFO:13:17:00,618:TempMonitor:(PID 2582, IP 192.168.1.101)-starting TempMonitor, Thu Jul 20 13:17:00 2017
   Register actor with PID - 2582 : /WeatherMonitor/WeatherReceiver/
   Get: /WeatherMonitor/TempData/pub
   Get results sent to discovery service
   Get results were sent to the client: /WeatherMonitor/WeatherReceiver/
   Changes sent to discovery service: /WeatherMonitor/TempData/pub
   Search for registered actor: /WeatherMonitor/WeatherReceiver/
   Port update sent to the client: /WeatherMonitor/WeatherReceiver/
   INFO:13:17:05,592:TempSensor:on_clock(): Temperature - 66, PID 2580, IP 192.168.1.101, Thu Jul 20 13:17:05 2017
   INFO:13:17:05,592:TempMonitor:on_tempupdate(): Temperature:66, PID Thu Jul 20 13:17:05 2017, from 192.168.1.101, Timestamp:Thu Jul 20    13:17:05 2017
   INFO:13:17:10,592:TempSensor:on_clock(): Temperature - 67, PID 2580, IP 192.168.1.101, Thu Jul 20 13:17:10 2017
   INFO:13:17:10,593:TempMonitor:on_tempupdate(): Temperature:67, PID Thu Jul 20 13:17:10 2017, from 192.168.1.101, Timestamp:Thu Jul 20    13:17:10 2017

```
       
## Second Test a Single BBB Talks with the VM
1.  SSH into the BBB, where xxxx refers to the hostname that you see when you log into the BBB.  If you do not know the hostname yet, you can use the IP address instead (xxx.xxx.xxx.xxx).

```       
          ssh riaps@bbb-xxxx.local 
```
    
2.  On the VM, open 2 terminal windows
   
   a. ``` rpyc_registry ```
   
   b. ``` riaps_ctrl ```
   
3.  On the BBB, run ``` riaps_deplo ```

4.  With the 'riaps_ctrl' command, the RIAPS control GUI will come up.  You should see the IP address of your BBB added as a node.
        
5.  Edit the **~/env_setup_tests/WeatherMonitor/wmonitor_1_bbb.depl** file to point to your BBB using either the hostname or the IP address.

6.  In the control GUI, select the **WeatherMonitor** located under **~/env_setup_tests** folder using the **wmonitor_1_bbb.depl** file.

7.  When you launch this application, you should see the following output on the RIAPS control GUI and on the BBB.

      MM TODO:  add control GUI image
      
      ```
      Starting RIAPS DISCOVERY SERVICE v0.8.0
      * 192.168.1.102
      * 6cecebb9f652
      Start DHT node.
      DHT node started.
      Stored ips: 192.168.1.102; 
      INFO:18:30:44,470:TempSensor:(PID 21380, IP 192.168.1.102)-starting TempSensor, Thu Jul 20 18:30:44 2017
      INFO:18:30:44,483:TempSensor:Initial temp:65, Thu Jul 20 18:30:44 2017
      Register actor with PID - 21380 : /WeatherMonitor/WeatherIndicator/
      Register service: /WeatherMonitor/TempData/pub
      INFO:18:30:44,621:TempMonitor:(PID 21381, IP 192.168.1.102)-starting TempMonitor, Thu Jul 20 18:30:44 2017
      Register actor with PID - 21381 : /WeatherMonitor/WeatherReceiver/
      Get: /WeatherMonitor/TempData/pub
      Get results sent to discovery service
      Get results were sent to the client: /WeatherMonitor/WeatherReceiver/
      Changes sent to discovery service: /WeatherMonitor/TempData/pub
      Search for registered actor: /WeatherMonitor/WeatherReceiver/
      Port update sent to the client: /WeatherMonitor/WeatherReceiver/
      INFO:18:30:49,566:TempSensor:on_clock(): Temperature - 66, PID 21380, IP 192.168.1.102, Thu Jul 20 18:30:49 2017
      INFO:18:30:49,570:TempMonitor:on_tempupdate(): Temperature:66, PID Thu Jul 20 18:30:49 2017, from 192.168.1.102, Timestamp:Thu Jul       20 18:30:49 2017
      INFO:18:30:54,567:TempSensor:on_clock(): Temperature - 67, PID 21380, IP 192.168.1.102, Thu Jul 20 18:30:54 2017
      INFO:18:30:54,571:TempMonitor:on_tempupdate(): Temperature:67, PID Thu Jul 20 18:30:54 2017, from 192.168.1.102, Timestamp:Thu Jul       20 18:30:54 2017
       
## Third Test that Multiple BBBs can Talk with the VM
1.  SSH into the BBBs, where xxxx refers to the hostname that you see when you log into the BBBs.
  
      ``` ssh riaps@bbb-xxxx.local ```
    
2.  On the VM, open 2 terminal windows
   
   a. ``` rpyc_registry ```
   
   b. ``` riaps_ctrl ```
   
3.  On the BBB, run ``` riaps_deplo ```

4.  With the 'riaps_ctrl' command, the RIAPS control GUI will come up.  You should see the IP address of your BBB added as a node.
        
5.  The **~/env_setup_tests/WeatherMonitor/wmonitor_manny_bbb.depl** file is setup to have a single BBB be the WeatherReceiver and then all BBBs will report a temperature number.  Edit this file to point the WeatherReceiver to one of your BBBs using either the hostname or the IP address.

6.  In the control GUI, select the **WeatherMonitor** located under **~/env_setup_tests** folder using the **wmonitor_many_bbb.depl** file.

7.  When you launch this application, you should see the following output on the BBB.
       
       MM TODO:  TBD - add image or text
   


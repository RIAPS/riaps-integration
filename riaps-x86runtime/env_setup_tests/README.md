This folder contains a generic application to test that the development environment is setup and able to talk with the configured BBBs.  If you do not see the expected results, please send an email to riap@list.isis.vanderbilt.edu describing the situation and any include any output log information.

## First Test VM with application on local node (VM)
1. Open 3 terminal windows
   a. ``` rpyc_registry ```
   b. ``` riaps_ctrl ```
   c. ``` riaps_deplo ```

2. With the 'riaps_ctrl' command, the RIAPS control GUI will come up.  You should see the IP address of your VM added as a node.
    
    MM TODO:  TBD - add image
    
3. In the control GUI, select the **WeatherMonitor** located under **~/env_setup_tests** folder using the **wmonitor_vm_only.depl** file.
    
    MM TODO:  add this copy to the bootstrap code
    
4. When you launch this application, you should see the following output from the different windows.
   a. ``` rpyc_registry ```
   
       MM TODO:  TBD - add image or text
       
   b. ``` riaps_ctrl ```
   
       MM TODO:  TBD - add image or text
       
   c. ``` riaps_deplo ```
   
       MM TODO:  TBD - add image or text
       
## Second Test a Single BBB Talks with the VM
1.  SSH into the BBB, where xxxx refers to the hostname that you see when you log into the BBB.  If you do not know the hostname yet, you can use the IP address instead (xxx.xxx.xxx.xxx).
    ``` ssh riaps@bbb-xxxx.local ```
2.  On the VM, open 2 terminal windows
   a. ``` rpyc_registry ```
   b. ``` riaps_ctrl ```
3.  On the BBB, run ``` riaps_deplo ```
4.  With the 'riaps_ctrl' command, the RIAPS control GUI will come up.  You should see the IP address of your BBB added as a node.
        
      MM TODO:  TBD - add image or text
        
5.  Edit the **~/env_setup_tests/WeatherMonitor/wmonitor_1_bbb.depl** file to point to your BBB using either the hostname or the IP address.
6.  In the control GUI, select the **WeatherMonitor** located under **~/env_setup_tests** folder using the **wmonitor_1_bbb.depl** file.
7.  When you launch this application, you should see the following output on the BBB.
      
      MM TODO:  TBD - add image or text
      
       
## Third Test that Multiple BBBs can Talk with the VM
1.  SSH into the BBBs, where xxxx refers to the hostname that you see when you log into the BBBs.
    ``` ssh riaps@bbb-xxxx.local ```
2.  On the VM, open 2 terminal windows
   a. ``` rpyc_registry ```
   b. ``` riaps_ctrl ```
3.  On the BBB, run ``` riaps_deplo ```
4.  With the 'riaps_ctrl' command, the RIAPS control GUI will come up.  You should see the IP address of your BBB added as a node.
        
        MM TODO:  TBD - add image or text
        
5.  The **~/env_setup_tests/WeatherMonitor/wmonitor_manny_bbb.depl** file is setup to have a single BBB be the WeatherReceiver and then all BBBs will report a temperature number.  Edit this file to point the WeatherReceiver to one of your BBBs using either the hostname or the IP address.
6.  In the control GUI, select the **WeatherMonitor** located under **~/env_setup_tests** folder using the **wmonitor_many_bbb.depl** file.
7.  When you launch this application, you should see the following output on the BBB.
       
       MM TODO:  TBD - add image or text
   


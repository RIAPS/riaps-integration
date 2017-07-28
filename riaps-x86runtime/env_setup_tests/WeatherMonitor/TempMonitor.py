'''
Created on Jan 25, 2017

@author: metelko
'''
# import riaps
from riaps.run.comp import Component
from riaps.utils.ifaces import getNetworkInterfaces
import logging
import time
import os


class TempMonitor(Component):
    def __init__(self):
        super(TempMonitor, self).__init__()
        self.pid = os.getpid()
        now = time.ctime(int(time.time()))
        (globalIPs,globalMACs,localIP) = getNetworkInterfaces()
        globalIP = globalIPs[0]
        self.hostAddress = globalIP
        self.logger.info("(PID %s, IP %s)-starting TempMonitor, %s",str(self.pid),str(self.hostAddress),str(now))
        
    def on_tempupdate(self):
        # Receive: timestamp,temperature
        msg = self.tempupdate.recv_pyobj()   
        now = time.ctime(int(time.time()))     
        temperatureTime, temperatureValue, temperatureLocation = msg
        self.logger.info("on_tempupdate(): Temperature:%s, PID %s, from %s, Timestamp:%s", temperatureValue, str(now), temperatureLocation, temperatureTime)
        
    def __destroy__(self):
        now = time.time()
        self.logger.info("%s:%s - stopping TempMonitor, %s",str(self.pid),str(self.hostAddress),now)

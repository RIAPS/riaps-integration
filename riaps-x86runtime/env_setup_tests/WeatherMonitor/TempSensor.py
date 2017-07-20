'''
Created on Jan 25, 2017

@author: metelko
'''
from riaps.run.comp import Component
from riaps.utils.ifaces import getNetworkInterfaces
import logging
import time
import os


class TempSensor(Component):
    def __init__(self):
        super(TempSensor, self).__init__()
        self.pid = os.getpid()
        self.temperature = 65
        now = time.ctime(int(time.time()))
        (globalIPs,globalMACs,localIP) = getNetworkInterfaces()
        globalIP = globalIPs[0]
        self.hostAddress = globalIP    
        self.logger.info("(PID %s, IP %s)-starting TempSensor, %s",str(self.pid),str(self.hostAddress),str(now))
        self.logger.info("Initial temp:%d, %s",self.temperature,str(now))
        
    def on_clock(self):
        now = time.ctime(int(time.time()))
        msg = self.clock.recv_pyobj()
        self.temperature = self.temperature + 1
        msgTemp = str(self.temperature)
        msgIP = str(self.hostAddress)
        msg = (now,msgTemp,msgIP)       
        self.logger.info("on_clock(): Temperature - %s, PID %s, IP %s, %s",str(msg[1]),str(self.pid),str(self.hostAddress),str(now))
        self.ready.send_pyobj(msg)
               
    def __destroy__(self):
        now = time.time()
        self.logger.info("%s:%s - stopping TempSensor, %s",str(self.pid),str(self.hostAddress),now)         


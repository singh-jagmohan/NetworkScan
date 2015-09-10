#!/bin/bash
sudo chmod +x network_scan.py
python network_scan.py
sleep 120
sudo chmod +x port_scan.py
python port_scan.py
sleep 300
sudo chmod +x monitor.sh
bash monitor.sh



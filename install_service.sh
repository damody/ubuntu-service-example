#!/bin/bash
cp /tmp/other/nms.conf /etc/init
cp /tmp/other/sflow.conf /etc/init
cp /home/giga/code/sflowtool /usr/bin/
cp /home/giga/code/sflow_read /usr/bin/
chmod +x /usr/bin/nms
chmod +x /usr/bin/sflowtool
chmod +x /usr/bin/sflow_read
cp /tmp/other/nms.service  /etc/systemd/system/nms.service
cp /tmp/other/sflow.service  /etc/systemd/system/sflow.service
service nms start
service sflow start

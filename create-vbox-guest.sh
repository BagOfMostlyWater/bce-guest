#!/bin/bash

VERSION=2.4
PRODUCT=oskibox
NAME=${PRODUCT}-${VERSION}

INSTALL_ISO=/var/tmp/trusty-server-i386.iso 
HDD_FILE=/var/tmp/${NAME}.vdi

RAM=1024
VRAM=16
DISK_MB=16384

VBoxManage createvm -name ${NAME} -register && \
VBoxManage showvminfo ${NAME} && \
VBoxManage modifyvm ${NAME} --ostype linux26 --memory ${RAM} --vram ${VRAM} \
	--nic1 nat --nictype1 82540EM \
	--clipboard bidirectional --draganddrop hosttoguest && \
VBoxManage createvdi --filename ${HDD_FILE} --size ${DISK_MB}  && \
VBoxManage storagectl ${NAME} --name IDE --add ide --bootable on && \
VBoxManage storagectl ${NAME} --name SATA --add sata && \
VBoxManage storageattach ${NAME} --storagectl IDE --port 1 --device 0 \
	--type dvddrive --medium ${INSTALL_ISO} --tempeject on && \
VBoxManage storageattach ${NAME} --storagectl SATA --port 0 --device 0 \
	--type hdd --medium ${HDD_FILE}

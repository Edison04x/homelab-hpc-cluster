#!/bin/bash
# Script de aprovisionamiento automatizado para nodos CentOS 7 en Docker

for nodo in nodo-worker1 nodo-worker2; do
  echo "Preparando $nodo..."
  
  # 1. Migración de repositorios EOL al CentOS Vault
  sudo docker exec $nodo bash -c "sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*"
  sudo docker exec $nodo bash -c "sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*"
  sudo docker exec $nodo yum clean all
  
  # 2. Instalación de dependencias básicas y OpenSSH
  sudo docker exec $nodo yum install -y openssh-server openssh-clients which net-tools iproute openmpi openmpi-devel
  
  # 3. Configuración del servicio SSH
  sudo docker exec $nodo ssh-keygen -A
  sudo docker exec $nodo /usr/sbin/sshd
  
  # 4. Variables de entorno para OpenMPI
  sudo docker exec $nodo bash -c 'echo "export PATH=/usr/lib64/openmpi/bin:\$PATH" >> /root/.bashrc'
  sudo docker exec $nodo bash -c 'echo "export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:\$LD_LIBRARY_PATH" >> /root/.bashrc'
  
  echo "$nodo listo y aprovisionado!"
done

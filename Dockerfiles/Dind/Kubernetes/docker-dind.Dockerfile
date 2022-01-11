# This Dockerfile will:
# Setup and Start (SSH) service
# Update root user password to root

# Pull base image.
FROM docker:dind

# Install initials
RUN \
  apk update && \
  apk add curl wget nmap net-tools iputils sshpass bash

# Setup SSH Service
RUN \
    apk add openssh-server && \
    apk add openrc --no-cache && \
    rc-update add sshd && \
    rc-status && \
    touch /run/openrc/softlevel 
#
RUN \
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
cp minikube-linux-amd64 /usr/local/bin/minikube && \
chmod +x /usr/local/bin/minikube && \
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \ 
chmod +x kubectl && \
mv kubectl /usr/local/bin/ 

# Expose port for ssh
EXPOSE 22

# Define working directory.
WORKDIR /src

# Updating root password
RUN echo 'root:root' | chpasswd

# Allowing root login with ssh
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Start SSH Service & Run the entrypoint script
CMD [ "sh", "-c", "service sshd restart &&  dockerd-entrypoint.sh && bash" ]

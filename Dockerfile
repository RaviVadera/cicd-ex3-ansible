FROM ubuntu:20.04

# Take public key as argument
ARG SSH_USER_PUB_KEY

# Update package definitions
RUN apt update

# Install SSH server
RUN apt install -y openssh-server

# Add ssluser for Ansible and configure public key authentication for SSH
RUN useradd -m -s /bin/bash -G sudo -p $(openssl passwd -1 eee) ssluser
RUN mkdir /home/ssluser/.ssh
RUN touch /home/ssluser/.ssh/authorized_keys
RUN echo $SSH_USER_PUB_KEY >> /home/ssluser/.ssh/authorized_keys
RUN chown -R ssluser:ssluser /home/ssluser/.ssh
RUN chmod 700 /home/ssluser/.ssh
RUN chmod 600 /home/ssluser/.ssh/authorized_keys

# Install sudo
RUN apt install -y sudo

# Install python3
RUN apt install -y python3

# Install net-tools
RUN apt install -y net-tools

# Create necessary directory for sshd
RUN mkdir -p /run/sshd

# Expose SSH port
EXPOSE 22

# Start sshd as entrypoint
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
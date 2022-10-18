# cicd-ex3-ansible

- [How To Run](#how-to-run)
- [Outputs from Ansible Playbook](#outputs-from-ansible-playbook)
    - [O1](#o1)
    - [O2](#o2)
    - [O3](#o3)
    - [O4](#o4)
- [Why uptime output is incorrect](#why-uptime-output-is-incorrect)
- [What was easy and difficult](#what-was-easy-and-difficult)

## How To Run
1. Generate / Retrieve Public Key for SSH Authentication
    - Retrieve SSH Key
        - ````cat ~/.ssh/id_*.pub````
    - Generate SSH Key
        - ````ssh-keygen -t ed25519 -C "ssluser"````
        - accept all defaults
        - ````cat ~/.ssh/id_ed25519.pub````
2. Build docker image with public key information (not ideal way, but probably out of scope of this exercise?)
    - ````docker build --build-arg SSH_USER_PUB_KEY="<public_key>" --tag cicd.ansible .````
    - Example <public_key> = ````ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZVzwhgAavtkVnArQL4bTJWhWF3PSJWUqPsUIz93ac3 ssluser````
3. Run first docker container
    - ````docker run -d cicd.ansible````
4. Get IP address of the container
    - ````docker exec <container_id> ifconfig````
5. Update IP address in inventory.yaml -> Line 6
6. Run Ansible playbook
    - ````ansible-playbook -K -i inventory.yaml playbook.yaml````
    - ````-K```` is to prompt for sudo password from stdin, enter password ````eee```` when prompted
    - ````-i```` allows running Ansible without modifying /etc/ansible/hosts
7. Run second docker container
    - ````docker run -d cicd.ansible````
8. Get IP address of the container
    - ````docker exec <container_id> ifconfig````
9. Uncomment lines for node2 in inventory.yaml -> Lines 9-13
10. Update IP address in inventory.yaml -> Line 11
11. Run Ansible playbook
    - ````ansible-playbook -K -i inventory.yaml playbook.yaml````
    - ````-K```` is to prompt for sudo password from stdin, enter password ````eee```` when prompted
    - ````-i```` allows running Ansible without modifying /etc/ansible/hosts

## Outputs from Ansible Playbook

### O1
````$ ansible-playbook -K -i inventory.yaml playbook.yaml````  
BECOME password: 

PLAY [Ansible] *************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
ok: [node1]

TASK [Ensure node(s) are reachable] ****************************************************************************************************************************************************************************
ok: [node1]

TASK [Ensure latest git version] *******************************************************************************************************************************************************************************
changed: [node1]

TASK [Query uptime] ********************************************************************************************************************************************************************************************
changed: [node1]

TASK [Output uptime] *******************************************************************************************************************************************************************************************
ok: [node1] => {
    "msg": "up 12 hours, 18 minutes"
}

PLAY RECAP *****************************************************************************************************************************************************************************************************
node1                      : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


### O2
````$ ansible-playbook -K -i inventory.yaml playbook.yaml````  
BECOME password: 

PLAY [Ansible] *************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
ok: [node1]

TASK [Ensure node(s) are reachable] ****************************************************************************************************************************************************************************
ok: [node1]

TASK [Ensure latest git version] *******************************************************************************************************************************************************************************
ok: [node1]

TASK [Query uptime] ********************************************************************************************************************************************************************************************
changed: [node1]

TASK [Output uptime] *******************************************************************************************************************************************************************************************
ok: [node1] => {
    "msg": "up 12 hours, 21 minutes"
}

PLAY RECAP *****************************************************************************************************************************************************************************************************
node1                      : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   





### O3
````$ ansible-playbook -K -i inventory.yaml playbook.yaml````  
BECOME password: 

PLAY [Ansible] *************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
ok: [node2]
ok: [node1]

TASK [Ensure node(s) are reachable] ****************************************************************************************************************************************************************************
ok: [node2]
ok: [node1]

TASK [Ensure latest git version] *******************************************************************************************************************************************************************************
ok: [node1]
changed: [node2]

TASK [Query uptime] ********************************************************************************************************************************************************************************************
changed: [node2]
changed: [node1]

TASK [Output uptime] *******************************************************************************************************************************************************************************************
ok: [node1] => {
    "msg": "up 12 hours, 27 minutes"
}
ok: [node2] => {
    "msg": "up 12 hours, 27 minutes"
}

PLAY RECAP *****************************************************************************************************************************************************************************************************
node1                      : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node2                      : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


### O4
````$ ansible-playbook -K -i inventory.yaml playbook.yaml````  
BECOME password: 

PLAY [Ansible] *************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
ok: [node2]
ok: [node1]

TASK [Ensure node(s) are reachable] ****************************************************************************************************************************************************************************
ok: [node1]
ok: [node2]

TASK [Ensure latest git version] *******************************************************************************************************************************************************************************
ok: [node1]
ok: [node2]

TASK [Query uptime] ********************************************************************************************************************************************************************************************
changed: [node1]
changed: [node2]

TASK [Output uptime] *******************************************************************************************************************************************************************************************
ok: [node1] => {
    "msg": "up 12 hours, 29 minutes"
}
ok: [node2] => {
    "msg": "up 12 hours, 29 minutes"
}

PLAY RECAP *****************************************************************************************************************************************************************************************************
node1                      : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node2                      : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

## Why uptime output is incorrect
Since ````uptime```` command reports the uptime for the kernel and we are running the nodes as docker containers, the kernel is actually shared across the containers. Hence, the uptime for both containers are reported as same independent of when the container is started.

## What was easy and difficult
- Easier parts
    - Creating docker image
    - Creating Ansible inventory
- Difficult parts
    - Figuring out the configuration to enable public key authentication for SSH and making it working seamlessly with Ansible
    - The reason of the error "[WARNING]: Updating cache and auto-installing missing dependency: python3-apt" was because sudo did not work properly. To fix it, make sure to use ````become```` plugin to elevate privileges for the user and provide sudo password by using ````-K```` with ansible-playbook command. 
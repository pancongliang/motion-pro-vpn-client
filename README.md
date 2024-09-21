# motion-pro-vpn-client

### 1. Install podman

#### Mac OS:
~~~
brew update
brew install podman wget
podman machine init
podman machine start
~~~

#### RHEL:
~~~
yum install -y podman
~~~

### 2. Setting Environment Variables

~~~
export USER='xxxx@xxx.com'
export PASSWD='xxxx'
export HOST='vpn.tok.softlayer.com'
export METHOD=radius
~~~

### 3. Build Dockerfile

~~~
./buildit.sh
~~~

### 4. Start VPNcontainer

~~~
./runit.sh 
~~~


### 5. Automatic Start VPN Container

#### RHEL:

##### Automatic Start VPN Container
~~~
cat << EOF > /etc/systemd/system/VPNcontainer.service
[Unit]
Description= VPNcontainer
After=network.target
After=network-online.target
[Service]
Restart=always
ExecStart=/usr/bin/podman start -a VPNcontainer
ExecStop=/usr/bin/podman stop -t 10 VPNcontainer
[Install]
WantedBy=multi-user.target
EOF
~~~
~~~
systemctl enable VPNcontainer.service --now
~~~

##### Restart the container to keep the VPN token valid.
~~~
podman exec -it VPNcontainer /bin/bash
[root@b1c83b17cb9f /]# ssh-keygen
[root@b1c83b17cb9f /]# ssh-copy-id root@10.184.134.128
[root@b1c83b17cb9f /]# exit
~~~

~~~
crontab -e
~~~
~~~
# Restart the container to keep the VPN token valid.
*/5 * * * * /usr/local/bin/podman exec -it VPNcontainer ssh -o BatchMode=yes -o ConnectTimeout=15 -t root@10.184.134.128 'date' > /dev/null 2>&1; if [ $? -eq 0 ]; then echo "$(date): SSH Succeeded" >> ~/Library/Logs/ssh.log 2>&1; else echo "$(date): SSH Failed" >> ~/Library/Logs/ssh.log 2>&1; /usr/local/bin/podman restart VPNcontainer; echo "$(date): VPNcontainer restarted" >> ~/Library/Logs/ssh.log 2>&1; fi

~~~

#### Mac OS:

##### Specify the machines that can ssh inside the VPN and Automatic Start VPN Container
~~~
podman exec -it VPNcontainer /bin/bash
[root@b1c83b17cb9f /]# ssh-keygen
[root@b1c83b17cb9f /]# ssh-copy-id root@10.184.134.128
[root@b1c83b17cb9f /]# exit
~~~
~~~
crontab -e
~~~
~~~
# Restart the container to keep the VPN token valid.
*/15 * * * * /usr/local/bin/podman exec -it VPNcontainer ssh -o BatchMode=yes -o ConnectTimeout=15 -t root@10.184.134.128 'date' > /dev/null 2>&1; if [ $? -eq 0 ]; then echo "$(date): SSH Succeeded" >> ~/Library/Logs/ssh.log 2>&1; else echo "$(date): SSH Failed" >> ~/Library/Logs/ssh.log 2>&1; /usr/local/bin/podman restart VPNcontainer; echo "$(date): VPNcontainer restarted" >> ~/Library/Logs/ssh.log 2>&1; fi

# Check the status of the machine and container, and trigger the start if they are not started.
*/2 * * * * /usr/local/bin/podman machine list | grep -q 'Currently running' || /usr/local/bin/podman machine start && /usr/local/bin/podman ps --filter "name=VPNcontainer" --filter "status=running" | grep -q VPNcontainer || /usr/local/bin/podman restart VPNcontainer
~~~


### 6. Access Target environment
~~~
# Conatiner hosts:
podman exec -it VPNcontainer /bin/bash -c 'ssh root@10.184.134.128'

or

# PC to Container hosts:
export CONTAINER_HOST-IP=10.72.94.215
ssh -t root@$CONTAINER_HOST_IP "podman exec -it VPNcontainer /bin/bash -c 'ssh -t root@10.184.134.128'"
~~~

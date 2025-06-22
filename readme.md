

Features
🌐 Web-based VNC access (port 6080)
🔑 SSH access (port 2221)
💾 Persistent storage volume
Prerequisites
Docker installed
KVM support on host machine
sudo privileges (for KVM device access)
VM user and pass
username:- root
password:- root
Installation
# Clone the repository
git clone https://github.com/samanyu200/root-v1.1.1/

# enter the repo
cd root-v1.0.1

# Build the Docker image
docker build -t ubuntu-vm .

# Run the container

docker run --privileged -p 6080:6080 -p 2221:2222 -v $PWD/vmdata:/data ubuntu-vm

🐳 To Run in NAT Mode (default):
bash


docker run --privileged -p 6080:6080 -p 2221:2222 -v $PWD/vmdata:/data ubuntu-vm




# or

docker build -t ubuntu-vm .

docker run --rm --privileged --net=host -v $PWD/vmdata:/data ubuntu-vm

# Update info
guys update has come we have added a new file called update logs you can read it to sees all the updates of the repo

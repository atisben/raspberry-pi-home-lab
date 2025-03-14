[document](https://docs.quentin.legraverend.fr/archives/archives/docker_portainer_raspberry)

## 1. Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Check that docker is running properly
```bash
sudo systemctl status docker
```
## 2. Install Portainer

First initialize docker Swarm

```bash
sudo docker swarm init
```

Then download Portainer Stack

```bash
curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml
```

Deploy the stack

```bash
sudo docker stack deploy --compose-file=portainer-agent-stack.yml portainer
```

Then docker should be accessible at http://raspberrypi:9000
[Portainer](http://raspberrypi:9000)
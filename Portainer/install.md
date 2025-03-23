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

```bash
sudo docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v ${DATA}/portainer_data:/data portainer/portainer-ce:linux-arm
```


Then docker should be accessible at http://raspberrypi:9000
[Portainer](http://raspberrypi:9000)


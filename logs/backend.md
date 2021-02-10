```
sudo apt  install docker.io
git clone https://github.com/tacobayle/demovip_server
cd $(basename https://github.com/tacobayle/demovip_server)
docker build . --tag demovip_server:latest
sudo docker run -d -p 192.168.2.111:80:80 demovip_server:latest
```
clear

docker build -t docker-vnc .

docker tag docker-vnc toanlk/docker-vnc:latest
docker push toanlk/docker-vnc:latest
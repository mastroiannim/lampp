docker build -t lampp .
docker image tag lampp mastroiannim/lampp:latest

exit

docker run -it --rm -p 80:80 --read-only lampp

docker run -it --rm -p 80:80 lampp


* WARNING: <service> is already starting
Ciò può essere corretto eseguendo il seguente comando:
root #rc-update --update

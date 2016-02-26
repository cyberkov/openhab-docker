# openhab-docker
This is the docker container for openHAB

To be able to use UPnP for discovery the container needs to be started with ``--net=host``.

## Usage

```
docker run \
        --name openhab \
        --net=host \
        -v /etc/localtime:/etc/localtime:ro \
        -v /etc/timezone:/etc/timezone:ro \
        -v /opt/openhab/conf:/openhab/conf \
        -v /opt/openhab/userdata:/openhab/userdata \
        -d \
        --restart=always \
        openhab/openhab
```

or with ``docker-compose.yml``
```
---
openhab:
  image: 'openhab/openhab'
  restart: always
  ports:
    - "8080:8080"
    - "8443:8443"
    - "5555:5555"
  net: "host"
  volumes:
    - '/etc/localtime:/etc/localtime:ro'
    - '/etc/timezone:/etc/timezone:ro'
    - '/opt/openhab/userdata:/openhab/userdata'
    - '/opt/openhab/conf:/openhab/conf'
  command: "dockerize -stdout /openhab/userdata/logs/openhab.log /openhab/start.sh debug"
```
then start with ```docker-compose up -d```

**Environment variables**
*  `OPENHAB_HTTP_PORT`=8080
*  `OPENHAB_HTTPS_PORT`=8443
*  `EXTRA_JAVA_OPTS`

**Parameters**

* `-p 8080` - the port of the webinterface
* `-v /openhab/conf` - openhab configs
* `-v /openhab/userdata` - openhab userdata directory
* `--device=/dev/ttyUSB0` - attach your devices like RFXCOM or Z-Wave Sticks to the conatiner

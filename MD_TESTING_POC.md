# Steps to reproduce POC

Copy the `Dockerfile` and all `*.tf|tfvars` to a directory. Built the named docker container

```shell
docker build -t hashi_inspec .
```

Open a seperate window to run the containers

```shell
docker rm -f hashi_inspec
docker run -e VAULT_ADDR='http://127.0.0.1:8200' --name hashi_inspec -it hashi_inspec
```
This will open an interactive shell to the container to allow debuging. 
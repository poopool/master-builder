# README #

### What is this repository for? ###

* Master-Builder is a docker image builder based on popular configuration management tools like Puppet and Chef. Master-Builder is a container
itself and needs to have config scripts from supported tools mounted as a volume to "/artifact" path and proper environment variables passed in.

### How do I get set up? ###

* Clone the repo
* Build the Master-Builder container using following command or just pull docker.applariat.io:5000/master-builder
 `docker build -t docker.applariat.io:5000/master-builder -f Dockerfile.builder .`
* Run the following command(replace env vars with proper values)

  Puppet:
 `docker run --rm -it -v $PWD/puppet-repo-lamp:/artifact -v /var/run/docker.sock:/var/run/docker.sock -e BASE_IMAGE_NAME=ubuntu-upstart:14.04 -e IMAGE_TAG=docker.applariat.io:5000/builder-lamp:1 -e DOCKER_REGISTRY=docker.applariat.io:5000 -e REGISTRY_USER=*** -e REGISTRY_PASS=*** -e PROVISIONER=puppet -e PORT=80 -e COMMAND=/usr/bin/supervisord docker.applariat.io:5000/master-builder`
 
  Chef:
 `docker run --rm -it -v $PWD/chef-repo-awesome-customers:/artifact -v /var/run/docker.sock:/var/run/docker.sock -e BASE_IMAGE_NAME=ubuntu:14.04 -e IMAGE_TAG=docker.applariat.io:5000/builder-awesome-customers:1 -e DOCKER_REGISTRY=docker.applariat.io:5000 -e REGISTRY_USER=*** -e REGISTRY_PASS=*** -e PROVISIONER=chef -e PORT=80 -e COMMAND=/usr/bin/supervisord docker.applariat.io:5000/master-builder`
 
### List of required environment variables ###

[BASE_IMAGE_NAME] (required) Base image to be used for building the image

[IMAGE_TAG] (required) Final image tag

[DOCKER_REGISTRY] (required) Docker registry that final image needs to be pushed to

[REGISTRY_USER] (required)

[REGISTRY_PASS] (required)

[PROVISIONER] (required) Provisioner that should be used to run config scripts(only Puppet and Chef is supported at this point)

[PORT] (Optional) executes docker commit --change 'EXPOSE $PORT'

[COMMAND] (Optional) executes docker commit --change 'ENTRYPOINT ["$COMMAND"]'

### Who do I talk to? ###

* pouya@applariat.com
#!/usr/bin/env bash

echo "Master-Builder is waking up..."
sleep 5
echo "Starting the build process..."

#uncomment for local builds/troubleshooting
#reading the conf file
#echo "[-] Reading config file..."
#source build.conf

#func to check the result of a command
get_status(){
if [ $? -ne 0 ]
then
  echo "[!] ERROR: Build process failed. Please check the logs."
  exit 1
fi
}

##TODO: We assume apt package manager, so in case BASE_IMAGE_NAME is set to rpm based OS this func will break. Ideally user needs to
##TODO: provide an inline shell script to install provisioner based on OS just like what packer does

install_puppet(){
#Installing good stuff
/usr/bin/docker exec -i $CONTAINER_ID apt-get update
/usr/bin/docker exec -i $CONTAINER_ID apt-get install -y zip unzip wget bsdtar
#Adding puppetlabs repo
/usr/bin/docker exec -i $CONTAINER_ID wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
/usr/bin/docker exec -i $CONTAINER_ID dpkg -i puppetlabs-release-trusty.deb
#Installing puppet
/usr/bin/docker exec -i $CONTAINER_ID apt-get update
/usr/bin/docker exec -i $CONTAINER_ID apt-get install -y puppet
/usr/bin/docker exec -i $CONTAINER_ID rm -rf puppetlabs-release-trusty.deb
}

install_chef(){
#Installing good stuff
/usr/bin/docker exec -i $CONTAINER_ID apt-get update
/usr/bin/docker exec -i $CONTAINER_ID apt-get install -y zip unzip wget bsdtar
#Installing Chefdk
/usr/bin/docker exec -i $CONTAINER_ID wget https://packages.chef.io/files/stable/chefdk/1.2.22/ubuntu/14.04/chefdk_1.2.22-1_amd64.deb
/usr/bin/docker exec -i $CONTAINER_ID dpkg -i chefdk_1.2.22-1_amd64.deb
/usr/bin/docker exec -i $CONTAINER_ID rm -rf chefdk_1.2.22-1_amd64.deb
}

#making sure all the params are set
[ -z $BASE_IMAGE_NAME ] && { echo "[!] ERROR: IMAGE_NAME not set. Aborting."; exit 1; }
[ -z $IMAGE_TAG ] && { echo "[!] ERROR: IMAGE_TAG not set. Aborting."; exit 1; }
[ -z $DOCKER_REGISTRY ] && { echo "[!] ERROR: DOCKER_REGISTRY not set. Aborting."; exit 1; }
[ -z $REGISTRY_USER ] && { echo "[!] ERROR: REGISTRY_USER not set. Aborting."; exit 1; }
[ -z $REGISTRY_PASS ] && { echo "[!] ERROR: REGISTRY_PASS not set. Aborting."; exit 1; }
[ -z $PROVISIONER ] && { echo "[!] ERROR: IMAGE_NAME not set. Aborting."; exit 1; }

#making sure docker is installed and accessible
[ -x /usr/bin/docker ] || { echo "[!] ERROR: Missing docker on this system. Aborting."; exit 1; }
/usr/bin/docker ps > /dev/null
get_status

#starting provisionee container and capturing container id
CONTAINER_ID=`/usr/bin/docker run -d -it $BASE_IMAGE_NAME`
get_status

#installing provisioner
if [ $PROVISIONER == "puppet" ]
then
  echo "Installing Puppet..."
  install_puppet
  if [ $? -ne 0 ]; then { echo "[!] ERROR: Puppet installation failed. Aborting."; exit 1; }; fi
elif [ $PROVISIONER == "chef" ]
then
  echo "Installing Chef..."
  install_chef
  if [ $? -ne 0 ]; then { echo "[!] ERROR: Chef installation failed. Aborting."; exit 1; }; fi
else
  echo "[!] ERROR: Provisioner not supported.  Aborting."
  exit 1
fi

#packaging artifacts and copying them over to provisionee
/usr/bin/zip -r artifact.zip /artifact/
/usr/bin/docker cp ./artifact.zip $CONTAINER_ID:/
get_status
if [ $PROVISIONER == "puppet" ]
then
  #using bsdtar to get rid of top level dir
  /usr/bin/docker exec -i $CONTAINER_ID /bin/mkdir -p /root/puppet-repo
  /usr/bin/docker exec -i $CONTAINER_ID /usr/bin/bsdtar -xf /artifact.zip -s'|[^/]*/||' -C /root/puppet-repo
  get_status
else
  #using bsdtar to get rid of top level dir
  /usr/bin/docker exec -i $CONTAINER_ID /bin/mkdir -p /root/chef-repo
  /usr/bin/docker exec -i $CONTAINER_ID /usr/bin/bsdtar -xf /artifact.zip -s'|[^/]*/||' -C /root/chef-repo
  get_status
fi

#running puppet scripts to provision the provisionee
if [ $PROVISIONER == "puppet" ]
then
  /usr/bin/docker exec -i $CONTAINER_ID /usr/bin/puppet apply --modulepath /root/puppet-repo/modules /root/puppet-repo/install.pp
  get_status
else
  /usr/bin/docker exec -i $CONTAINER_ID /usr/bin/chef-solo -c /root/chef-repo/solo.rb -j /root/chef-repo/install.json
  get_status
fi

#removing artifacts and cleaning up image
if [ $PROVISIONER == "puppet" ]
then
  /usr/bin/docker exec -i $CONTAINER_ID rm -rf /root/puppet-repo
  /usr/bin/docker exec -i $CONTAINER_ID rm -rf /artifact.zip
  get_status
else
 /usr/bin/docker exec -i $CONTAINER_ID rm -rf /root/chef-repo
 /usr/bin/docker exec -i $CONTAINER_ID rm -rf /artifact.zip
 get_status
fi

#commiting container and capturing image id
#check to see if "commit --change" parameters are passed in
if [ ! -z $PORT ]
then
 EXPOSE_PORT=" --change 'EXPOSE ${PORT}' "
fi

if [ ! -z $COMMAND ]
then
 ENTRYPOINT=" --change 'ENTRYPOINT [\"${COMMAND}\"]' "
fi

#Construncting a "docker commit" command with "--change" parameters turned out to be a pain as bash treats double and single quotes
#differently when ran as command vs ran as a bash script. Had to break them into 3 different strings and concatenate them
STR=$EXPOSE_PORT$ENTRYPOINT$CONTAINER_ID
STR2="/usr/bin/docker commit"
CMD=$STR2$STR

IMAGE_ID=`eval $CMD`
get_status

#killing the container and tagging the image
/usr/bin/docker kill $CONTAINER_ID
/usr/bin/docker tag $IMAGE_ID $IMAGE_TAG
get_status

#logging in and pushing the image
/usr/bin/docker login  -u $REGISTRY_USER -p $REGISTRY_PASS $DOCKER_REGISTRY
get_status
/usr/bin/docker push $IMAGE_TAG
get_status

#cleaning up
/usr/bin/docker rm $CONTAINER_ID
/usr/bin/docker rmi $IMAGE_ID

echo "Build process completed successfully, sadly Master-Builder is going to die now...ByeBye"
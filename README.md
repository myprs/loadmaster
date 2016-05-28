# loadmaster: a simple helper script for configuring docker containers

## Abstract

Creating docker files regularly requires to manage configuration files inside the container. There are several aspects that requires to be taken care of to ensure multiple containers created from the same image to be unique. On the other hand they should not loose their configuration on upgrade, when a new container is created from an updated image.

These goals can be archived by some simple steps. 
At image creation time ensure to remove all individual ids and key material that makes an installation unique. Make sure there are exportable locations in the file system, where persistent data can be stored.
At container start, if these IDs are not present,  create new keys and ids in the exportable location and link the original files to them. For the persistent data, if not already present, create directories in the exportable location, copy missing files from the original location and remove the original files. Link the original location to the representation in the exportable location. 
By having done so all data representing the "identity" and the state of the container can be placed inside a data-container, which is based on the docker image. This data-container is tied to the container running the code. So you can dispose the running container without loosing your data and tying the existent data to a new instance of the container.

As these steps are quite simple, but need to be coordinated between the phases of image creation and container creation, handling this in an automated manner helps maintaining consistency following the "don't repeat yourself" dogma.


## Quick start

Create a dockerfile:
 Install the software as required
 Add the ```loadmaster.sh``` script to your container
 Add a loadingplan file
  Make sure to define your program call as a STARTCMD definition
  Define how to recreate IDs and Keys
  Define where to place the persistent configuration with PUBLISHDIR and PUBLISHFILE
 Run the ```loadmaster.sh``` script with your loadingplan in your image (this will create the startcontainer.sh link in your image)
 Mark the persistent directories as exportable in your dockerfile
 Make the ```startcontainer.sh``` your entrypoint in the Dockerfile
Create an image
Create a data-container
 Just create it, you can stop it immediately. It does not need to be started to hold the data and being accessible.
 You might want to run the container to configure the application to your needs.
Create a runing container:
 make sure to import the directories from the data container
 Run it. If all goes well it inherits the configuration from your data container.

The last step should be repeatable, always giving you the same results.


Now image creation and container update should be repeatable with consistent resuts.


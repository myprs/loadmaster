# Loadmaster: a simple helper script for configuring docker containers

## Abstract

Creating docker files very often requires to manage configuration files inside the container. There are several aspects that requires to be taken care of to ensure containers to be unique but do not loose their configuration on upgrade.

These goals can be archived by some simple steps. On image creation ensure to remove all individual ids and key material. On container creation make sure to move all configuration to exportable locations, if not already has done before, so they can be held into a separate data container. Also the initially removed material might need to be regenerated, if absent.

As these steps are quite simple, but need to be coordinated between the phases of image creation and container creation, handling this in an automated manner helps maintaining consistency following the "don't repeat yourself" dogma.



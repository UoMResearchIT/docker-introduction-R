---
title: Setup
---

This lesson aims to introduce you to the use of Docker containers.

It will guide you through:

* What images and containers are, and how they are used.
* The use of the Docker command line interface.
* Setting up whole services in Docker (Compose).

::::::::::::::::::::::::::::::::::::  checklist

## Prerequisites

You should be familiar with the use of:

- The [unix shell](https://swcarpentry.github.io/shell-novice/).

::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::  checklist

### Requirements

- A Linux, Mac or Windows computer
- Superuser / administrator access

**Warning** If you install Docker without root / administrator rights, it will not be possible to follow or complete this course.

::::::::::::::::::::::::::::::::::::::::::::

### Installation of Docker

Installing Docker on different platforms requires different procedures.
Please follow the instructions for your platform below:

::::::::::::::::::::::::::::::::::::::::::::::::::: tab

### Linux

Installation on Linux requires two steps:

- Installation of Docker Engine
- Enabling non-root access

Docker provides a generic installation option using a [convenience script](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script).

Once the Docker Engine has been successfully installed, some [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/) must be taken.

If you prefer not to use the convenience script,
Docker provides a guide to [installing the Docker Engine](https://docs.docker.com/engine/install/),
with an overview of supported Linux distributions and pointers to relevant installation information.

**Warning: Extra action if you install Docker using Snap**

[Snap](https://snapcraft.io/) is an app management system for linux, popular on Ubuntu and other systems.
Docker is available via Snap.
However, if you have installed it using this service you will need to take the following steps to ensure docker will work properly:  
`mkdir ~/tmp`  
`export TMPDIR=~/tmp`

These commands will let you use docker in the current terminal instance,
but you will have to run "export TMPDIR=~/tmp" in every new terminal you want to use docker in.

An alternative is to append that command at the end of your bashrc file with the following command:  
`echo "export TMPDIR=~/tmp" >> ~/bashrc`

This will configure each new instance of a terminal to run that command at the start of every new terminal instance.


### Mac

Please install docker following these [instructions](https://docs.docker.com/desktop/install/mac-install/).


### Windows

Installation on Windows requires two steps:

- Enabling the Windows Subsystem for Linux.
- Installation of Docker Desktop.

Microsoft publishes a [guide](https://learn.microsoft.com/en-us/windows/wsl/install) to installing WSL,
and Docker provides a [guide](https://docs.docker.com/desktop/install/windows-install/) for installing Docker Desktop.

We recommend following these guides directly, as they are updated regularly and provide the most current information.

**Note**: Please ensure you select the use of WSL2 when installing Docker Desktop.
We recommend using WSL not just for the Docker backend, but also for the terminal.
This will allow you to use the same commands in this course.

You can also find a summary of the steps below (buyer beware!).

- Open PowerShell as Administrator ("Start menu" > "PowerShell" > right-click > "Run as Administrator")
  and paste the following commands followed by <kbd>Enter</kbd> to install WSL 2:  
  `wsl --update`  
  `wsl --install --distribution Ubuntu`  
  To ensure that `Ubuntu` is the default subsystem instead of `docker-desktop-*`, you may need to use:  
  `wsl --set-default Ubuntu`  
  If you had previously installed WSL1 in Windows 10, upgrade to WSL2 with:  
  `wsl --set-version Ubuntu 2`
- Reboot your computer.
  Ubuntu will set itself up after the reboot.
  Wait for Ubuntu to ask for a UNIX username and password.
  After you provide that information and the command prompt appears.
  The Ubuntu window can be closed.
- Then continue to [download Docker Desktop](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe) and run the installer.
  Make sure to select the option to use WSL2 as the backend.
- Reboot your computer again, and then run Docker Desktop.
  From the top menu, choose "Settings" > "Resources" > "WSL Integration"
  Under "Enable integration with additional distros", select "Ubuntu".
  Apply changes and restart.

:::::::::::::::::::::::::::::::::::::::::::::::::::



### Verify the installation

To check if the Docker and client and server are working run the following command in a new terminal session:

```bash
docker version
```
```output
Client: Docker Engine - Community
 Version:           27.3.1
 [...]

Server: Docker Engine - Community
 Engine:
  Version:          27.3.1
  [...]
```

If you see output similar to the above, you have a successful installation.
It is important that both the "Client" and the "Server" sections return information.

---
title: Setup
---

### Requirements

- A Linux, Mac or Windows computer
- More than 5 GB free hard drive space
- If installing Docker yourself: **root / administrator access**

:::::::::::::::::::::::::::::::::::::::::  callout

## Warning

Docker uses root / administrator access for basic functionality. If installing Docker yourself, without root / administrator rights, it will not be possible to follow or complete this course.

If your computer has already been set up with Docker, then it may be possible to follow this course, please check locally.


::::::::::::::::::::::::::::::::::::::::::::::::::

### Website accounts to create

Please seek help at the start of the lesson if you have not been able to establish a website account on:

- The [Docker Hub](https://hub.docker.com). We will use the Docker Hub to download pre-built container images, and for you to upload and download container images that you create, as explained in the relevant lesson episodes.

### Software to install

Installing Docker on different platforms requires different procedures and generally requires root / administrator access for a successful installation. Please follow the pointers below for assistance in finding the correct installation procedures.

<br>

:::::::::::::::: solution

## Windows

Installation of Docker on Microsoft Windows comprises two central steps:

- Enabling the Windows Subsystem for Linux
- Installation of the Docker Desktop package

Microsoft publish a [guide](https://learn.microsoft.com/en-us/windows/wsl/install "WSL install") to installing WSL and Docker provide a [guide](https://docs.docker.com/desktop/install/windows-install/ "Docker Desktop Install ") for installing Docker Desktop.

Further, we provide some instruction here that attempts to unify these two guides.

1. Confirm that you are running Windows 10, version 2004 or higher (Build 19041 and higher) or Windows 11.

::::::::::::::::::::::::::::::::::::::::  callout

### Check your Windows version

To check your Windows version and build number, press the Windows logo key + <kbd>R</kbd>, type `winver`, select OK.
You can update to the latest Windows version by selecting "Start" > "Settings" > "Windows Update" > "Check for updates".


::::::::::::::::::::::::::::::::::::::::::::::::::

2. Open PowerShell as Administrator ("Start menu" > "PowerShell" > right-click > "Run as Administrator")
  and paste the following commands followed by <kbd>Enter</kbd> to install WSL 2:
  `wsl --update`
  `wsl --install --distribution Ubuntu`
  To ensure that `Ubuntu` is the default subsystem instead of `docker-desktop-*`, you may need to use:
  `wsl --set-default Ubuntu`
  If you had previously installed WSL1 in Windows 10, upgrade to WSL2 with:
  `wsl --set-version Ubuntu 2`

3. Reboot your computer. Ubuntu will set itself up after the reboot. Wait for Ubuntu to ask for a
  UNIX username and password. After you provide that information and the command prompt appears,
  then the Ubuntu window can be closed.

4. Then continue to [download Docker Desktop](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe){:target="\_blank"}{:rel="noopener noreferrer"} and run the installer.
  
  1. Reboot after installing Docker Desktop.
  2. Run Docker Desktop
  3. Accept the terms and conditions, if prompted
  4. Wait for Docker Desktop to finish starting
  5. Skip the tutorial, if prompted
  6. From the top menu choose "Settings" > "Resources" > "WSL Integration"
  7. Under "Enable integration with additional distros" select "Ubuntu"
  8. Close the Docker Desktop window

:::::::::::::::::::::::::::::::::::::::::  callout

### Warning: Git Bash

If you are using Git Bash as your terminal on Windows then you should be aware that you may run
into issues running some of the commands in this lesson as Git Bash will automatically re-write
any paths you specify at the command line into Windows versions of the paths and this will confuse
the Docker container you are trying to use. For example, if you enter the command:

```
docker run alpine cat /etc/os-release
```

Git Bash will change the `/etc/os-release` path to `C:\etc\os-release\` before passing the command
to the Docker container and the container will report an error. If you want to use Git Bash then you
can request that this path translation does not take place by adding an extra `/` to the start of the
path. i.e. the command would become:

```
docker run alpine cat //etc/os-release
```

This should suppress the path translation functionality in Git Bash.


::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::

:::::::::::::::: solution

## Mac

Please install docker following these [instructions](https://docs.docker.com/desktop/install/mac-install/).

:::::::::::::::::::::::::

:::::::::::::::: solution

## Linux

Installation on Linux requires two steps:

- Installation of Docker Engine
- Enabling non-root access

Docker provide a guide to [installing the Docker Engine](https://docs.docker.com/engine/install/) which provides an overview of supported Linux distributions and pointers to relevant installation information.

Additionally, a generic installation option is provided using a [convenience script](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script).

Once the Docker Engine has been successfully installed, some [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/) must be taken.

:::::::::::::::::::::::::::::::::::::::::  callout

## Warning: Extra action if you install Docker using Snap

[Snap](https://snapcraft.io/) is an app management system for linux - which is popular on
Ubuntu and other systems. Docker is available via Snap - if you have installed it using
this service you will need to take the following steps, to ensure docker will work properly.

```bash
mkdir ~/tmp
export TMPDIR=~/tmp
```

These commands will let you use docker in the current terminal instance, but you will have to run "export TEMPDIR=~/tmp" in every new terminal you want to use docker in.
An alternative is to append that command at the end of your bashrc file with

```
echo "export TEMPDIR=~/tmp" >> ~/bashrc
```

this will configure each new instance of a terminal to run that command at the start of every new terminal instance.


::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::


### Verify Installation

To check if the Docker and client and server are working run the following command in a new terminal session:

```bash
$ docker version
```

```output
Client:
 Version:           20.10.2
 API version:       1.41
 Go version:        go1.13.8
 Git commit:        20.10.2-0ubuntu2
 Built:             Tue Mar  2 05:52:27 2021
 OS/Arch:           linux/arm64
 Context:           default
 Experimental:      true

Server:
 Engine:
  Version:          20.10.2
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.13.8
  Git commit:       20.10.2-0ubuntu2
  Built:            Tue Mar  2 05:45:16 2021
  OS/Arch:          linux/arm64
  Experimental:     false
 containerd:
  Version:          1.4.4-0ubuntu1
  GitCommit:        
 runc:
  Version:          1.0.0~rc95-0ubuntu1~21.04.1
  GitCommit:        
 docker-init:
  Version:          0.19.0
  GitCommit:        
```

If you see output similar to the above, you have a successful installation. It is important that both the "Client" and the "Server" sections return information. It is beyond the scope of this document to debug installation problems but some general advice would be to:

- double check the installation instructions for your platform
- ensure you have started a new terminal session (or rebooted your machine)



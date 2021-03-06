MICOS
=====

Machine Intelligence Cloud Operating System

MICOS is SmartOS + FIFO

MICOS is, as similar to Project FiFo and SmartOS, licensed under [CDDL](http://smartos.org/cddl/). Generally, it is free of use.

For User
========

Introduction, instruction and release download

For Developer
=============

# How to build MICOS ?

First of all, you need a SmartOS building environment, which can be setup by following [this](http://wiki.smartos.org/display/DOC/Building+SmartOS+on+SmartOS). You may also need to be able to access public internet inside it, since during the building process we will download lots of stuff.

After that, `cd <somedir>`, then

```bash
git clone https://github.com/plexzhang/micos.git
cd micos
git checkout refs/tags/<verion> -b <version>
./build.sh
```

After it is done, the result distribution should be

```
build/dist/iso/micos-<version>.iso
build/dist/usb/micos-<version>.img
```

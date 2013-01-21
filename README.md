> ![**S&P**](http://upload.wikimedia.org/wikipedia/commons/d/d2/Standard%26Poors.svg)
> This branch is as stable as the Greek economy!

---

## Warning!

This is an extremely volatile experimental branch in which I entertain the freedom of rewriting (parts of)
PortFusion in C.

Motivations are twofold:
+ offer support for smaller embedded devices than one can target with today's GHC
+ seamless integration with OpenWrt's build system to be placed in OpenWrt kernel images

Everything in this branch enjoys the following rights **at all times**:
+ the right to crash
+ the right to work
+ the right to be utterly broken beyond all hope
+ the right to contine its existence, be cared for and fixed
+ the right to end its existence, be forgotten and gone forever


## Supported Network Protocols

+ PortFusion(/Haskell) 1.0 or above


## Directories & Files

```
PortFusion                     # directory to put under openwrt/package/
PortFusion/Makefile            # OpenWrt 'make menuconfig' integration

PortFusion/src                 # PortFusion/C directory
PortFusion/src/Makefile        # PortFusion/C makefile
PortFusion/src/README          # PortFusion/C how-to-make file
PortFusion/src/pf.c            # PortFusion/C
```


## Dependencies

+ OS with BSD sockets API
+ POSIX Threads library
+ Luck and/or expertise


## Build as part of a OpenWrt kernel image

```
git clone git://nbd.name/openwrt.git
cd openwrt
./scripts/feeds update
./scripts/feeds install
make package/symlinks
cd package
git clone git://github.com/corsis/PortFusion.git -b ρφμ
cd ..
make menuconfig # find and *-select: "Corsis Research" > "pfl"
make
```

### Screenshots

![0](http://portfusion.sourceforge.net/dev/screenshots/PortFusion-C-in-OpenWrt-menuconfig.png)
![1](http://portfusion.sourceforge.net/dev/screenshots/PortFusion-C-built-into-vanilla-OpenWrt-from-git.png)


## Build as a tiny stand-alone binary

```
git clone git://github.com/corsis/PortFusion.git -b ρφμ
cd PortFusion/src
make
```

----

## Contact

[![corsis]](https://github.com/corsis/)

[fusion@corsis.eu](mailto:fusion@corsis.eu)

[corsis]: http://portfusion.sourceforge.net/i/l100.png "Corsis Research"

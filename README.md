This is an experi-fucking-mental branch in which I entertain the freedom of rewriting (parts of) PortFusion in C.

```
This branch is as stable as the current Greek economy!
```

## Directories & Files

```
PortFusion                     # directory to put under openwrt/package/
PortFusion/Makefile            # OpenWrt 'make menuconfig' integration

PortFusion/src                 # PortFusion/C directory
PortFusion/src/Makefile        # PortFusion/C makefile
PortFusion/src/README          # PortFusion/C how-to-make file
PortFusion/src/pf.c            # PortFusion/C
```

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

## Build as a clumsy stand-alone library

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

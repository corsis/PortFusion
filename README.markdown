![logo](http://corsis.eu/i/icon/h.png)

PortFusion ]-[ayabusa is a minimalistic, cross-platform, transport-layer distributed proxy for TCP traffic. It is damn small, optimized for maximum throughput and ease of use. PortFusion ]-[ayabusa is developed in Haskell and licensed under GPLv3.


## Build

### Requirements

| OS           | Dependencies        |
|:-------------|:--------------------|
| Windows      | [Haskell Platform](http://hackage.haskell.org/platform/) >= 2011.4.0.0
| Linux, Mac OS, BSD, Solaris, iOS and others | [GHC](http://www.haskell.org/ghc/) >= 7, [LLVM](http://llvm.org/) >= 3

### Instructions

```
git clone git://github.com/corsis/PortFusion.git
cd PortFusion
cabal configure
cabal build
```

## Use

### Distributed Reverse Proxy Mode

You have a Linux PC at home and a Windows PC at work behind a corporate firewall. You open port 2000 on your Linux PC to public internet and tunnel remote desktop to be able to work remotely from home.

```
@remote> PortFusion             ] 2000        [                     # home / Linux
@local > PortFusion 3389 server - 2000 remote [ 3389                # work / Windows
```
Any remote desktop client that connects to `remote:3389` are served by `server:3389` via `local`.

### Distributed Forward Proxy Mode

You have a Windows caching http(s) proxy server and anonymity clients that want to connect through your proxy to access websites blocked in their country. You open a port 2000 on your Windows PC to public internet and tell your contacts how to tunnel http connections to your http(s) proxy server.

```
@remote> PortFusion      ]        2000 [                            # http(s) proxy server / Windows
@local > PortFusion 3128 ] remote 2000 - server 3128                # anonymity client     / Windows
```
Any http client that connects to `local:3128` are served by `server:3128` via `remote`.

### Message Sequence Charts

| Distributed Reverse Proxy Mode  | Distributed Forward Proxy Mode |
|:--------------------------------|:-------------------------------|
| [<img height='300px' src='https://sourceforge.net/p/portfusion/wiki/hayabusa-pics/attachment/reverse-fusion-msc-5.png' alt='dr' />](https://sourceforge.net/p/portfusion/wiki/hayabusa-pics/attachment/reverse-fusion-msc-5.png) | [<img height='300px' src='https://sourceforge.net/p/portfusion/wiki/hayabusa-pics/attachment/forward-fusion-msc-4.png' alt='dr' />](https://sourceforge.net/p/portfusion/wiki/hayabusa-pics/attachment/forward-fusion-msc-4.png)


## Download

No binaries are available until multi-platform build automation tools have been set up.

Binaries will be made available for the following platforms.

```
+ :  immediate support
N :  near future 
F :  far  future
```

### CORSIS-supported Platforms

| OS           | x86    | x86-64 | ARM   | 
|:-------------|:-------|:-------|:------|
| Windows      | +      | +      | F
| Linux        | N      | +      | F
| FreeBSD      |        | +      |

### Community-supported Platforms

| OS           | x86    | x86-64 | ARM   | 
|:-------------|:-------|:-------|:------|
| Mac OS       |        | +      | F


## Remember

### Trademark

```
PortFusion™ is a trademark of Corsis (corsis.eu).
```

### Trademark Policy

```
You may only distribute unchanged official binaries downloaded from
corsis.eu using the PortFusion and Corsis Marks.

If you're taking full advantage of the open-source nature of Corsis
products and making significant functional changes, you may not
redistribute the fruits of your labor under any Corsis trademark,
without prior written consent from Corsis. For example, if you've
modified PortFusion, you may not use Corsis or PortFusion, in whole
or in part, in your product name. Also, it would be inappropriate
for you to say "based on Corsis PortFusion". Instead, in the interest
of complete accuracy, you could describe your executables as "based on
PortFusion technology", or "incorporating PortFusion source code."
In addition, a "Powered by PortFusion" logo will be made available.
```

### Copyright

```
    CORSIS PortFusion ]-[ayabusa
    Copyright © 2012  Cetin Sert
```

### Copyright License

```
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
```
[![GPLv3](http://gplv3.fsf.org/gplv3-127x51.png) <br /> Full License Text](http://beta.corsis.eu/license/)


## Know

### Core Principles

1. Be concise: [PortFusion is a single-file with less than 500 lines of code](https://github.com/corsis/PortFusion/blob/master/src/Main.hs)
2. Refactor as often and as heavily as possible
3. Push and keep code where it belongs
 1. Create [fully documented reusable libraries](http://hackage.haskell.org/package/splice) that [cover common needs](http://stackoverflow.com/questions/10080670/using-gnu-linux-system-call-splice-for-zero-copy-socket-to-socket-data-transfe)
 2. [Report bugs and work on fixes](https://github.com/haskell/network/issues/31)
4. Share everything
 1. [Use more permissive licenses whenever possible](http://hackage.haskell.org/package/splice)
 2. [Illustrate every step in detail](http://beta.corsis.eu/features/#tab-distributed-reverse-proxy-mode)
5. [Provide excellent support](https://sourceforge.net/p/portfusion/discussion/general/thread/7ad0cb49/)


## Contact

[![Corsis Research](http://portfusion.sourceforge.net/i/l100.png)](https://github.com/corsis/)

[fusion@corsis.eu](mailto:fusion@corsis.eu)

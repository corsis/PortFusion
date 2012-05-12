![pf]
[pf]: http://corsis.eu/i/icon/h.png "PortFusion"

PortFusion is a minimalistic, cross-platform, transport-layer distributed
reverse / forward proxy for TCP released under [GPLv3](#license).

A single package that makes the most of each platform by tapping into their
unique capabilities, combining this power with an intuitive interface, beautiful
design and [Haskell]'s excellent support for unprecedented levels of concurrency
and parallelism.

It strives for the smallest source code size while delivering maximum throughput
with near zero overhead.


## Notice

```
This is the new Haskell source code repository of the latest ]-[ayabusa version
– a complete rewrite of the initial Windows-only versions developed in F# / C#.
```


### What is new in `]-[ayabusa`?

PortFusion          | 0.9.3 – old                     | 1.0.3 – \]-[ayabusa
--------------------|---------------------------------|-------------------------------
Memory at Start-up  | ~14 MB                          | **~0.7 MB**
Memory at 1 Fusion  | ~30 MB (lots of jumps)          | **~1.0 MB** (constant)
OS Support          | ![Windows]                      | ![Windows], ![Linux], ![OSX], ![FreeBSD], ![OpenBSD], ![Solaris], ![Other]
Official Binaries   | ![Windows]                      | ![Windows], ![Linux], ![OSX], ![FreeBSD]
Source Code Size    | 778 lines (multiple files)      | **< 500 lines (1 file)**
Language            | F# / C#                         | **[Haskell] \([GHC] / [LLVM]\)**
Dependencies        | .NET 4.0 + F# 2.0 Runtime       | **none**
Deployment          | 2 .NET 4.0 managed binaries     | **1 unified, native code binary for each platform**
Binary Size         | **78.3 KB** (34.3 KB + 44 KB)   | 1-3 MB (~400 KB compressed)
Concurrency Model   | 1 OS thread per connection      | **1 Haskell thread per connection**
Distribution Technique | Windows Communication Foundation | **native sockets API and system calls of each OS**
Distributed Proxy Modes | reverse                     | **reverse, forward**
Local Proxy Modes   |                                 | **forward**
Native IPv6 Support | **yes**                         | **yes**
License             | ![GPLv3]                        | ![GPLv3]
Availability        | SourceForge.net                 | **SourceForge.net (binary) <br /> GitHub (source) <br /> Corsis.eu (commercial)**

[GPLv3]:   http://gplv3.fsf.org/gplv3-127x51.png                                           "GPLv3"
[Windows]: http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/os_win_other.png "Windows"
[Linux]:   http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/os_oracle.png    "Linux"
[OSX]:     http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/os_macosx.png    "Mac OS"
[FreeBSD]: http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/os_freebsd.png   "FreeBSD"
[OpenBSD]: http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/os_openbsd.png   "OpenBSD"
[Solaris]: http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/os_solaris.png   "Solaris"
[Other]:   http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/os_other.png     "Other"
[Haskell]: http://www.haskell.org/                                                         "Haskell"
[GHC]:     http://www.haskell.org/ghc/                                                     "GHC"
[LLVM]:    http://llvm.org                                                                 "LLVM"
[Haskell Platform]: http://hackage.haskell.org/platform/                                   "Haskell Platform"


## Download

Official binaries are built and made availabe for several platforms.

### Official Binaries

| <img height='48px' alt='CPU' title='CPU' src='http://a.fsdn.com/sd/topics/hardware_64.png' /> | ![Windows]                                                                                    | ![Linux]                                                                                      | ![OSX]                                                                                        | ![FreeBSD]                                                                                    | ![OpenBSD] | ![Solaris] | ![Other]
| --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------- | ---------- | --------
| x86-64                                                                                        | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | ![C]       | ![C]       | ![C]
| x86                                                                                           | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | ![B]                                                                                          |                                                                                               | ![C]                                                                                          | ![C]       | ![C]       | ![C]
| ARM                                                                                           | ![B]                                                                                          | ![B]                                                                                          | ![C]                                                                                          | ![C]                                                                                          | ![C]       | ![C]       | ![C]
| Other                                                                                         |                                                                                               | ![C]                                                                                          |                                                                                               | ![C]                                                                                          | ![C]       | ![C]       | ![C]

CORSIS Research <br /> <br />
![D] builds official binaries <br />
![B] will build official binaries on demand  <br />
![C] can cooperate with community for builds <br />

[D]: http://fusion.corsis.eu/i/down_16.png "Download"
[B]: http://res2.windows.microsoft.com/resbox/en/Windows%207/main/33624ed4-7676-4be4-9f47-d77eab7ecd9c_0.gif "Build-on-Demand"
[C]: http://res2.windows.microsoft.com/resbox/en/Windows%207/main/43fa1e85-5152-43ff-b0f7-63ae6520a88b_0.gif "Coop-on-Demand"

### Community Support

We are seeking your support to provide up-to-date binaries for all platforms!
If you have access to an OS+CPU combination lacking official binaries,
please [contact us](#contact) to join our build team!


## Use

| Distributed Reverse Proxy Mode  | Distributed Forward Proxy Mode |
|:-------------------------------:|:-------------------------------|
| |
| <p>You have a Linux PC at home `remote` and two Windows PCs behind a corporate firewall at work: the gateway `local` and your personal workstation `server`.</p> <p>You open port `2000` at `remote` and tunnel incoming RDP traffic at port `3389` on `remote` to your workstation `server` via gateway `local`.</p> | <p>A friend is operating an http proxy server `server:3128` and has only one gateway PC in his network that accepts incoming connections from the public internet `remote`.</p> <p>You `local` want to connect to the internet through your friend's http proxy `server:3128` to access websites blocked by your current internet service provider.</p>
| |
| `@remote>` <pre>PortFusion             ] 2000        [</pre> `@local>` <pre>PortFusion 3389 server - 2000 remote [ 3389</pre> | `@remote>` <pre>PortFusion      ]        2000 [</pre> `@local>` <pre>PortFusion 3128 ] remote 2000 - server 3128</pre>
| |
| <p>You can now connect to `remote:3389` with your favourite remote desktop client. All connections will be tunneled via gateway `local` to your workstation `server`.</p> <p>You only need to configure the firewall at your own home PC `remote` for port `2000`.</p> | <p>`local` HTTP clients that connects to the tunneled proxy `local:3128` are served by your friend's http proxy `server:3128` via gateway`remote`.</p> <p>Your friend only needs to configure the firewall on gateway `remote` for port `2000`.</p>
| |
| <a name='illustrate' class='anchor' href='#illustrate' /> [<img width='100%' src="http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/reverse-fusion-msc-7.png" alt="DR" />](http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/reverse-fusion-msc-7.png) | [<img width='100%' src="http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/forward-fusion-msc-7.png" alt="DF" />](http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/forward-fusion-msc-7.png)


## Build

### Requirements

You need only *one* of the following rows for compilation.

| Remarks | OS           | Compilers           |
|:--------|:-------------|:--------------------|
| recommended and <br /> used for official binaries | ![Windows], ![Linux], ![OSX], ![FreeBSD], ![OpenBSD], ![Solaris], ![Other] | [GHC] >= 7.4 <br /> [LLVM] >= 3
| easy to install for <br /> all Haskell newbies | ![Windows], ![OSX] | [Haskell Platform] >= 2011.4.0.0

### Instructions

```bash
cabal update
cabal install    splice

git   clone      git://github.com/corsis/PortFusion.git -b master
cd    PortFusion
cabal configure
cabal build
```

### Flags

Following flags can be activated with `cabal configure -f llvm`.

| Flag     | Effect                      | Default | Official Binaries  |
|:---------|:----------------------------|:--------|:-------------------|
|          |                             |         |
| `llvm`   | compile via LLVM            | `false` | `true`

These are by default not activated to make PortFusion easy to compile for everyone :).


## Remember

### Trademark

```
PortFusion™ is a trademark of Corsis (corsis.eu).
```

### Trademark Policy

```
You may only distribute unchanged official binaries using the
PortFusion and Corsis Marks.

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

### License

[![GPLv3]](http://beta.corsis.eu/license/)

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


## Know

### Principles

Development follows simple principles:

1. Be concise: [PortFusion is a single-file with less than 500 lines of code](https://github.com/corsis/PortFusion/blob/master/src/Main.hs)
2. Refactor and prune *constantly*
3. Push and keep code where it belongs
 1. Create [fully documented reusable libraries](http://hackage.haskell.org/package/splice) that [cover common needs](http://stackoverflow.com/questions/10080670/using-gnu-linux-system-call-splice-for-zero-copy-socket-to-socket-data-transfe)
 2. [Report bugs and work on fixes](https://github.com/haskell/network/issues/31)
4. Share *everything*
 1. [Use the most permissive licenses possible](http://hackage.haskell.org/package/splice)
 2. [Illustrate every concept in detail worthy of books](#illustrate)
5. [Provide excellent support](https://sourceforge.net/p/portfusion/discussion/general/thread/7ad0cb49/)
6. Grow true to your principles

### Family

We hope to grow a whole family of software-defined networking solutions reaching
all network layers, technologies and devices.


## Thanks

For their support and inspiration, we extend our heart-felt thanks to:

<div style='vertical-align: middle'>
<img alt='Internet Initiative Japan'                  title='Internet Initiative Japan'                                src='http://www.iij.ad.jp/en/common/images/hd_logo01.png' />
<img alt='Commercial Users of Functional Programming' title='Commercial Users of Functional Programming' height='96px' src='http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/cufp.png' />
<img alt='Japan Aerospace Exploration Agency'         title='Japan Aerospace Exploration Agency'                       src='http://upload.wikimedia.org/wikipedia/en/thumb/8/85/Jaxa_logo.svg/160px-Jaxa_logo.svg.png' />
</div>


## Contact

[![corsis]](https://github.com/corsis/)

[fusion@corsis.eu](mailto:fusion@corsis.eu)

[corsis]: http://portfusion.sourceforge.net/i/l100.png "Corsis Research"

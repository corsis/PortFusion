![pf]
[pf]: http://fusion.corsis.eu/i/h.png "PortFusion"

### <a href='http://sourceforge.net/projects/portfusion/files/1.2.1/#files'><img src='http://fusion.corsis.eu/i/down_16.png' /> Download 1.2.1</a> <span style="font-size: small">(for Windows, Linux, OS X and FreeBSD, ...)</span>

---

PortFusion is a minimalistic, cross-platform, transport-layer distributed
reverse / forward proxy and tunneling solution for TCP released under
[GPLv3](#license).

A single package that makes the most of each platform by tapping into their
unique capabilities, combining this power with an intuitive interface, beautiful
design and [Haskell]'s excellent support for unprecedented levels of concurrency
and parallelism.

It strives for the smallest source code size while delivering maximum throughput
with near-zero overhead.

---
[Today, a growing number of companies and institutions around the world use PortFusion.](https://github.com/corsis/PortFusion/wiki/Users)

---

## Use

PortFusion is a tiny command line application.

| Distributed Reverse Proxy Mode  | Distributed Forward Proxy Mode |
|:--------------------------------|:-------------------------------|
| |
| <p>Work from home using [remote desktop services](http://en.wikipedia.org/wiki/Remote_Desktop_Services) circumventing corporate firewalls.</p> | <p>Connect to the internet through a http proxy via a gateway to a friend's intranet.</p>
| |
| `↓ home ↓` <pre>PortFusion                ] 2000      [</pre><pre>PortFusion 3389 localhost - 2000 home [ 3389</pre> `↑ work ↑` | `↓ friend ↓` <pre>PortFusion      ]        2000 [</pre><pre>PortFusion 3128 ] friend 2000 - server 3128</pre> `↑ you ↑`
| |
| <p>Connections to `home:3389` will now be tunnelled and reach `work:3389`.</p> <p>You only need to make `home:2000` accessible from work.</p> | <p>Connections to `you:3128` will now be tunnelled and reach `server:3128`.</p> <p>Your friend only needs to make `friend:2000` accessible.</p>
| |
| <a name='illustrate' class='anchor' href='#illustrate' /> [<img src="http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/dr1.png" />](http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/dr1.png) | [<img src="http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/df2.png" />](http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/df2.png)
| |
| [<img width='100%' src="http://portfusion.sourceforge.net/i/reverse-fusion-msc-8.png" alt="DR" />](http://portfusion.sourceforge.net/i/reverse-fusion-msc-8.png) | [<img width='100%' src="http://portfusion.sourceforge.net/i/forward-fusion-msc-8.png" alt="DF" />](http://portfusion.sourceforge.net/i/forward-fusion-msc-8.png)


## Build

### Prerequisites

You need only *one* of the following rows for compilation.

| Remarks | OS           | Compilers           |
|:--------|:-------------|:--------------------|
| recommended and <br /> used for official binaries | ![Windows], ![Linux], ![OSX], ![FreeBSD], ![OpenBSD], ![Solaris], ![Other] | [GHC] >= 7.4 <br /> [LLVM] >= 3
| easy to install for <br /> all Haskell newbies    | ![Windows], ![Linux], ![OSX] | [Haskell Platform] >= 2012.2.0.0

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

Following flags can be activated when using `cabal configure -f <FLAG>` or `cabal install -f <FLAG>`.

| Flag  | Effect             | Default | Official Binaries  |
|:------|:-------------------|:--------|:-------------------|
|       |                    |         |
| `llvm`| compile via [LLVM] | `false` | `true`


## Download

### Binaries

| <img height='48px' alt='CPU' title='CPU' src='http://a.fsdn.com/sd/topics/hardware_64.png' /> | ![Windows]                                                                                    | ![Linux]                                                                                      | ![OSX]                                                                                        | ![FreeBSD]                                                                                    | ![OpenBSD] | ![Solaris] | ![Other]
| --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------- | ---------- | --------
| x86-64                                                                                        | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | ![C]       | ![C]       | ![C]
| x86-32                                                                                        | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> |                                                                                               | ![C]                                                                                          | ![C]       | ![C]       | ![C]
| ARM                                                                                           | ![B]                                                                                          | <a href='http://fusion.corsis.eu'><img src='http://fusion.corsis.eu/i/down_16.png' /> Get</a> | ![C]                                                                                          | ![C]                                                                                          | ![C]       | ![C]       | ![C]
| MIPS                                                                                          |                                                                                               | ![B]                                                                                          |                                                                                               |                                                                                               |            |            |    
| Other                                                                                         |                                                                                               | ![C]                                                                                          |                                                                                               | ![C]                                                                                          | ![C]       | ![C]       | ![C]

CORSIS Research <br />
![D] builds official binaries <br />
![B] will build official binaries on demand  <br />
![C] can cooperate with community for builds <br />

[D]: http://fusion.corsis.eu/i/down_16.png "Download"
[B]: http://res2.windows.microsoft.com/resbox/en/Windows%207/main/33624ed4-7676-4be4-9f47-d77eab7ecd9c_0.gif "Build-on-Demand"
[C]: http://res2.windows.microsoft.com/resbox/en/Windows%207/main/43fa1e85-5152-43ff-b0f7-63ae6520a88b_0.gif "Coop-on-Demand"

#### Support

If you have access to an OS+CPU combination lacking official binaries,
please [contact us](#contact) to join our build team!

### Packages

[PortFusion](http://hackage.haskell.org/package/PortFusion) is available and can be very easily installed from [Hackage](http://hackage.haskell.org/package/PortFusion):

````bash
cabal update
cabal install splice      -f llvm
cabal install PortFusion  -f llvm
````

If you do not have [LLVM] installed, you can drop `-f llvm`.


## Compare

```
This is the new Haskell source code repository of the latest ]-[ayabusa version
– a complete rewrite of the initial Windows-only versions developed in F# / C#.
```

### What is new in `]-[ayabusa`?

PortFusion          | 0.9.3 – old                     | 1.2.1 – \]-[ayabusa
--------------------|---------------------------------|-------------------------------
Memory at Start-up  | ~14 MB                          | **~0.7 MB**
Memory at 1 Fusion  | ~30 MB (lots of jumps)          | **~1.0 MB** (constant)
OS Support          | ![Windows]                      | ![Windows], ![Linux], ![OSX], ![FreeBSD], ![OpenBSD], ![Solaris], ![Other]
Official Binaries   | ![Windows]                      | ![Windows], ![Linux], ![OSX], ![FreeBSD]
Source Code Size    | 778 lines (multiple files)      | **< 500 lines (1 file)**
Language            | F# / C#                         | **[Haskell] \([GHC] / [LLVM]\)**
Dependencies        | .NET 4.0 + F# 2.0 Runtime       | **none**
Deployment          | 2 .NET 4.0 managed binaries     | **1 unified, native code binary for each platform**
Binary Size         | **78.3 KB** (34.3 KB + 44 KB)   | 1-2 MB (~400 KB compressed)
Concurrency Model   | 1 OS thread per connection      | **1 Haskell thread per connection**
Distribution Technique | Windows Communication Foundation | **native sockets API and system calls of each OS**
Distributed Proxy Modes | reverse                     | **reverse, forward**
Local Proxy Modes   |                                 | **forward**
Native IPv6 Support | **yes**                         | **yes**
Interactive Mode    |                                 | [**REPL in GHCi**](https://github.com/corsis/PortFusion/wiki/PortFusion-REPL)
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


## Remember

### Trademark

```
PortFusion™ is a trademark of Corsis Research (corsis.eu).
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
© 2011 - 2013     Cetin Sert
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
2. Be relentless: [refactor and prune *constantly*](https://github.com/corsis/PortFusion/compare/v1.0...master#diff-9)
4. Be open: share everything
 1. Create [fully documented reusable libraries](http://hackage.haskell.org/package/splice) that [cover common needs](http://stackoverflow.com/questions/10080670/using-gnu-linux-system-call-splice-for-zero-copy-socket-to-socket-data-transfe)
 2. [Use the most permissive licenses possible](http://hackage.haskell.org/package/splice)
 3. Report [bugs in external code](http://hackage.haskell.org/trac/ghc/ticket/7134) and [work on fixes](https://github.com/haskell/network/issues/31)
 4. [Illustrate every concept in publication-worthy detail](#illustrate)
5. Be friendly: [provide excellent support to users](https://sourceforge.net/p/portfusion/discussion/general/thread/7ad0cb49/)

### Japanese Influence: ]-[ayabusa (はやぶさ) (Hayabusa)

I had already spent a great deal of time contemplating a nice and intuitive
syntax and it was only when I watched the Japanese movie
[Hayabusa](http://www.dramacrazy.net/japanese-movie/hayabusa/) about [the
same-named space probe](http://en.wikipedia.org/wiki/Hayabusa) sent to extract
and bring to Earth pieces from the asteroid Itokawa that everything just fell
into place:

```
# command line  # source file

  ] [             :><:          # serve
  - [             :-<:          # reverse
  ] -             :>-:          # forward

# > and < are reserved characters at command line
# ] and [ are reserved characters in Haskell
```

PortFusion owes its design goals, ambitions and 1.0 release name ]-[ayabusa
to the great Japanese culture and friends.



### Family

We hope to grow a whole family of software-defined networking solutions reaching
all network layers, technologies and devices.


## Thanks

For their continuing support and inspiration, we extend our heart-felt thanks to:

<div style='vertical-align: middle'>
<img alt='Internet Initiative Japan'                  title='Internet Initiative Japan'                                src='http://www.iij.ad.jp/en/common/images/hd_logo01.png' />
<img alt='Commercial Users of Functional Programming' title='Commercial Users of Functional Programming' height='96px' src='http://portfusion.sourceforge.net/w/wp-content/uploads/2012/05/cufp.png' />
<img alt='Japan Aerospace Exploration Agency'         title='Japan Aerospace Exploration Agency'                       src='http://upload.wikimedia.org/wikipedia/en/thumb/8/85/Jaxa_logo.svg/160px-Jaxa_logo.svg.png' />
</div>

----

## Contact

[![corsis]](https://github.com/corsis/)

[fusion@corsis.eu](mailto:fusion@corsis.eu)

[corsis]: http://portfusion.sourceforge.net/i/l100.png "Corsis Research"

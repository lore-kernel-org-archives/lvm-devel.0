From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Tue, 26 Sep 2023 21:53:59 +0200
Subject: [PATCH] autoconf: handle the standard --disable-shared flag
In-Reply-To: <20230922064737.31282-2-adam@westernsemico.com>
References: <20230922064737.31282-2-adam@westernsemico.com>
Message-ID: <e0bc7bc7-027b-45d6-84a2-c73bf68672c4@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 22. 09. 23 v 8:47 Adam Joseph napsal(a):
> Since LVM 2.02 it appears that compiling LVM on a platform which
> lacks a shared library linker/loader will fail to produce any
> binaries (dmsetup, lvm2, etc).
> 
> This commit adds support for the standard --disable-shared flag, and
> uses it to disable attempts at building shared libraries.
> ---
>   configure.ac               | 9 +++++++++
>   libdm/Makefile.in          | 7 +++++++
>   libdm/dm-tools/Makefile.in | 9 +++++++++
>   libdm/make.tmpl.in         | 6 ++++++
>   make.tmpl.in               | 4 ++++
>   5 files changed, 35 insertions(+)
> 

Hi

The main problem with supporting anything for 'static' linkage is rather a 
lack of 'known' system that can be build with 'static' library of all other 
used libraries - and actually be usable.

I.e.  static udev or static systemd  must be some kind of unicorn I'd like to 
see myself.

So what is the system you are using ?

How is the lvm2 usable there ?

What libraries are present for usage ?

Do you purly target to have  'libdm' portion to be linked as static
(aka only 'dmsetup' resulting binary - or do you need 'dmeventd' ,
or mayby  libdevmapper.a  ?)


Regards

Zdenek



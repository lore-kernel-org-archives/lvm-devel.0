From: Christine Caulfield <ccaulfie@redhat.com>
Date: Thu, 30 Jul 2009 09:00:27 +0100
Subject: [Fwd: Re: [Cluster-devel] LVM2 clvmd and STABLE3]
Message-ID: <4A71531B.3090300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Can someone have a look at this please ? I'll help on IRC if needed, but 
the autoconf system in lvm is something I'd rather keep clear of!

Basically it needs pkg-config calls for libcpg libconfdb and libquorum 
for the corosync option.

Thanks,

Chrissie

-------- Original Message --------
Subject: Re: [Cluster-devel] LVM2 clvmd and STABLE3
Date: Thu, 30 Jul 2009 09:45:24 +0200
From: Marc - A. Dahlhaus [ Administration | Westermann GmbH ] <mad@wol.de>
To: Chrissie Caulfield <ccaulfie@redhat.com>
CC: cluster-devel <cluster-devel@redhat.com>

Am Dienstag, den 10.03.2009, 16:50 +0000 schrieb Chrissie Caulfield:
> Marc - A. Dahlhaus wrote:
> > Chrissie Caulfield schrieb:
> >> Marc - A. Dahlhaus [ Administration | Westermann GmbH ] wrote:
> >>
> >>> Hello,
> >>>
> >>>
> >>> what is the right approach to build LVM2 with STABLE3,
> >>> a build with --with-clvmd=corosync or --with-clvmd=cman ?
> >>>
> >>>
> >>
> >> I recommend you do both.
> >>
> >>   --with-clvmd=corosync=cman,corosync
> >>
> > sounds nice but it doesn't build.
> > I use the last released tarballs of STABLE3, corosync, openais and LVM2.
> > I tested the following:
> >
> > --with-clvmd=corosync=cman,corosync
> > --with-clvmd=cman,corosync
> > --with-clvmd=corosync,cman
> >
> > All end up with:
> >
> > gcc -m32 -o clvmd clvmd-command.o clvmd.o lvm-functions.o
> > refresh_clvmd.o clvmd-cman.o clvmd-corosync.o -march=i686 -mtune=generic
> > -O2 -pipe -march=i686 -mtune=generic -O2 -pipe -fPIC -Wall -Wundef
> > -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes
> > -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn
> > -Wformat-security -O2 -march=i686 -mtune=generic -O2 -pipe -fPIC -Wall
> > -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes
> > -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn
> > -Wformat-security -O2    -fno-strict-aliasing -march=i686 -mtune=generic
> > -O2 -pipe -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings
> > -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline
> > -Wmissing-noreturn -Wformat-security -O2 -Wl,--export-dynamic
> > -L../../libdm -L../../lib -L../../daemons/dmeventd \
> >                -llvm -lpthread -ldevmapper-event -ldevmapper -ldlm
> > -lcman    -ldlm -lreadline -lrt -ldl -lncurses
> > clvmd-corosync.o: In function `_get_cluster_name':
> > clvmd-corosync.c:(.text+0x695): undefined reference to `confdb_initialize'
> > clvmd-corosync.c:(.text+0x6c6): undefined reference to
> > `confdb_object_find_start'
> > clvmd-corosync.c:(.text+0x6dd): undefined reference to `confdb_finalize'
> > clvmd-corosync.c:(.text+0x727): undefined reference to `confdb_object_find'
> > clvmd-corosync.c:(.text+0x769): undefined reference to `confdb_key_get'
> > clvmd-corosync.o: In function `_cluster_closedown':
> > clvmd-corosync.c:(.text+0x7e9): undefined reference to `cpg_finalize'
> > clvmd-corosync.c:(.text+0x801): undefined reference to `quorum_finalize'
> > clvmd-corosync.o: In function `_is_quorate':
> > clvmd-corosync.c:(.text+0x98d): undefined reference to `quorum_getquorate'
> > clvmd-corosync.o: In function `_get_main_cluster_fd':
> > clvmd-corosync.c:(.text+0xadd): undefined reference to `cpg_fd_get'
> > clvmd-corosync.o: In function `_cluster_fd_callback':
> > clvmd-corosync.c:(.text+0xb30): undefined reference to `cpg_dispatch'
> > clvmd-corosync.o: In function `_cluster_send_message':
> > clvmd-corosync.c:(.text+0xc12): undefined reference to `cpg_mcast_joined'
> > clvmd-corosync.o: In function `init_corosync_cluster':
> > clvmd-corosync.c:(.text+0xc80): undefined reference to `cpg_initialize'
> > clvmd-corosync.c:(.text+0xcec): undefined reference to `quorum_initialize'
> > clvmd-corosync.c:(.text+0xdb9): undefined reference to `cpg_join'
> > clvmd-corosync.c:(.text+0xddc): undefined reference to `cpg_finalize'
> > clvmd-corosync.c:(.text+0xdf4): undefined reference to `quorum_finalize'
> > clvmd-corosync.c:(.text+0xe66): undefined reference to `cpg_local_get'
> > clvmd-corosync.c:(.text+0xe89): undefined reference to `cpg_finalize'
> > clvmd-corosync.c:(.text+0xea1): undefined reference to `quorum_finalize'
> > clvmd-corosync.c:(.text+0xf1c): undefined reference to `quorum_finalize'
> >
> > The full configure line for reference:
> >
> > ./configure --enable-cmdlib --enable-dmeventd --enable-pkgconfig \
> >     --disable-selinux --with-clvmd=corosync,cman --with-lvm1=shared \
> >     --with-cluster=shared --with-pool=shared \
> >     --with-snapshots=shared --with-mirrors=internal
> >
>
>
> Oh, the Make system still needs to be finished. I left that to the LVM
> maintainers as I'm not good with Makefiles ... people always seem to
> feel the need to tidy up after me.
>
> You can add -L /usr/lib/corosync -lcpg -lquorum -lconfdb to the linker
> command-line. or /usr/lib64/corosync for 64bit systems. If you feel the
> urge.
>

Hello Chrissie,

the buildsystem of lvm2 sill (as of version 2.02.50) doesn't link when
using --with-clvmd=cman,corosync

We plan to move over to stable3 on our test-systems and i'm unsure if i
should switch from cman to corosync for clvmd during the change...

What is the best choice in this case?

What is the value of --with-clvmd on rawhide for cluster3?

What differences we have to expect between these two options?

I think a default value of "auto" for --with-clvmd which uses the best
bindings it could find on a system would be nice...



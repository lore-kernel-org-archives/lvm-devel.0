From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:21 +0200
Subject: Cleanup clvmd build
Message-ID: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clvmd build needs to be a bit more robust and some of the options
really don't make much sense together.

The following patchset cleans it up and does better checkes on
build requirements.

I split the patch in several chunks to make it easier to review
but in theory it should all go in together to have a real benefit.

I'd be glad if people could review and apply as appropriate
(I don't have CVS commit access).

$ git diff --stat master..HEAD
 configure.in                   |  160 ++++++++++++++++++++++++++++++++++++---
 daemons/clvmd/Makefile.in      |   58 ++++++---------
 daemons/clvmd/clvmd-comms.h    |    4 +-
 daemons/clvmd/clvmd-corosync.c |   16 ++--
 daemons/clvmd/clvmd-openais.c  |   49 +++++++------
 5 files changed, 207 insertions(+), 80 deletions(-)

Here below are the test results stressing all the code paths.
The Fedora results are the same for F10/F11 and rawhide. I attached only one
for all to avoid extra 27KB of redundant data.

Thanks
Fabio

*** RHEL4 ***

$ ./configure

checking whether to build cluster LVM daemon... none

$ ./configure --with-clvmd
(default to cman, libcman not installed - expected failure)

checking whether to build cluster LVM daemon... cman
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CMAN... no
checking libcman.h usability... no
checking libcman.h presence... no
checking for libcman.h... no
configure: error: bailing out

$ ./configure --with-clvmd
(default to cman, all dependencies installed)

checking whether to build cluster LVM daemon... cman
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CMAN... no
checking libcman.h usability... yes
checking libcman.h presence... yes
checking for libcman.h... yes
checking for cman_init in -lcman... yes
no pkg for libcman library, using -lcman
checking for CONFDB... no
checking corosync/confdb.h usability... no
checking corosync/confdb.h presence... no
checking for corosync/confdb.h... no
checking for DLM... no
checking libdlm.h usability... yes
checking libdlm.h presence... yes
checking for libdlm.h... yes
checking for dlm_lock in -ldlm... yes
no pkg for libdlm library, using -ldlm -lpthread

$ make && ldd daemons/clvmd/clvmd
[snip]
        libpthread.so.0 => /lib/tls/libpthread.so.0 (0x00b72000)
        libcman.so.DEVEL => /usr/lib/libcman.so.DEVEL (0x007a7000)
        libdlm.so.DEVEL => /usr/lib/libdlm.so.DEVEL (0x007d0000)
[snip]

$ ./configure --with-clvmd=all
(default to cman)

checking whether to build cluster LVM daemon... cman

$ ./configure --with-clvmd=cman

checking whether to build cluster LVM daemon... cman

$ ./configure --with-clvmd=gulm

checking whether to build cluster LVM daemon... gulm
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CCS... no
checking ccs.h usability... yes
checking ccs.h presence... yes
checking for ccs.h... yes
checking for ccs_connect in -lccs... yes
no pkg for libccs library, using -lccs
checking for GULM... no
checking libgulm.h usability... yes
checking libgulm.h presence... yes
checking for libgulm.h... yes
checking for lg_core_login in -lgulm... yes
no pkg for libgulm library, using -lgulm

$ make && ldd daemons/clvmd/clvmd
[snip]
        libgulm.so.DEVEL => /usr/lib/libgulm.so.DEVEL (0x00552000)
[snip]

$ ./configure --with-clvmd=gulm,cman
(tested both with cman,gulm and gulm,cman)

checking whether to build cluster LVM daemon... gulm,cman
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CCS... no
checking ccs.h usability... yes
checking ccs.h presence... yes
checking for ccs.h... yes
checking for ccs_connect in -lccs... yes
no pkg for libccs library, using -lccs
checking for GULM... no
checking libgulm.h usability... yes
checking libgulm.h presence... yes
checking for libgulm.h... yes
checking for lg_core_login in -lgulm... yes
no pkg for libgulm library, using -lgulm
checking for CMAN... no
checking libcman.h usability... yes
checking libcman.h presence... yes
checking for libcman.h... yes
checking for cman_init in -lcman... yes
no pkg for libcman library, using -lcman
checking for CONFDB... no
checking corosync/confdb.h usability... no
checking corosync/confdb.h presence... no
checking for corosync/confdb.h... no
checking for DLM... no
checking libdlm.h usability... yes
checking libdlm.h presence... yes
checking for libdlm.h... yes
checking for dlm_lock in -ldlm... yes
no pkg for libdlm library, using -ldlm -lpthread

$ make && ldd daemons/clvmd/clvmd
[snip]
        libpthread.so.0 => /lib/tls/libpthread.so.0 (0x00b72000)
        libgulm.so.DEVEL => /usr/lib/libgulm.so.DEVEL (0x0076a000)
        libcman.so.DEVEL => /usr/lib/libcman.so.DEVEL (0x005a8000)
        libdlm.so.DEVEL => /usr/lib/libdlm.so.DEVEL (0x0063e000)
[snip]

$ ldd  tools/lvm
(no clvmd libraries leak into the build)
        libdevmapper.so.1.02 => /lib/libdevmapper.so.1.02 (0x00ab8000)
        librt.so.1 => /lib/tls/librt.so.1 (0x00aed000)
        libdl.so.2 => /lib/libdl.so.2 (0x00ab2000)
        libncurses.so.5 => /usr/lib/libncurses.so.5 (0x00230000)
        libc.so.6 => /lib/tls/libc.so.6 (0x00981000)
        libselinux.so.1 => /lib/libselinux.so.1 (0x00add000)
        libpthread.so.0 => /lib/tls/libpthread.so.0 (0x00b72000)
        /lib/ld-linux.so.2 (0x00967000)

*** RHEL5 ***

$ ./configure

checking whether to build cluster LVM daemon... none

$ ./configure --with-clvmd
(default to cman, libcman not installed - expected failure)

checking whether to build cluster LVM daemon... cman
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CMAN... no
checking libcman.h usability... no
checking libcman.h presence... no
checking for libcman.h... no
configure: error: bailing out

$ ./configure --with-clvmd
(default to cman, all dependencies installed)

checking whether to build cluster LVM daemon... cman
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CMAN... no
checking libcman.h usability... yes
checking libcman.h presence... yes
checking for libcman.h... yes
checking for cman_init in -lcman... yes
no pkg for libcman library, using -lcman
checking for CONFDB... no
checking corosync/confdb.h usability... no
checking corosync/confdb.h presence... no
checking for corosync/confdb.h... no
checking for DLM... no
checking libdlm.h usability... yes
checking libdlm.h presence... yes
checking for libdlm.h... yes
checking for dlm_lock in -ldlm... yes
no pkg for libdlm library, using -ldlm -lpthread

$ make && ldd daemons/clvmd/clvmd
[snip]
        libpthread.so.0 => /lib/libpthread.so.0 (0x003b0000)
        libcman.so.2 => /usr/lib/libcman.so.2 (0x00482000)
        libdlm.so.2 => /usr/lib/libdlm.so.2 (0x00474000)
[snip]

$ ./configure --with-clvmd=all
(default to cman)

checking whether to build cluster LVM daemon... cman

$ ./configure --with-clvmd=cman

checking whether to build cluster LVM daemon... cman

$ ldd tools/lvm
(no clvmd libraries leak into the build)
        linux-gate.so.1 =>  (0x0083b000)
        libdevmapper.so.1.02 => /lib/libdevmapper.so.1.02 (0x003c9000)
        libreadline.so.5 => /usr/lib/libreadline.so.5 (0x00489000)
        librt.so.1 => /lib/librt.so.1 (0x00469000)
        libselinux.so.1 => /lib/libselinux.so.1 (0x003f2000)
        libsepol.so.1 => /lib/libsepol.so.1 (0x0040c000)
        libdl.so.2 => /lib/libdl.so.2 (0x003aa000)
        libncurses.so.5 => /usr/lib/libncurses.so.5 (0x0057e000)
        libc.so.6 => /lib/libc.so.6 (0x00264000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x003b0000)
        /lib/ld-linux.so.2 (0x00246000)

*** Fedora 10/11/rawhide ***

$ ./configure

checking whether to build cluster LVM daemon... none

$ ./configure --with-clvmd
(default to cman, libcman not installed - expected failure)

checking whether to build cluster LVM daemon... cman
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CMAN... no
checking libcman.h usability... no
checking libcman.h presence... no
checking for libcman.h... no
configure: error: bailing out

$ ./configure --with-clvmd
(default to cman, use pkg-config)

checking whether to build cluster LVM daemon... cman
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CMAN... yes
checking for CONFDB... yes
checking corosync/confdb.h usability... yes
checking corosync/confdb.h presence... yes
checking for corosync/confdb.h... yes
checking for DLM... yes

$ make && ldd daemons/clvmd/clvmd
[snip]
        libpthread.so.0 => /lib/libpthread.so.0 (0x00583000)
        libcman.so.3 => /usr/lib/libcman.so.3 (0x00d9a000)
        libconfdb.so.4 => /usr/lib/libconfdb.so.4 (0x00234000)
        libdlm.so.3 => /usr/lib/libdlm.so.3 (0x002b0000)
        libcoroipcc.so.4 => /usr/lib/libcoroipcc.so.4 (0x008f6000)
[snip]

$ ldd tools/lvm
(no clvmd libraries leak into the build)
        linux-gate.so.1 =>  (0x00480000)
        libdevmapper.so.1.02 => /lib/libdevmapper.so.1.02 (0x004b1000)
        librt.so.1 => /lib/librt.so.1 (0x00137000)
        libdl.so.2 => /lib/libdl.so.2 (0x00e8c000)
        libtinfo.so.5 => /lib/libtinfo.so.5 (0x003be000)
        libc.so.6 => /lib/libc.so.6 (0x00931000)
        libselinux.so.1 => /lib/libselinux.so.1 (0x008ce000)
        libsepol.so.1 => /lib/libsepol.so.1 (0x00141000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00110000)
        /lib/ld-linux.so.2 (0x00276000)

$ ./configure --with-clvmd=all
(default to cman)

checking whether to build cluster LVM daemon... cman

$ ./configure --with-clvmd=cman

checking whether to build cluster LVM daemon... cman

$ ./configure --with-clvmd=corosync
(all dependencies installed)

checking whether to build cluster LVM daemon... corosync
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for COROSYNC... yes
checking for QUORUM... yes
checking for CONFDB... yes
checking corosync/confdb.h usability... yes
checking corosync/confdb.h presence... yes
checking for corosync/confdb.h... yes
checking for CPG... yes
checking for DLM... yes

$ make && ldd daemons/clvmd/clvmd
[snip]
        libpthread.so.0 => /lib/libpthread.so.0 (0x0050a000)
        libconfdb.so.4 => /usr/lib/libconfdb.so.4 (0x005ec000)
        libcpg.so.4 => /usr/lib/libcpg.so.4 (0x00b61000)
        libdlm.so.3 => /usr/lib/libdlm.so.3 (0x007cd000)
        libquorum.so.4 => /usr/lib/libquorum.so.4 (0x0020b000)
        libcoroipcc.so.4 => /usr/lib/libcoroipcc.so.4 (0x00606000)
[snip]

$ ldd tools/lvm
(no clvmd libraries leak into the build)
        linux-gate.so.1 =>  (0x00bf4000)
        libdevmapper.so.1.02 => /lib/libdevmapper.so.1.02 (0x00ef4000)
        librt.so.1 => /lib/librt.so.1 (0x00585000)
        libdl.so.2 => /lib/libdl.so.2 (0x00be9000)
        libtinfo.so.5 => /lib/libtinfo.so.5 (0x00dc8000)
        libc.so.6 => /lib/libc.so.6 (0x00110000)
        libselinux.so.1 => /lib/libselinux.so.1 (0x00ecc000)
        libsepol.so.1 => /lib/libsepol.so.1 (0x007e2000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x005b2000)
        /lib/ld-linux.so.2 (0x00ea6000)

$ ./configure --with-clvmd=corosync
(without confdb - expected failure)

checking whether to build cluster LVM daemon... corosync
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for COROSYNC... yes
checking for QUORUM... yes
checking for CONFDB... no
configure: error: bailing out... confdb library is required

$ ./configure --with-clvmd=openais
(without confdb - optional)

checking whether to build cluster LVM daemon... openais
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for COROSYNC... yes
checking for SALCK... yes
checking for CONFDB... no
checking corosync/confdb.h usability... no
checking corosync/confdb.h presence... no
checking for corosync/confdb.h... no
checking for CPG... yes

$ make && ldd daemons/clvmd/clvmd
[snip]
        libcpg.so.4 => /usr/lib/libcpg.so.4 (0x00429000)
        libSaLck.so.3 => /usr/lib/libSaLck.so.3 (0x001b9000)
        libcoroipcc.so.4 => /usr/lib/libcoroipcc.so.4 (0x0075c000)
[snip]

$ ldd tools/lvm
(no clvmd libraries leak into the build)
	linux-gate.so.1 =>  (0x0075b000)
        libdevmapper.so.1.02 => /lib/libdevmapper.so.1.02 (0x00862000)
        librt.so.1 => /lib/librt.so.1 (0x00fa5000)
        libdl.so.2 => /lib/libdl.so.2 (0x0094e000)
        libtinfo.so.5 => /lib/libtinfo.so.5 (0x007f0000)
        libc.so.6 => /lib/libc.so.6 (0x00110000)
        libselinux.so.1 => /lib/libselinux.so.1 (0x0097e000)
        libsepol.so.1 => /lib/libsepol.so.1 (0x00f24000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x0040b000)
        /lib/ld-linux.so.2 (0x00e45000)

$ ./configure --with-clvmd=openais

checking whether to build cluster LVM daemon... openais
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for COROSYNC... yes
checking for SALCK... yes
checking for CONFDB... yes
checking corosync/confdb.h usability... yes
checking corosync/confdb.h presence... yes
checking for corosync/confdb.h... yes
checking for CPG... yes

$ make && ldd daemons/clvmd/clvmd
[snip]
        libconfdb.so.4 => /usr/lib/libconfdb.so.4 (0x00cac000)
        libcpg.so.4 => /usr/lib/libcpg.so.4 (0x00952000)
        libSaLck.so.3 => /usr/lib/libSaLck.so.3 (0x008dd000)
        libcoroipcc.so.4 => /usr/lib/libcoroipcc.so.4 (0x00a8a000)
[snip]

$ ldd tools/lvm
(no clvmd libraries leak into the build)
        linux-gate.so.1 =>  (0x00f4d000)
        libdevmapper.so.1.02 => /lib/libdevmapper.so.1.02 (0x005d4000)
        librt.so.1 => /lib/librt.so.1 (0x001e7000)
        libdl.so.2 => /lib/libdl.so.2 (0x00630000)
        libtinfo.so.5 => /lib/libtinfo.so.5 (0x00747000)
        libc.so.6 => /lib/libc.so.6 (0x001f1000)
        libselinux.so.1 => /lib/libselinux.so.1 (0x00e4d000)
        libsepol.so.1 => /lib/libsepol.so.1 (0x0097d000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00496000)
        /lib/ld-linux.so.2 (0x00914000)

$ ./configure --with-clvmd=corosync,cman

checking whether to build cluster LVM daemon... corosync,cman
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CMAN... yes
checking for COROSYNC... yes
checking for QUORUM... yes
checking for CONFDB... yes
checking corosync/confdb.h usability... yes
checking corosync/confdb.h presence... yes
checking for corosync/confdb.h... yes
checking for CPG... yes
checking for DLM... yes

$ make && ldd daemons/clvmd/clvmd
[snip]
        libcman.so.3 => /usr/lib/libcman.so.3 (0x00b77000)
        libconfdb.so.4 => /usr/lib/libconfdb.so.4 (0x00697000)
        libdlm.so.3 => /usr/lib/libdlm.so.3 (0x006b8000)
        libcpg.so.4 => /usr/lib/libcpg.so.4 (0x0040d000)
        libquorum.so.4 => /usr/lib/libquorum.so.4 (0x0072d000)
        libcoroipcc.so.4 => /usr/lib/libcoroipcc.so.4 (0x00a43000)
[snip]

$ ldd tools/lvm
(no clvmd libraries leak into the build)
        linux-gate.so.1 =>  (0x00cc5000)
        libdevmapper.so.1.02 => /lib/libdevmapper.so.1.02 (0x0024c000)
        librt.so.1 => /lib/librt.so.1 (0x00a0e000)
        libdl.so.2 => /lib/libdl.so.2 (0x00224000)
        libtinfo.so.5 => /lib/libtinfo.so.5 (0x00405000)
        libc.so.6 => /lib/libc.so.6 (0x00264000)
        libselinux.so.1 => /lib/libselinux.so.1 (0x004b7000)
        libsepol.so.1 => /lib/libsepol.so.1 (0x0070f000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00177000)
        /lib/ld-linux.so.2 (0x00556000)

$ ./configure --with-clvmd=corosync,openais

checking whether to build cluster LVM daemon... corosync,openais
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for COROSYNC... yes
checking for QUORUM... yes
checking for SALCK... yes
checking for CONFDB... yes
checking corosync/confdb.h usability... yes
checking corosync/confdb.h presence... yes
checking for corosync/confdb.h... yes
checking for CPG... yes
checking for DLM... yes

$ make && ldd daemons/clvmd/clvmd
[snip]
        libconfdb.so.4 => /usr/lib/libconfdb.so.4 (0x00c1e000)
        libcpg.so.4 => /usr/lib/libcpg.so.4 (0x00633000)
        libSaLck.so.3 => /usr/lib/libSaLck.so.3 (0x00a7b000)
        libdlm.so.3 => /usr/lib/libdlm.so.3 (0x00745000)
        libquorum.so.4 => /usr/lib/libquorum.so.4 (0x00334000)
        libcoroipcc.so.4 => /usr/lib/libcoroipcc.so.4 (0x00598000)
[snip]

$ ldd tools/lvm
(no clvmd libraries leak into the build)
        linux-gate.so.1 =>  (0x00660000)
        libdevmapper.so.1.02 => /lib/libdevmapper.so.1.02 (0x0024e000)
        librt.so.1 => /lib/librt.so.1 (0x0080f000)
        libdl.so.2 => /lib/libdl.so.2 (0x002bd000)
        libtinfo.so.5 => /lib/libtinfo.so.5 (0x00110000)
        libc.so.6 => /lib/libc.so.6 (0x002c2000)
        libselinux.so.1 => /lib/libselinux.so.1 (0x00aa2000)
        libsepol.so.1 => /lib/libsepol.so.1 (0x0020e000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00776000)
        /lib/ld-linux.so.2 (0x00b3b000)

$ ./configure --with-clvmd=cman,openais

checking whether to build cluster LVM daemon... cman,openais
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CMAN... yes
checking for COROSYNC... yes
checking for SALCK... yes
checking for CONFDB... yes
checking corosync/confdb.h usability... yes
checking corosync/confdb.h presence... yes
checking for corosync/confdb.h... yes
checking for CPG... yes
checking for DLM... yes

$ make && ldd daemons/clvmd/clvmd
[snip]
        libcman.so.3 => /usr/lib/libcman.so.3 (0x0018c000)
        libconfdb.so.4 => /usr/lib/libconfdb.so.4 (0x001ec000)
        libdlm.so.3 => /usr/lib/libdlm.so.3 (0x0012f000)
        libcpg.so.4 => /usr/lib/libcpg.so.4 (0x00a6d000)
        libSaLck.so.3 => /usr/lib/libSaLck.so.3 (0x00110000)
        libcoroipcc.so.4 => /usr/lib/libcoroipcc.so.4 (0x0055b000)
[snip]

$ ldd tools/lvm
(no clvmd libraries leak into the build)
        linux-gate.so.1 =>  (0x00ce0000)
        libdevmapper.so.1.02 => /lib/libdevmapper.so.1.02 (0x00a30000)
        librt.so.1 => /lib/librt.so.1 (0x00d76000)
        libdl.so.2 => /lib/libdl.so.2 (0x00bb7000)
        libtinfo.so.5 => /lib/libtinfo.so.5 (0x00afe000)
        libc.so.6 => /lib/libc.so.6 (0x00e66000)
        libselinux.so.1 => /lib/libselinux.so.1 (0x00810000)
        libsepol.so.1 => /lib/libsepol.so.1 (0x008f8000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00b8e000)
        /lib/ld-linux.so.2 (0x0034c000)

$ ./configure --with-clvmd=cman,corosync,openais

checking whether to build cluster LVM daemon... cman,corosync,openais
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for PKGCONFIGINIT... no
pkg-config initialized
checking for CMAN... yes
checking for COROSYNC... yes
checking for QUORUM... yes
checking for SALCK... yes
checking for CONFDB... yes
checking corosync/confdb.h usability... yes
checking corosync/confdb.h presence... yes
checking for corosync/confdb.h... yes
checking for CPG... yes
checking for DLM... yes

$ make && ldd daemons/clvmd/clvmd
[snip]
        libcman.so.3 => /usr/lib/libcman.so.3 (0x00a7f000)
        libconfdb.so.4 => /usr/lib/libconfdb.so.4 (0x0089d000)
        libdlm.so.3 => /usr/lib/libdlm.so.3 (0x00af9000)
        libcpg.so.4 => /usr/lib/libcpg.so.4 (0x00b30000)
        libSaLck.so.3 => /usr/lib/libSaLck.so.3 (0x00d44000)
        libquorum.so.4 => /usr/lib/libquorum.so.4 (0x00f5c000)
        libcoroipcc.so.4 => /usr/lib/libcoroipcc.so.4 (0x00927000)
[snip]

$ ldd tools/lvm
(no clvmd libraries leak into the build)
        linux-gate.so.1 =>  (0x00fa6000)
        libdevmapper.so.1.02 => /lib/libdevmapper.so.1.02 (0x00969000)
        librt.so.1 => /lib/librt.so.1 (0x00fca000)
        libdl.so.2 => /lib/libdl.so.2 (0x00cf4000)
        libtinfo.so.5 => /lib/libtinfo.so.5 (0x00364000)
        libc.so.6 => /lib/libc.so.6 (0x003f5000)
        libselinux.so.1 => /lib/libselinux.so.1 (0x008df000)
        libsepol.so.1 => /lib/libsepol.so.1 (0x002db000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00c2e000)
        /lib/ld-linux.so.2 (0x007f3000)

tested on RHEL4/RHEL5/Fedora:

./configure --with-clvmd=gulm,cman,openais
configure: error: requested clvmd configuration is not valid



From: Alexander Talos-Zens <at@univie.ac.at>
Date: Thu, 12 Feb 2015 14:43:24 +0000
Subject: errors compiling lvm with static linking
Message-ID: <54DCBC0C.1060500@univie.ac.at>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hej,

when building a statically linked lvm with libblkid from
util-linux-2.25.2 and glibc-2.21, I ran into two issues:

 * undefined reference to `pthread_mutex_lock' and unlock in libdevmapper.a
 * missing uuid_unparse() in libblkid (while it's source file works
around the (non)-existence of HAVE_LIBUUID, the library, once compiled
and installed, obviously doesn't)

The patch below did the trick for me, but may break the compile with
other versions of util-linux and possibly glibc.

HTH, best regards,

Alexander

--- LVM2.2.02.116/tools/Makefile.in     Thu Feb 12 15:32:32 2015
+++ LVM2.2.02.116/tools/Makefile.in.orig        Fri Jan 30 17:19:54 2015
@@ -128,7 +128,7 @@
 
 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
        $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
-             -o $@ dmsetup.o -ldevmapper $(STATIC_LIBS) $(LIBS)
$(PTHREAD_LIBS)
+             -o $@ dmsetup.o -ldevmapper $(STATIC_LIBS) $(LIBS)
 
 all: device-mapper
 
@@ -144,7 +144,7 @@
 
 lvm.static: $(OBJECTS) lvm-static.o
$(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
        $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
-             $(OBJECTS) lvm-static.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
$(PTHREAD_LIBS) -luuid
+             $(OBJECTS) lvm-static.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS)
lvmcmdlib.o lvm2cmd.o
        cat $(top_builddir)/lib/liblvm-internal.a > $@



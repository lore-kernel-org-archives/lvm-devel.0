From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Nov 2011 21:30:38 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in ./configure ./ ...
Message-ID: <20111114213038.6830.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-11-14 21:30:36

Modified files:
	.              : WHATS_NEW make.tmpl.in configure configure.in 
	tools          : Makefile.in 
	daemons/dmeventd: Makefile.in 

Log message:
	Make dmsetup.static and lvm.static build when dmeventd is disabled.
	udev may also need to be disabled if you didn't build it statically too.
	
	dmeventd.static could be fixed with some more work but I don't really see the
	point: without dlopen() it's useless, and if you have dlopen(), why not support
	normal shared libraries too?

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2182&r2=1.2183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/WHATS_NEW	2011/11/12 17:03:53	1.2182
+++ LVM2/WHATS_NEW	2011/11/14 21:30:35	1.2183
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix --enable-static_link unless using --enable-dmeventd / --enable-udev_sync.
   Move gentoo MAKEDEV to /sbin in lvm2create_initrd.
   Add filter to avoid scan of device if it is part of active multipath.
   Add missing default $LVM_VG_NAME usage for snapshots.
--- LVM2/make.tmpl.in	2011/08/12 12:56:38	1.122
+++ LVM2/make.tmpl.in	2011/11/14 21:30:35	1.123
@@ -35,6 +35,7 @@
 DEFS += @DEFS@
 CFLAGS += @CFLAGS@
 CLDFLAGS += @CLDFLAGS@
+ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
--- LVM2/configure	2011/09/24 20:57:49	1.159
+++ LVM2/configure	2011/11/14 21:30:35	1.160
@@ -643,6 +643,7 @@
 HAVE_REALTIME
 HAVE_LIBDL
 FSADM
+ELDFLAGS
 DM_LIB_PATCHLEVEL
 DM_LIB_VERSION
 DM_IOCTLS
@@ -2807,10 +2808,11 @@
 		CFLAGS="$CFLAGS"
 		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
+		ELDFLAGS="-Wl,--export-dynamic"
+		# FIXME Generate list and use --dynamic-list=.dlopen.sym
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
 		LDDEPS="$LDDEPS .export.sym"
-		LDFLAGS="$LDFLAGS -Wl,--export-dynamic"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		LVMETAD=no
@@ -2824,6 +2826,7 @@
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
 		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS"
+		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
 		LIB_SUFFIX=dylib
@@ -10211,6 +10214,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts!
 /Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
--- LVM2/configure.in	2011/09/24 20:57:49	1.173
+++ LVM2/configure.in	2011/11/14 21:30:35	1.174
@@ -31,10 +31,11 @@
 		CFLAGS="$CFLAGS"
 		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
+		ELDFLAGS="-Wl,--export-dynamic"
+		# FIXME Generate list and use --dynamic-list=.dlopen.sym
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
 		LDDEPS="$LDDEPS .export.sym"
-		LDFLAGS="$LDFLAGS -Wl,--export-dynamic"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		LVMETAD=no
@@ -48,6 +49,7 @@
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
 		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS"
+		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
 		LIB_SUFFIX=dylib
@@ -1342,6 +1344,7 @@
 AC_SUBST(DM_IOCTLS)
 AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
+AC_SUBST(ELDFLAGS)
 AC_SUBST(FSADM)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
--- LVM2/tools/Makefile.in	2011/09/24 21:00:53	1.123
+++ LVM2/tools/Makefile.in	2011/11/14 21:30:36	1.124
@@ -132,7 +132,7 @@
 all: device-mapper
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm.o \
+	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
 		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) -rdynamic
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
--- LVM2/daemons/dmeventd/Makefile.in	2011/09/24 21:00:52	1.46
+++ LVM2/daemons/dmeventd/Makefile.in	2011/11/14 21:30:36	1.47
@@ -60,11 +60,11 @@
 LVMLIBS += -ldevmapper-event $(PTHREAD_LIBS)
 
 dmeventd: $(LIB_SHARED) dmeventd.o
-	$(CC) $(CFLAGS) $(LDFLAGS) -L. -o $@ dmeventd.o \
+	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -L. -o $@ dmeventd.o \
 	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
+	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
 	dmeventd.o $(DL_LIBS) $(LVMLIBS) $(LIBS) $(STATIC_LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")



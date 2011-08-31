From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 31 Aug 2011 11:31:59 -0000
Subject: LVM2 ./configure.in daemons/Makefile.in daemon ...
Message-ID: <20110831113159.4167.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-08-31 11:31:58

Modified files:
	.              : configure.in 
	daemons        : Makefile.in 
	daemons/common : daemon-server.c 
	test           : Makefile.in 
	test/lib       : aux.sh test.sh 
Added files:
	daemons/lvmetad: Makefile.in 

Log message:
	A compromise integration of LVMetaD into the build: I have kept all the
	daemon/common code in a single libdaemon.a, which is completely private. This
	is currently linked into the lvmetad binary, and will be linked into LVM (the
	client part, since static linking only picks up only symbols that are actually
	used). I have also added --enable/disable-lvmetad to ./configure; although the
	current default is off, I expect this to be flipped to on shortly. There's no
	LVM-side support yet, but when there is, even when built, it'll still need to
	be enabled by an lvm.conf option.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/test.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/configure.in	2011/08/24 08:27:50	1.170
+++ LVM2/configure.in	2011/08/31 11:31:57	1.171
@@ -37,6 +37,7 @@
 		LDFLAGS="$LDFLAGS -Wl,--export-dynamic"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
+		LVMETAD=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -790,6 +791,17 @@
 fi
 
 ################################################################################
+dnl -- Build lvmetad
+AC_MSG_CHECKING(whether to build LVMetaD)
+AC_ARG_ENABLE(lvmetad,
+	      AC_HELP_STRING([--disable-lvmetad],
+			     [disable the LVM Metadata Daemon]),
+	      LVMETAD=$enableval)
+AC_MSG_RESULT($LVMETAD)
+
+BUILD_LVMETAD=$LVMETAD
+
+################################################################################
 dnl -- Enable udev synchronisation
 AC_MSG_CHECKING(whether to enable synchronisation with udev processing)
 AC_ARG_ENABLE(udev_sync,
@@ -1288,6 +1300,7 @@
 AC_SUBST(AWK)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
+AC_SUBST(BUILD_LVMETAD)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
 AC_SUBST(CLDFLAGS)
@@ -1401,6 +1414,7 @@
 daemons/dmeventd/plugins/raid/Makefile
 daemons/dmeventd/plugins/mirror/Makefile
 daemons/dmeventd/plugins/snapshot/Makefile
+daemons/lvmetad/Makefile
 doc/Makefile
 doc/example.conf
 include/.symlinks
--- LVM2/daemons/Makefile.in	2010/04/09 21:34:25	1.16
+++ LVM2/daemons/Makefile.in	2011/08/31 11:31:58	1.17
@@ -15,7 +15,10 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-.PHONY: dmeventd clvmd cmirrord
+LIB_STATIC=libdaemon.a
+SOURCES = common/daemon-shared.c common/daemon-server.c common/daemon-client.c
+
+.PHONY: dmeventd clvmd cmirrord lvmetad
 
 ifneq ("@CLVMD@", "none")
   SUBDIRS = clvmd
@@ -25,6 +28,10 @@
   SUBDIRS += cmirrord
 endif
 
+ifeq ("@BUILD_LVMETAD@", "yes")
+  SUBDIRS += lvmetad
+endif
+
 ifeq ("@BUILD_DMEVENTD@", "yes")
   SUBDIRS += dmeventd
 ifneq ("$(CFLOW_CMD)", "")
@@ -33,7 +40,7 @@
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = clvmd cmirrord dmeventd
+  SUBDIRS = clvmd cmirrord dmeventd lvmetad
 endif
 
 include $(top_builddir)/make.tmpl
@@ -41,3 +48,5 @@
 ifeq ("@BUILD_DMEVENTD@", "yes")
 device-mapper: dmeventd.device-mapper
 endif
+
+device-mapper: libdaemon.a
--- LVM2/daemons/common/daemon-server.c	2011/08/30 15:42:57	1.10
+++ LVM2/daemons/common/daemon-server.c	2011/08/31 11:31:58	1.11
@@ -247,13 +247,13 @@
 			fprintf(stderr, "error parsing request:\n %s\n", req.buffer);
 		response res = b->s.handler(b->s, b->client, req);
 		if (req.cft)
-			destroy_config_tree(req.cft);
+			dm_config_destroy(req.cft);
 		dm_free(req.buffer);
 
 		if (!res.buffer) {
 			dm_config_write_node(res.cft->root, buffer_line, &res);
 			buffer_rewrite(&res.buffer, "%s\n\n", NULL);
-			destroy_config_tree(res.cft);
+			dm_config_destroy(res.cft);
 		}
 
 		write_buffer(b->client.socket_fd, res.buffer, strlen(res.buffer));
/cvs/lvm2/LVM2/daemons/lvmetad/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/daemons/lvmetad/Makefile.in
+++ -	2011-08-31 11:31:59.219763000 +0000
@@ -0,0 +1,59 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This file is part of the device-mapper userspace tools.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU Lesser General Public License v.2.1.
+#
+# You should have received a copy of the GNU Lesser General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+SOURCES = lvmetad-core.c
+SOURCES2 = testclient.c
+
+TARGETS = lvmetad lvmetad-testclient
+
+.PHONY: install_lib_dynamic install_lib_static install_include \
+	install_pkgconfig install_dmeventd_dynamic install_dmeventd_static \
+	install_lib install_dmeventd
+
+INCLUDES += -I$(top_srcdir)/daemons/common/
+INSTALL_LVMETAD_TARGETS = install_lvmetad
+CLEAN_TARGETS = lvmetad lvmetad-testclient
+
+CFLOW_LIST = $(SOURCES)
+CFLOW_LIST_TARGET = $(LIB_NAME).cflow
+CFLOW_TARGET = lvmetad
+
+include $(top_builddir)/make.tmpl
+
+all: device-mapper
+device-mapper: $(TARGETS)
+
+LIBS += -ldevmapper -ldaemon -lpthread
+
+lvmetad: lvmetad-core.o
+	$(CC) $(CFLAGS) $(LDFLAGS) -L$(top_builddir)/daemons -o $@ lvmetad-core.o \
+	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
+
+# TODO: No idea. No idea how to test either.
+#ifneq ("$(CFLOW_CMD)", "")
+#CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
+#-include $(top_builddir)/libdm/libdevmapper.cflow
+#-include $(top_builddir)/lib/liblvm-internal.cflow
+#-include $(top_builddir)/lib/liblvm2cmd.cflow
+#-include $(top_builddir)/daemons/dmeventd/$(LIB_NAME).cflow
+#-include $(top_builddir)/daemons/dmeventd/plugins/mirror/$(LIB_NAME)-lvm2mirror.cflow
+#endif
+
+install_lvmetad: $(INSTALL_DMEVENTD_TARGETS)
+
+install: install_lvmetad
+
+install_device-mapper: install_lvmetad
--- LVM2/test/Makefile.in	2011/04/28 22:17:06	1.56
+++ LVM2/test/Makefile.in	2011/08/31 11:31:58	1.57
@@ -96,10 +96,11 @@
 	for i in lvm $$(cat ../tools/.commands); do \
 	  ln -fs lvm-wrapper lib/$$i; \
 	done
-	ln -s "$(abs_top_builddir)/tools/dmsetup" lib/dmsetup
-	ln -s "$(abs_top_builddir)/daemons/clvmd/clvmd" lib/clvmd
-	ln -s "$(abs_top_builddir)/daemons/dmeventd/dmeventd" lib/dmeventd
-	ln -s "$(abs_top_builddir)/scripts/vgimportclone.sh" lib/vgimportclone
+	ln -fs "$(abs_top_builddir)/tools/dmsetup" lib/dmsetup
+	ln -fs "$(abs_top_builddir)/daemons/clvmd/clvmd" lib/clvmd
+	ln -fs "$(abs_top_builddir)/daemons/dmeventd/dmeventd" lib/dmeventd
+	ln -fs "$(abs_top_builddir)/daemons/lvmetad/lvmetad" lib/lvmetad
+	ln -fs "$(abs_top_builddir)/scripts/vgimportclone.sh" lib/vgimportclone
 	touch $@
 
 clean:
--- LVM2/test/lib/aux.sh	2011/08/11 17:46:14	1.28
+++ LVM2/test/lib/aux.sh	2011/08/31 11:31:58	1.29
@@ -60,6 +60,21 @@
 	sleep 1
 }
 
+prepare_lvmetad() {
+	# skip if we don't have our own lvmetad...
+	(which lvmetad | grep $abs_builddir) || {
+		touch SKIP_THIS_TEST
+		exit 1
+	}
+
+	lvmconf "global/lvmetad = 1"
+
+	lvmetad -f "$@" &
+	echo "$!" > LOCAL_LVMETAD
+
+	sleep 1
+}
+
 teardown_devs() {
 	# Delete any remaining dm/udev semaphores
 	teardown_udev_cookies
@@ -145,6 +160,7 @@
     echo -n .
 
     test -f LOCAL_DMEVENTD && kill -9 "$(cat LOCAL_DMEVENTD)"
+    test -f LOCAL_LVMETAD && kill -9 "$(cat LOCAL_LVMETAD)"
 
     echo -n .
 
--- LVM2/test/lib/test.sh	2011/06/30 00:57:29	1.4
+++ LVM2/test/lib/test.sh	2011/08/31 11:31:58	1.5
@@ -54,6 +54,7 @@
 set -eE -o pipefail
 aux lvmconf
 aux prepare_clvmd
+aux prepare_lvmetad
 echo "@TESTDIR=$TESTDIR"
 echo "@PREFIX=$PREFIX"
 



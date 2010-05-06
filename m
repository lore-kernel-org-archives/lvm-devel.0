From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 May 2010 10:07:48 -0000
Subject: LVM2 ./make.tmpl.in daemons/dmeventd/plugins/m ...
Message-ID: <20100506100748.19199.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-06 10:07:47

Modified files:
	.              : make.tmpl.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	lib/format1    : Makefile.in 
	lib/format_pool: Makefile.in 
	lib/locking    : Makefile.in 
	lib/mirror     : Makefile.in 
	lib/snapshot   : Makefile.in 

Log message:
	Install plugins to subdirs
	
	Target install_dm_plugin installs files to libdir/device-mapper.
	Target install_lvm2_plugin installs files to libdir/lvm2.
	
	Both targets creates relative links to libdir to keep the code
	compatible with current dlopen handling.
	
	Once we will be able to read plugins from subdir, links
	could be removed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/Makefile.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/make.tmpl.in	2010/04/30 13:58:10	1.93
+++ LVM2/make.tmpl.in	2010/05/06 10:07:46	1.94
@@ -163,7 +163,7 @@
 
 .PHONY: all pofile distclean clean cleandir cflow device-mapper
 .PHONY: install install_cluster install_device-mapper install_lvm2
-.PHONY: install_lib_shared install_lib_shared_plugin
+.PHONY: install_lib_shared install_dm_plugin install_lvm2_plugin
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
@@ -306,9 +306,18 @@
 	$(INSTALL) -d $(usrlibdir)
 	$(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
 
-# FIXME: plugins are currently installed with .so suffix only
-install_lib_shared_plugin: $(LIB_SHARED)
-	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F)
+# FIXME: plugins are installed to subdirs 
+#        and for compatibility links in libdir are created
+#        when the code is fixed links could be removed.
+install_dm_plugin: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/device-mapper/$(<F)
+	$(LN_S) -f device-mapper/$(<F) $(libdir)/$(<F)
+	$(LN_S) -f $(<F) $(libdir)/$(<F).$(LIB_VERSION)
+
+install_lvm2_plugin: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/lvm2/$(<F)
+	$(LN_S) -f lvm2/$(<F) $(libdir)/$(<F)
+	$(LN_S) -f $(<F) $(libdir)/$(<F).$(LIB_VERSION)
 endif
 
 %.so: %.a
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/04/09 21:42:49	1.19
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/05/06 10:07:47	1.20
@@ -32,6 +32,6 @@
 
 LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
 
-install_lvm2: install_lib_shared_plugin
+install_lvm2: install_dm_plugin
 
 install: install_lvm2
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/04/09 21:42:49	1.14
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/05/06 10:07:47	1.15
@@ -28,6 +28,6 @@
 
 LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
 
-install_lvm2: install_lib_shared_plugin
+install_lvm2: install_dm_plugin
 
 install: install_lvm2
--- LVM2/lib/format1/Makefile.in	2010/04/09 21:42:50	1.14
+++ LVM2/lib/format1/Makefile.in	2010/05/06 10:07:47	1.15
@@ -30,4 +30,4 @@
 
 include $(top_builddir)/make.tmpl
 
-install: install_lib_shared_plugin
+install: install_lvm2_plugin
--- LVM2/lib/format_pool/Makefile.in	2010/04/09 21:42:50	1.10
+++ LVM2/lib/format_pool/Makefile.in	2010/05/06 10:07:47	1.11
@@ -27,4 +27,4 @@
 
 include $(top_builddir)/make.tmpl
 
-install: install_lib_shared_plugin
+install: install_lvm2_plugin
--- LVM2/lib/locking/Makefile.in	2010/04/09 21:42:50	1.8
+++ LVM2/lib/locking/Makefile.in	2010/05/06 10:07:47	1.9
@@ -23,4 +23,4 @@
 
 include $(top_builddir)/make.tmpl
 
-install install_cluster: install_lib_shared_plugin
+install install_cluster: install_lvm2_plugin
--- LVM2/lib/mirror/Makefile.in	2010/04/09 21:42:50	1.9
+++ LVM2/lib/mirror/Makefile.in	2010/05/06 10:07:47	1.10
@@ -23,4 +23,4 @@
 
 include $(top_builddir)/make.tmpl
 
-install: install_lib_shared_plugin
+install: install_lvm2_plugin
--- LVM2/lib/snapshot/Makefile.in	2010/04/09 21:42:50	1.9
+++ LVM2/lib/snapshot/Makefile.in	2010/05/06 10:07:47	1.10
@@ -23,4 +23,4 @@
 
 include $(top_builddir)/make.tmpl
 
-install: install_lib_shared_plugin
+install: install_lvm2_plugin



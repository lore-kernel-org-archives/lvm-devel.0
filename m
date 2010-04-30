From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 30 Apr 2010 16:36:55 +0200
Subject: Makefile updates for plugin installation
Message-ID: <4BDAEB07.5030402@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Author: Zdenek Kabelac <zkabelac@redhat.com>
Date:   Fri Apr 30 16:32:30 2010 +0200

    Install plugins to subdirs.

    install_dm_plugin  install files to libdir/device-mapper
    install_lvm2_plugin install files to libdir/lvm2

    Both targets creates relative links to libdir to keep the code
    compatible with current dlopen handling.

    Once we will be able to read plugins from subdir, links
    could be removed.

    Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in
b/daemons/dmeventd/plugins/mirror/Makefile.in
index 146361f..5966f24 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -32,6 +32,6 @@ include $(top_builddir)/make.tmpl

 LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)

-install_lvm2: install_lib_shared_plugin
+install_lvm2: install_dm_plugin

 install: install_lvm2
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in
b/daemons/dmeventd/plugins/snapshot/Makefile.in
index f36f916..32a74af 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -28,6 +28,6 @@ include $(top_builddir)/make.tmpl

 LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)

-install_lvm2: install_lib_shared_plugin
+install_lvm2: install_dm_plugin

 install: install_lvm2
diff --git a/lib/format1/Makefile.in b/lib/format1/Makefile.in
index f0f04d2..e102fe8 100644
--- a/lib/format1/Makefile.in
+++ b/lib/format1/Makefile.in
@@ -30,4 +30,4 @@ LIB_VERSION = $(LIB_VERSION_LVM)

 include $(top_builddir)/make.tmpl

-install: install_lib_shared_plugin
+install: install_lvm2_plugin
diff --git a/lib/format_pool/Makefile.in b/lib/format_pool/Makefile.in
index 0671ee8..be5195c 100644
--- a/lib/format_pool/Makefile.in
+++ b/lib/format_pool/Makefile.in
@@ -27,4 +27,4 @@ LIB_VERSION = $(LIB_VERSION_LVM)

 include $(top_builddir)/make.tmpl

-install: install_lib_shared_plugin
+install: install_lvm2_plugin
diff --git a/lib/locking/Makefile.in b/lib/locking/Makefile.in
index fee0382..1aae878 100644
--- a/lib/locking/Makefile.in
+++ b/lib/locking/Makefile.in
@@ -23,4 +23,4 @@ LIB_VERSION = $(LIB_VERSION_LVM)

 include $(top_builddir)/make.tmpl

-install install_cluster: install_lib_shared_plugin
+install install_cluster: install_lvm2_plugin
diff --git a/lib/mirror/Makefile.in b/lib/mirror/Makefile.in
index 2769d44..5168eda 100644
--- a/lib/mirror/Makefile.in
+++ b/lib/mirror/Makefile.in
@@ -23,4 +23,4 @@ LIB_VERSION = $(LIB_VERSION_LVM)

 include $(top_builddir)/make.tmpl

-install: install_lib_shared_plugin
+install: install_lvm2_plugin
diff --git a/lib/snapshot/Makefile.in b/lib/snapshot/Makefile.in
index 7f8a544..72399f3 100644
--- a/lib/snapshot/Makefile.in
+++ b/lib/snapshot/Makefile.in
@@ -23,4 +23,4 @@ LIB_VERSION = $(LIB_VERSION_LVM)

 include $(top_builddir)/make.tmpl

-install: install_lib_shared_plugin
+install: install_lvm2_plugin
diff --git a/make.tmpl.in b/make.tmpl.in
index 48b0419..a88830f 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -162,7 +162,7 @@ POTFILES = $(SOURCES:%.c=%.pot)

 .PHONY: all pofile distclean clean cleandir cflow device-mapper
 .PHONY: install install_cluster install_device-mapper install_lvm2
-.PHONY: install_lib_shared install_lib_shared_plugin
+.PHONY: install_lib_shared install_dm_plugin install_lvm2_plugin
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
@@ -305,9 +305,18 @@ install_lib_shared: $(LIB_SHARED)
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



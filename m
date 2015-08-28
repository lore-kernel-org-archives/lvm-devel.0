From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 28 Aug 2015 12:06:12 +0000 (UTC)
Subject: master - man: Add install_full_man makefile target.
Message-ID: <20150828120612.C6AE160093@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc17210bce2cf08015e19caad3bc6a8307c841c8
Commit:        cc17210bce2cf08015e19caad3bc6a8307c841c8
Parent:        e5d99cb9e685ba167f10413694e5d9d34fe90bb0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 28 13:03:18 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 28 13:03:18 2015 +0100

man: Add install_full_man makefile target.

'make install_full_man' installs all the man pages regardless of
which components were enabled when 'configure' was run.
---
 Makefile.in             |    3 +
 WHATS_NEW               |    1 +
 configure               |    8 +--
 configure.in            |   10 ++---
 lib/misc/configure.h.in |   11 +++--
 make.tmpl.in            |    2 +-
 man/Makefile.in         |  114 ++++++++++++++++++++++++----------------------
 7 files changed, 78 insertions(+), 71 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 35e5d8f..1ce9ca8 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -150,6 +150,9 @@ install_systemd_generators:
 install_systemd_units:
 	$(MAKE) -C scripts install_systemd_units
 
+install_full_man:
+	$(MAKE) -C man install_full_man
+
 ifeq ("@PYTHON_BINDINGS@", "yes")
 install_python_bindings:
 	$(MAKE) -C liblvm/python install_python_bindings
diff --git a/WHATS_NEW b/WHATS_NEW
index 9488e32..b5e8414 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.130 - 
 ===================================
+  Add 'make install_full_man' to install all man pages regardless of config.
 
 Version 2.02.129 - 26th August 2015
 ===================================
diff --git a/configure b/configure
index 57bec69..ff914d8 100755
--- a/configure
+++ b/configure
@@ -13870,16 +13870,14 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
-if  test "$CLVMD" != none; then
-	clvmd_prefix=$ac_default_prefix
-	test "$prefix" != NONE && clvmd_prefix=$prefix
-	CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
+clvmd_prefix=$ac_default_prefix
+test "$prefix" != NONE && clvmd_prefix=$prefix
+CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
 
 cat >>confdefs.h <<_ACEOF
 #define CLVMD_PATH "$CLVMD_PATH"
 _ACEOF
 
-fi
 
 ################################################################################
 if test "$BUILD_DMEVENTD" = yes; then
diff --git a/configure.in b/configure.in
index 2c89d8c..dfd105a 100644
--- a/configure.in
+++ b/configure.in
@@ -1788,12 +1788,10 @@ test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$ac_default_prefix
 LVM_PATH="$lvm_exec_prefix/sbin/lvm"
 AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
 
-if  test "$CLVMD" != none; then
-	clvmd_prefix=$ac_default_prefix
-	test "$prefix" != NONE && clvmd_prefix=$prefix
-	CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
-	AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$CLVMD_PATH"], [Path to clvmd binary.])
-fi
+clvmd_prefix=$ac_default_prefix
+test "$prefix" != NONE && clvmd_prefix=$prefix
+CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
+AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$CLVMD_PATH"], [Path to clvmd binary.])
 
 ################################################################################
 dnl -- dmeventd pidfile and executable path
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 0adb7b1..a21d807 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -460,7 +460,7 @@
 /* Define to 1 if you have the `strtoull' function. */
 #undef HAVE_STRTOULL
 
-/* Define to 1 if `st_rdev' is member of `struct stat'. */
+/* Define to 1 if `st_rdev' is a member of `struct stat'. */
 #undef HAVE_STRUCT_STAT_ST_RDEV
 
 /* Define to 1 if you have the <syslog.h> header file. */
@@ -513,12 +513,12 @@
 /* Define to 1 if you have the <sys/stat.h> header file. */
 #undef HAVE_SYS_STAT_H
 
-/* Define to 1 if you have the <sys/time.h> header file. */
-#undef HAVE_SYS_TIME_H
-
 /* Define to 1 if you have the <sys/timerfd.h> header file. */
 #undef HAVE_SYS_TIMERFD_H
 
+/* Define to 1 if you have the <sys/time.h> header file. */
+#undef HAVE_SYS_TIME_H
+
 /* Define to 1 if you have the <sys/types.h> header file. */
 #undef HAVE_SYS_TYPES_H
 
@@ -643,6 +643,9 @@
 /* Define to the one symbol short name of this package. */
 #undef PACKAGE_TARNAME
 
+/* Define to the home page for this package. */
+#undef PACKAGE_URL
+
 /* Define to the version of this package. */
 #undef PACKAGE_VERSION
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 2ce2faf..96889b4 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -275,7 +275,7 @@ POTFILES = $(SOURCES:%.c=%.pot)
 .PHONY: all pofile distclean clean cleandir cflow device-mapper
 .PHONY: install install_cluster install_device-mapper install_lvm2
 .PHONY: install_lib_shared install_dm_plugin install_lvm2_plugin
-.PHONY: install_ocf help
+.PHONY: install_ocf install_systemd_generators install_full_man help
 .PHONY: python_bindings install_python_bindings
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
diff --git a/man/Makefile.in b/man/Makefile.in
index dc16a76..995438f 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -16,41 +16,16 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-ifeq ("@FSADM@", "yes")
 FSADMMAN = fsadm.8
-else
-FSADMMAN =
-endif
-
-ifeq ("@BLKDEACTIVATE@", "yes")
 BLKDEACTIVATEMAN = blkdeactivate.8
-else
-BLKDEACTIVATEMAN =
-endif
-
-ifeq ("@DMEVENTD@", "yes")
 DMEVENTDMAN = dmeventd.8
-else
-DMEVENTDMAN =
-endif
-
-ifeq ("@BUILD_LVMETAD@", "yes")
-LVMETAD = lvmetad.8
-else
-LVMETAD =
-endif
-
-ifeq ("@BUILD_LVMPOLLD@", "yes")
-LVMPOLLD = lvmpolld.8
-else
-LVMPOLLD =
-endif
-
-ifeq ("@BUILD_LVMLOCKD@", "yes")
-LVMLOCKD = lvmlockd.8
-else
-LVMLOCKD =
-endif
+LVMETADMAN = lvmetad.8
+LVMPOLLDMAN = lvmpolld.8
+LVMLOCKDMAN = lvmlockd.8
+CLVMDMAN = clvmd.8
+CMIRRORDMAN = cmirrord.8
+LVMCACHEMAN = lvmcache.7
+LVMTHINMAN = lvmthin.7
 
 MAN5=lvm.conf.5
 MAN7=lvmsystemid.7
@@ -62,38 +37,69 @@ MAN8=lvm-config.8 lvm-dumpconfig.8 lvm-lvpoll.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(LVMETAD) $(LVMPOLLD) \
-	$(LVMLOCKD)
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8
+MAN8DM=dmsetup.8 dmstats.8
+MAN8CLUSTER=
+MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
-ifneq ("@CLVMD@", "none")
-  MAN8CLUSTER=clvmd.8
+ifeq ($(MAKECMDGOALS),install_full_man)
+  MAN8+=$(FSADMMAN) $(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN)
+  MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN)
+  MAN8CLUSTER+=$(CLVMDMAN) $(CMIRRORDMAN)
+  MAN7+=$(LVMCACHEMAN) $(LVMTHINMAN)
 else
-  MAN8CLUSTER=
-endif
+  ifeq ("@FSADM@", "yes")
+    MAN8+=$(FSADMMAN)
+  endif
 
-ifeq ("@BUILD_CMIRRORD@", "yes")
-  MAN8CLUSTER+=cmirrord.8
-endif
+  ifeq ("@BUILD_LVMETAD@", "yes")
+    MAN8+=$(LVMETADMAN)
+  endif
 
-ifneq ("@CACHE@", "none")
-  MAN7+=lvmcache.7
-endif
+  ifeq ("@BUILD_LVMPOLLD@", "yes")
+    MAN8+=$(LVMPOLLDMAN)
+  endif
+
+  ifeq ("@BUILD_LVMLOCKD@", "yes")
+    MAN8+=$(LVMLOCKDMAN)
+  endif
+
+  ifeq ("@BLKDEACTIVATE@", "yes")
+    MAN8DM+=$(BLKDEACTIVATEMAN)
+  endif
+
+  ifeq ("@DMEVENTD@", "yes")
+    MAN8DM+=$(DMEVENTDMAN)
+  endif
 
-ifneq ("@THIN@", "none")
-  MAN7+=lvmthin.7
+  ifneq ("@CLVMD@", "none")
+    MAN8CLUSTER+=$(CLVMDMAN)
+  endif
+
+  ifeq ("@BUILD_CMIRRORD@", "yes")
+    MAN8CLUSTER+=$(CMIRRORDMAN)
+  endif
+
+  ifneq ("@CACHE@", "none")
+    MAN7+=$(LVMCACHEMAN)
+  endif
+
+  ifneq ("@THIN@", "none")
+    MAN7+=$(LVMTHINMAN)
+  endif
 endif
 
-MAN8DM=dmsetup.8 dmstats.8 $(DMEVENTDMAN) $(BLKDEACTIVATEMAN)
 MAN5DIR=$(mandir)/man5
 MAN7DIR=$(mandir)/man7
 MAN8DIR=$(mandir)/man8
 
-MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
-
 include $(top_builddir)/make.tmpl
 
-CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS) $(MAN8DM)
-DISTCLEAN_TARGETS+=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8 lvmcache.7 lvmthin.7 blkdeactivate.8
+CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) \
+	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM)
+DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
+	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CLVMDMAN) $(CMIRRORDMAN) \
+	$(LVMCACHEMAN) $(LVMTHINMAN)
 
 all: man device-mapper
 
@@ -119,10 +125,8 @@ install_man5: $(MAN5)
 	$(INSTALL_DATA) $(MAN5) $(MAN5DIR)/
 
 install_man7: $(MAN7)
-ifdef MAN7
 	$(INSTALL) -d $(MAN7DIR)
 	$(INSTALL_DATA) $(MAN7) $(MAN7DIR)/
-endif
 
 install_man8: $(MAN8)
 	$(INSTALL) -d $(MAN8DIR)
@@ -141,9 +145,9 @@ install_device-mapper: $(MAN8DM)
 	$(INSTALL_DATA) $(MAN8DM) $(MAN8DIR)/
 
 install_systemd_generators: $(MAN8SYSTEMD_GENERATORS)
-ifdef MAN8SYSTEMD_GENERATORS
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8SYSTEMD_GENERATORS) $(MAN8DIR)/
-endif
 
 install: install_lvm2 install_device-mapper install_cluster
+
+install_full_man: install install_systemd_generators



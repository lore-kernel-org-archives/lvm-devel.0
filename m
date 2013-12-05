From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  5 Dec 2013 13:06:00 +0000 (UTC)
Subject: master - compile/link: use RELRO/PIE compiler/linker options for executables
Message-ID: <20131205130600.379E960319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=481edce41f54a392b663991c4e29c9eed05f90b5
Commit:        481edce41f54a392b663991c4e29c9eed05f90b5
Parent:        b494881e685da3ada4a42a17a33d4fe67f3ca784
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 5 14:03:10 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 5 14:03:10 2013 +0100

compile/link: use RELRO/PIE compiler/linker options for executables

---
 WHATS_NEW                    |    2 +-
 daemons/clvmd/Makefile.in    |    4 ++--
 daemons/cmirrord/Makefile.in |    4 ++--
 daemons/dmeventd/Makefile.in |    4 ++--
 daemons/lvmetad/Makefile.in  |    4 ++--
 make.tmpl.in                 |    4 ++--
 scripts/Makefile.in          |    4 +++-
 tools/Makefile.in            |    4 ++--
 8 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2e1f59a..72a61e3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -8,7 +8,7 @@ Version 2.02.105 -
   Extend lv_remove_single() to not print info about removed LV.
   Replace open_count check with lv_check_not_in_use() for snapshot open test.
   Add error messages with LV names for failing lv refresh.
-  Compile/link daemons with RELRO and PIE options to harden daemon security.
+  Compile/link executables with new RELRO and PIE options (non-static builds).
   Support per-object compilation cflags via CFLAGS_object.o.
   Automatically detect support for compiler/linker options to use RELRO and PIE.
   Add --splitsnapshot to lvconvert to separate out cow LV.
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 4677048..0da95a7 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -88,8 +88,8 @@ LVMLIBS += -ldevmapper
 LIBS += $(PTHREAD_LIBS)
 
 DEFS += -D_REENTRANT
-CFLAGS += -fno-strict-aliasing $(DAEMON_CFLAGS)
-LDFLAGS += $(DAEMON_LDFLAGS)
+CFLAGS += -fno-strict-aliasing $(EXTRA_EXEC_CFLAGS)
+LDFLAGS += $(EXTRA_EXEC_LDFLAGS)
 
 INSTALL_TARGETS = \
 	install_clvmd
diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index df7c2a8..d368793 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -28,8 +28,8 @@ include $(top_builddir)/make.tmpl
 
 LIBS += -ldevmapper
 LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
-CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS) $(DAEMON_CFLAGS)
-LDFLAGS += $(DAEMON_LDFLAGS)
+CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS) $(EXTRA_EXEC_CFLAGS)
+LDFLAGS += $(EXTRA_EXEC_LDFLAGS)
 
 cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index fcc5c9e..47bfb67 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -59,10 +59,10 @@ device-mapper: $(TARGETS)
 LIBS += -ldevmapper
 LVMLIBS += -ldevmapper-event $(PTHREAD_LIBS)
 
-CFLAGS_dmeventd.o += $(DAEMON_CFLAGS)
+CFLAGS_dmeventd.o += $(EXTRA_EXEC_CFLAGS)
 
 dmeventd: $(LIB_SHARED) dmeventd.o
-	$(CC) $(CFLAGS) $(LDFLAGS) $(DAEMON_LDFLAGS) $(ELDFLAGS) -L. -o $@ dmeventd.o \
+	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -L. -o $@ dmeventd.o \
 	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index 67a557f..0a174bb 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -33,9 +33,9 @@ LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
 
 LIBS += $(PTHREAD_LIBS)
 
-LDFLAGS += -L$(top_builddir)/libdaemon/server $(DAEMON_LDFLAGS)
+LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS)
 CLDFLAGS += -L$(top_builddir)/libdaemon/server
-CFLAGS += $(DAEMON_CFLAGS)
+CFLAGS += $(EXTRA_EXEC_CFLAGS)
 
 lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
diff --git a/make.tmpl.in b/make.tmpl.in
index 5f72182..65b1da0 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -153,8 +153,8 @@ endif
 ifneq ("@STATIC_LINK@", "yes")
 ifeq ("@HAVE_PIE@", "yes")
 ifeq ("@HAVE_FULL_RELRO@", "yes")
-  DAEMON_CFLAGS += -fPIE -DPIE
-  DAEMON_LDFLAGS += -Wl,-z,relro,-z,now -pie
+  EXTRA_EXEC_CFLAGS += -fPIE -DPIE
+  EXTRA_EXEC_LDFLAGS += -Wl,-z,relro,-z,now -pie
 endif
 endif
 endif
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 3616afa..ed587ca 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -82,8 +82,10 @@ ifeq ("@BLKDEACTIVATE@", "yes")
 	$(INSTALL_SCRIPT) blk_availability_init_red_hat $(initdir)/blk-availability
 endif
 
+CFLAGS_lvm2_activation_generator_systemd_red_hat.o += $(EXTRA_EXEC_CFLAGS)
+
 lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS)
-	$(CC) -o $@ $(OBJECTS) $(LDFLAGS) $(LVMLIBS)
+	$(CC) -o $@ $(OBJECTS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(LVMLIBS)
 
 install_systemd_generators:
 	$(INSTALL_DIR) $(systemd_generator_dir)
diff --git a/tools/Makefile.in b/tools/Makefile.in
index f8e4934..34df48b 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -122,7 +122,7 @@ LIBS += $(UDEV_LIBS) $(BLKID_LIBS)
 device-mapper: $(TARGETS_DM)
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
-	$(CC) $(CFLAGS) $(LDFLAGS) -L$(top_builddir)/libdm \
+	$(CC) $(CFLAGS) $(EXTRA_EXEC_CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
 	      -o $@ dmsetup.o -ldevmapper $(LIBS)
 
 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
@@ -132,7 +132,7 @@ dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
 all: device-mapper
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
-	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
+	$(CC) $(CFLAGS) $(EXTRA_EXEC_CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
 		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) -rdynamic
 
 ifeq ("@BUILD_LVMETAD@", "yes")



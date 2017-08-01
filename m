From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 06:01:52 -0400
Subject: master - man: fix generated paths
Message-ID: <201708011001.v71A1q0D011546@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1b5f38bbe30e14f33a0cd76eed74c48280865ee
Commit:        c1b5f38bbe30e14f33a0cd76eed74c48280865ee
Parent:        8256170e6a2dbed15b790e75f5d1026e3de69a16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 1 11:17:04 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 11:53:11 2017 +0200

man: fix generated paths

Use user configured paths instead of some developers paths ;)
---
 WHATS_NEW       |    1 +
 make.tmpl.in    |    1 +
 man/Makefile.in |    8 ++++----
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 41ddda7..515b0eb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Fix some paths in generated makefiles to respected configured settings.
   Add warning when creating thin-pool with zeroing and chunk size >= 512KiB.
   Introduce exit code 4 EINIT_FAILED to replace -1 when initialisation fails.
   Add synchronization points with udev during reshape of raid LVs.
diff --git a/make.tmpl.in b/make.tmpl.in
index cb5953a..2b2ddd1 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -123,6 +123,7 @@ DEFAULT_CACHE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_CACHE_SUBDIR@
 DEFAULT_PROFILE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_PROFILE_SUBDIR@
 DEFAULT_LOCK_DIR = @DEFAULT_LOCK_DIR@
 DEFAULT_RUN_DIR = @DEFAULT_RUN_DIR@
+DEFAULT_PID_DIR = @DEFAULT_PID_DIR@
 DEFAULT_MANGLING = @MANGLING@
 
 # Setup vpath search paths for some suffixes
diff --git a/man/Makefile.in b/man/Makefile.in
index d0efb5d..f88b569 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -179,10 +179,10 @@ $(SED)	-e "s+#VERSION#+$(LVM_VERSION)+" \
 	-e "s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+" \
 	-e "s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+" \
 	-e "s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+" \
-	-e "s+#CLVMD_PATH#+/data/lvmtest/usr/sbin/clvmd+" \
-	-e "s+#LVM_PATH#+/data/lvmtest/sbin/lvm+" \
-	-e "s+#DEFAULT_RUN_DIR#+/var/run/lvm+" \
-	-e "s+#DEFAULT_PID_DIR#+/var/run+" \
+	-e "s+#CLVMD_PATH#+$(exec_prefix)/clvmd+" \
+	-e "s+#LVM_PATH#+$(exec_prefix)/lvm+" \
+	-e "s+#DEFAULT_RUN_DIR#+$(DEFAULT_RUN_DIR)+" \
+	-e "s+#DEFAULT_PID_DIR#+$(DEFAULT_PID_DIR)+" \
 	-e "s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+" \
 	-e "s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+" $< > $@
 endef



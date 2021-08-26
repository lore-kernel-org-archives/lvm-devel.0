From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 26 Aug 2021 17:11:02 +0000 (GMT)
Subject: main - vdo: rename vdoimport to lvm_import_vdo
Message-ID: <20210826171102.723503858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=12ba43ccd0cac480b4da0fb8457db83b4b50b722
Commit:        12ba43ccd0cac480b4da0fb8457db83b4b50b722
Parent:        49822624e8b02bf108d79ac3ffd58a35c0c92c5e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 23 14:02:42 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 26 19:10:28 2021 +0200

vdo: rename vdoimport to lvm_import_vdo

Missed bits in previous rename commits.
---
 configure                 | 26 +++++++++++++-------------
 configure.ac              | 18 +++++++++---------
 include/configure.h.in    |  6 +++---
 man/Makefile.in           |  8 ++++----
 man/lvm_import_vdo.8_main |  1 -
 scripts/Makefile.in       |  4 ++--
 scripts/lvm_import_vdo.sh |  6 +++---
 7 files changed, 34 insertions(+), 35 deletions(-)

diff --git a/configure b/configure
index cd94cbca2..9b1508255 100755
--- a/configure
+++ b/configure
@@ -643,8 +643,6 @@ WRITE_INSTALL
 WRITECACHE
 VDO_LIB
 VDO_INCLUDE
-VDOIMPORT_PATH
-VDOIMPORT
 VDO
 VALGRIND_POOL
 USRSBINDIR
@@ -693,6 +691,8 @@ OCFDIR
 OCF
 MIRRORS
 MANGLING
+LVMIMPORTVDO_PATH
+LVMIMPORTVDO
 LVM_RELEASE_DATE
 LVM_RELEASE
 LVM_PATH
@@ -971,7 +971,7 @@ enable_dbus_service
 enable_pkgconfig
 enable_write_install
 enable_fsadm
-enable_vdoimport
+enable_lvmimportvdo
 enable_blkdeactivate
 enable_dmeventd
 enable_selinux
@@ -1710,7 +1710,7 @@ Optional Features:
   --enable-pkgconfig      install pkgconfig support
   --enable-write_install  install user writable files
   --disable-fsadm         disable fsadm
-  --disable-vdoimport     disable vdoimport
+  --disable-lvmimportvdo  disable lvm_import_vdo
   --disable-blkdeactivate disable blkdeactivate
   --enable-dmeventd       enable the device-mapper event daemon
   --disable-selinux       disable selinux support
@@ -3143,7 +3143,7 @@ case "$host_os" in
 		DM_IOCTLS=yes
 		SELINUX=yes
 		FSADM=yes
-		VDOIMPORT=yes
+		LVMIMPORTVDO=yes
 		BLKDEACTIVATE=yes
 		;;
 	darwin*)
@@ -3157,7 +3157,7 @@ case "$host_os" in
 		DM_IOCTLS=no
 		SELINUX=no
 		FSADM=no
-		VDOIMPORT=no
+		LVMIMPORTVDO=no
 		BLKDEACTIVATE=no
 		;;
 	*)
@@ -12554,13 +12554,13 @@ $as_echo "$FSADM" >&6; }
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install lvm_import_vdo" >&5
 $as_echo_n "checking whether to install lvm_import_vdo... " >&6; }
-# Check whether --enable-vdoimport was given.
-if test "${enable_vdoimport+set}" = set; then :
-  enableval=$enable_vdoimport; VDOIMPORT=$enableval
+# Check whether --enable-lvmimportvdo was given.
+if test "${enable_lvmimportvdo+set}" = set; then :
+  enableval=$enable_lvmimportvdo; LVMIMPORTVDO=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $VDOIMPORT" >&5
-$as_echo "$VDOIMPORT" >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVMIMPORTVDO" >&5
+$as_echo "$LVMIMPORTVDO" >&6; }
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install blkdeactivate" >&5
@@ -14048,10 +14048,10 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
-VDOIMPORT_PATH="$SBINDIR/lvm_import_vdo"
+LVMIMPORTVDO_PATH="$SBINDIR/lvm_import_vdo"
 
 cat >>confdefs.h <<_ACEOF
-#define VDOIMPORT_PATH "$VDOIMPORT_PATH"
+#define LVMIMPORTVDO_PATH "$LVMIMPORTVDO_PATH"
 _ACEOF
 
 
diff --git a/configure.ac b/configure.ac
index 922a21265..a821edf2a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -46,7 +46,7 @@ case "$host_os" in
 		DM_IOCTLS=yes
 		SELINUX=yes
 		FSADM=yes
-		VDOIMPORT=yes
+		LVMIMPORTVDO=yes
 		BLKDEACTIVATE=yes
 		;;
 	darwin*)
@@ -60,7 +60,7 @@ case "$host_os" in
 		DM_IOCTLS=no
 		SELINUX=no
 		FSADM=no
-		VDOIMPORT=no
+		LVMIMPORTVDO=no
 		BLKDEACTIVATE=no
 		;;
 	*)
@@ -1317,9 +1317,9 @@ AC_MSG_RESULT($FSADM)
 ################################################################################
 dnl -- Enable lvm_import_vdo
 AC_MSG_CHECKING(whether to install lvm_import_vdo)
-AC_ARG_ENABLE(vdoimport, AC_HELP_STRING([--disable-vdoimport], [disable vdoimport]),
-	      VDOIMPORT=$enableval)
-AC_MSG_RESULT($VDOIMPORT)
+AC_ARG_ENABLE(lvmimportvdo, AC_HELP_STRING([--disable-lvmimportvdo], [disable lvm_import_vdo]),
+	      LVMIMPORTVDO=$enableval)
+AC_MSG_RESULT($LVMIMPORTVDO)
 
 ################################################################################
 dnl -- Enable blkdeactivate
@@ -1676,8 +1676,8 @@ USRSBINDIR="$(eval echo $(eval echo $usrsbindir))"
 FSADM_PATH="$SBINDIR/fsadm"
 AC_DEFINE_UNQUOTED(FSADM_PATH, ["$FSADM_PATH"], [Path to fsadm binary.])
 
-VDOIMPORT_PATH="$SBINDIR/lvm_import_vdo"
-AC_DEFINE_UNQUOTED(VDOIMPORT_PATH, ["$VDOIMPORT_PATH"], [Path to lvm_import_vdo binary.])
+LVMIMPORTVDO_PATH="$SBINDIR/lvm_import_vdo"
+AC_DEFINE_UNQUOTED(LVMIMPORTVDO_PATH, ["$LVMIMPORTVDO_PATH"], [Path to lvm_import_vdo script.])
 
 ################################################################################
 dnl -- dmeventd pidfile and executable path
@@ -1855,6 +1855,8 @@ AC_SUBST(LVM_PATCHLEVEL)
 AC_SUBST(LVM_PATH)
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
+AC_SUBST(LVMIMPORTVDO)
+AC_SUBST(LVMIMPORTVDO_PATH)
 AC_SUBST(localedir)
 AC_SUBST(MANGLING)
 AC_SUBST(MIRRORS)
@@ -1915,8 +1917,6 @@ AC_SUBST(SILENT_RULES)
 AC_SUBST(USRSBINDIR)
 AC_SUBST(VALGRIND_POOL)
 AC_SUBST(VDO)
-AC_SUBST(VDOIMPORT)
-AC_SUBST(VDOIMPORT_PATH)
 AC_SUBST(VDO_FORMAT_CMD)
 AC_SUBST(VDO_INCLUDE)
 AC_SUBST(VDO_LIB)
diff --git a/include/configure.h.in b/include/configure.h.in
index cf0d7f223..8fb5ca9fe 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -571,6 +571,9 @@
 /* Path to lvmconfig binary. */
 #undef LVMCONFIG_PATH
 
+/* Path to lvm_import_vdo script. */
+#undef LVMIMPORTVDO_PATH
+
 /* Path to lvmlockd pidfile. */
 #undef LVMLOCKD_PIDFILE
 
@@ -687,9 +690,6 @@
 /* Enable a valgrind aware build of pool */
 #undef VALGRIND_POOL
 
-/* Path to lvm_import_vdo binary. */
-#undef VDOIMPORT_PATH
-
 /* The path to 'vdoformat', if available. */
 #undef VDO_FORMAT_CMD
 
diff --git a/man/Makefile.in b/man/Makefile.in
index 45ebf5446..40248d640 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -23,7 +23,7 @@ else
 endif
 
 FSADMMAN = fsadm.8
-VDOIMPORTMAN = lvm_import_vdo.8
+LVMIMPORTVDOMAN = lvm_import_vdo.8
 BLKDEACTIVATEMAN = blkdeactivate.8
 DMEVENTDMAN = dmeventd.8
 DMFILEMAPDMAN = dmfilemapd.8
@@ -51,7 +51,7 @@ MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
 ifeq (,$(findstring $(MAKECMDGOALS), distclean all_man install_all_man))
   MAN7 += lvmcache.7 lvmthin.7 lvmvdo.7
-  MAN8+=$(FSADMMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN) $(VDOIMPORTMAN)
+  MAN8+=$(FSADMMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN) $(LVMIMPORTVDOMAN)
   MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(DMFILEMAPDMAN)
   MAN8CLUSTER+=$(CMIRRORDMAN)
 else
@@ -59,8 +59,8 @@ else
     MAN8+=$(FSADMMAN)
   endif
 
-  ifeq ("@VDOIMPORT@", "yes")
-    MAN8+=$(VDOIMPORTMAN)
+  ifeq ("@LVMIMPORTVDO@", "yes")
+    MAN8+=$(LVMIMPORTVDOMAN)
   endif
 
   ifeq ("@BUILD_LVMDBUSD@", "yes")
diff --git a/man/lvm_import_vdo.8_main b/man/lvm_import_vdo.8_main
index ee817a0cc..d970eeb40 100644
--- a/man/lvm_import_vdo.8_main
+++ b/man/lvm_import_vdo.8_main
@@ -89,4 +89,3 @@ Defaults to "\fI/dev\fP" and must be an absolute path.
 .BR lvm.conf (5),
 .P
 .BR vdo (8),
-.BR vdo2lvm (8),
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index f16c37d81..ee0acb6f6 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2006-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2006-2021 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -31,7 +31,7 @@ ifeq ("@FSADM@", "yes")
 	LVM_SCRIPTS += fsadm.sh
 endif
 
-ifeq ("@VDOIMPORT@", "yes")
+ifeq ("@LVMIMPORTVDO@", "yes")
 	LVM_SCRIPTS += lvm_import_vdo.sh
 endif
 
diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 35140a07c..7e24b49d7 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -14,11 +14,11 @@
 #
 # Author: Zdenek Kabelac <zkabelac@redhat.com>
 #
-# Script for converting VDO volumes to lvm2 VDO LVs
+# Script for importing VDO volumes to lvm2 managed VDO LVs
 #
 # Needed utilities:
 #  lvm, dmsetup,
-#  vdo, vdo2lvm,
+#  vdo,
 #  grep, awk, sed, blockdev, readlink, mkdir
 #
 # Conversion is using  'vdo convert' support from VDO manager to move
@@ -305,7 +305,7 @@ EOF
 		}
 
 		# Obtain free space in this new PV
-		# after 'vdo convert/vdo2lvm' call there is +2M free space at the front of the device
+		# after 'vdo convert' call there is +2M free space at the front of the device
 		case "$DRY" in
 		0) pvfree=$("$LVM" pvs -o devsize --units b --nosuffix --noheadings "$DEVICE") ;;
 		*) pvfree=$("$BLOCKDEV" --getsize64 "$DEVICE") ;;



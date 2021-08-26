From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 26 Aug 2021 15:43:41 +0000 (GMT)
Subject: main - vdo: Rename vdoimport to lvm_import_vdo.
Message-ID: <20210826154341.D900C3858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bbbd4fed69d88e67678994cb611d082d27bb774b
Commit:        bbbd4fed69d88e67678994cb611d082d27bb774b
Parent:        0969e90d45932d2903d2822701b32edfb2cf31cf
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Aug 26 16:53:33 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Aug 26 17:13:59 2021 +0200

vdo: Rename vdoimport to lvm_import_vdo.

---
 WHATS_NEW                                       |  1 +
 configure                                       |  6 +++---
 configure.ac                                    |  8 ++++----
 include/configure.h.in                          |  2 +-
 man/Makefile.in                                 |  2 +-
 man/{vdoimport.8_main => lvm_import_vdo.8_main} |  8 ++++----
 scripts/Makefile.in                             |  2 +-
 scripts/{vdoimport.sh => lvm_import_vdo.sh}     |  2 +-
 test/Makefile.in                                |  2 +-
 test/shell/vdo-convert.sh                       | 12 ++++++------
 10 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 09ee395b5..ea434e2c6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.14 - 
 ==================================
+  Rename vdoimport to lvm_import_vdo.
 
 Version 2.03.13 - 11th August 2021
 ==================================
diff --git a/configure b/configure
index c2d2cff5b..cd94cbca2 100755
--- a/configure
+++ b/configure
@@ -12552,8 +12552,8 @@ $as_echo "$FSADM" >&6; }
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install vdoimport" >&5
-$as_echo_n "checking whether to install vdoimport... " >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install lvm_import_vdo" >&5
+$as_echo_n "checking whether to install lvm_import_vdo... " >&6; }
 # Check whether --enable-vdoimport was given.
 if test "${enable_vdoimport+set}" = set; then :
   enableval=$enable_vdoimport; VDOIMPORT=$enableval
@@ -14048,7 +14048,7 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
-VDOIMPORT_PATH="$SBINDIR/vdoimport"
+VDOIMPORT_PATH="$SBINDIR/lvm_import_vdo"
 
 cat >>confdefs.h <<_ACEOF
 #define VDOIMPORT_PATH "$VDOIMPORT_PATH"
diff --git a/configure.ac b/configure.ac
index a20633e21..922a21265 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1315,8 +1315,8 @@ AC_MSG_RESULT($FSADM)
 
 
 ################################################################################
-dnl -- Enable vdoimport
-AC_MSG_CHECKING(whether to install vdoimport)
+dnl -- Enable lvm_import_vdo
+AC_MSG_CHECKING(whether to install lvm_import_vdo)
 AC_ARG_ENABLE(vdoimport, AC_HELP_STRING([--disable-vdoimport], [disable vdoimport]),
 	      VDOIMPORT=$enableval)
 AC_MSG_RESULT($VDOIMPORT)
@@ -1676,8 +1676,8 @@ USRSBINDIR="$(eval echo $(eval echo $usrsbindir))"
 FSADM_PATH="$SBINDIR/fsadm"
 AC_DEFINE_UNQUOTED(FSADM_PATH, ["$FSADM_PATH"], [Path to fsadm binary.])
 
-VDOIMPORT_PATH="$SBINDIR/vdoimport"
-AC_DEFINE_UNQUOTED(VDOIMPORT_PATH, ["$VDOIMPORT_PATH"], [Path to vdoimport binary.])
+VDOIMPORT_PATH="$SBINDIR/lvm_import_vdo"
+AC_DEFINE_UNQUOTED(VDOIMPORT_PATH, ["$VDOIMPORT_PATH"], [Path to lvm_import_vdo binary.])
 
 ################################################################################
 dnl -- dmeventd pidfile and executable path
diff --git a/include/configure.h.in b/include/configure.h.in
index 55d18bd4f..cf0d7f223 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -687,7 +687,7 @@
 /* Enable a valgrind aware build of pool */
 #undef VALGRIND_POOL
 
-/* Path to vdoimport binary. */
+/* Path to lvm_import_vdo binary. */
 #undef VDOIMPORT_PATH
 
 /* The path to 'vdoformat', if available. */
diff --git a/man/Makefile.in b/man/Makefile.in
index d60a92cde..45ebf5446 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -23,7 +23,7 @@ else
 endif
 
 FSADMMAN = fsadm.8
-VDOIMPORTMAN = vdoimport.8
+VDOIMPORTMAN = lvm_import_vdo.8
 BLKDEACTIVATEMAN = blkdeactivate.8
 DMEVENTDMAN = dmeventd.8
 DMFILEMAPDMAN = dmfilemapd.8
diff --git a/man/vdoimport.8_main b/man/lvm_import_vdo.8_main
similarity index 88%
rename from man/vdoimport.8_main
rename to man/lvm_import_vdo.8_main
index 1f329099c..ee817a0cc 100644
--- a/man/vdoimport.8_main
+++ b/man/lvm_import_vdo.8_main
@@ -2,14 +2,14 @@
 .
 .SH "NAME"
 .
-vdoimport \(em utility to import VDO volumes into a new volume group.
+lvm_import_vdo \(em utility to import VDO volumes into a new volume group.
 .
 .SH SYNOPSIS
 .
 .PD 0
 .ad l
 .TP 10
-.B vdoimport
+.B lvm_import_vdo
 .RI [ options ]
 .IR device
 .
@@ -17,7 +17,7 @@ vdoimport \(em utility to import VDO volumes into a new volume group.
 .
 .SH DESCRIPTION
 .
-vdoimport utility imports VDO volumes created and managed by
+lvm_import_vdo utility imports VDO volumes created and managed by
 .BR vdo (8)
 manager into
 .BR lvm2 (8)
@@ -69,7 +69,7 @@ A status code of 1 is used for failure.
 Convert VDO volume created by vdo manager into logical volume LV1 with within volume group VG1.
 .P
 #
-.B vdoimport --name VG1/LV1 /dev/mapper/vdo-volume
+.B lvm_import_vdo --name VG1/LV1 /dev/mapper/vdo-volume
 .
 .SH ENVIRONMENT VARIABLES
 .
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 1fe88ca90..f16c37d81 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -32,7 +32,7 @@ ifeq ("@FSADM@", "yes")
 endif
 
 ifeq ("@VDOIMPORT@", "yes")
-	LVM_SCRIPTS += vdoimport.sh
+	LVM_SCRIPTS += lvm_import_vdo.sh
 endif
 
 ifeq ("@BLKDEACTIVATE@", "yes")
diff --git a/scripts/vdoimport.sh b/scripts/lvm_import_vdo.sh
similarity index 99%
rename from scripts/vdoimport.sh
rename to scripts/lvm_import_vdo.sh
index ef9659103..35140a07c 100755
--- a/scripts/vdoimport.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -28,7 +28,7 @@
 
 set -euE -o pipefail
 
-TOOL=vdoimport
+TOOL=lvm_import_vdo
 
 _SAVEPATH=$PATH
 PATH="/sbin:/usr/sbin:/bin:/usr/sbin:$PATH"
diff --git a/test/Makefile.in b/test/Makefile.in
index 093054087..ecb9e4264 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -368,7 +368,7 @@ LIB = $(addprefix lib/, $(LIB_SECURETEST) $(LIB_DMSECURETEST) $(LIB_SHARED) $(LI
 	$(Q) $(LN_S) -f $(abs_top_srcdir)/conf/lvmdbusd.profile lib/
 	$(Q) $(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
 	$(Q) $(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
-	$(Q) $(LN_S) -f $(abs_top_srcdir)/scripts/vdoimport.sh lib/vdoimport
+	$(Q) $(LN_S) -f $(abs_top_srcdir)/scripts/lvm_import_vdo.sh lib/lvm_import_vdo
 	@test "$(srcdir)" = . || \
 		for i in $(LIB_LVMLOCKD_CONF) $(LIB_MKE2FS_CONF); do \
 			test -n "$(Q)" || echo "$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/"; \
diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
index 538147b8d..2d16c973f 100644
--- a/test/shell/vdo-convert.sh
+++ b/test/shell/vdo-convert.sh
@@ -54,12 +54,12 @@ vdo create $VDOCONF --name "$VDONAME" --device="$DM_DEV_DIR/$vg/$lv1" --vdoLogic
 mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
 
 # Different VG name fails
-not vdoimport -y -v --name $vg1/$lv1 "$DM_DEV_DIR/$vg/$lv1"
+not lvm_import_vdo -y -v --name $vg1/$lv1 "$DM_DEV_DIR/$vg/$lv1"
 
 # Try just dry run and observe logging
-vdoimport --dry-run -y -v --name $lv1 "$DM_DEV_DIR/$vg/$lv1"
+lvm_import_vdo --dry-run -y -v --name $lv1 "$DM_DEV_DIR/$vg/$lv1"
 
-vdoimport -y --name $lv1 "$DM_DEV_DIR/$vg/$lv1"
+lvm_import_vdo -y --name $lv1 "$DM_DEV_DIR/$vg/$lv1"
 
 # ATM needed - since we do not call 'vdo convert' in this case
 vdo remove $VDOCONF --force --name "$VDONAME" || true
@@ -79,13 +79,13 @@ vdo create $VDOCONF --name "$VDONAME" --device="$dev1" --vdoLogicalSize=31G
 mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
 
 # Fail with an already existing volume group $vg2
-not vdoimport --dry-run -y -v --name $vg2/$lv1 "$dev1" |& tee err
+not lvm_import_vdo --dry-run -y -v --name $vg2/$lv1 "$dev1" |& tee err
 grep "already existing volume group" err
 
 # User can also convert already stopped VDO volume
 vdo stop $VDOCONF --name "$VDONAME"
 
-vdoimport -y -v --name $vg/$lv1 "$dev1"
+lvm_import_vdo -y -v --name $vg/$lv1 "$dev1"
 
 fsck -n "$DM_DEV_DIR/$vg/$lv1"
 
@@ -102,7 +102,7 @@ vdo create $VDOCONF --name "$VDONAME" --device="$dev1" --vdoLogicalSize=23G
 
 mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
 
-vdoimport -y -v --name $vg1/$lv2 "$dev1"
+lvm_import_vdo -y -v --name $vg1/$lv2 "$dev1"
 
 fsck -n "$DM_DEV_DIR/$vg1/$lv2"
 



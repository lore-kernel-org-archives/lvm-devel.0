From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 09:27:45 +0000 (UTC)
Subject: master - configure: add DEFAULT_USE_BLKID_WIPING
Message-ID: <20150624092745.BD01960DF6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20e336f21c242e7a98d11d9dc03941512c0ab69a
Commit:        20e336f21c242e7a98d11d9dc03941512c0ab69a
Parent:        6575122c63de3d400ee46ea0f400ab44b8520978
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 23 15:20:51 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 11:13:38 2015 +0200

configure: add DEFAULT_USE_BLKID_WIPING

If blkid wiping is possible, than set use_blkid_wiping=1 and
use_blkid_wiping=0 otherwise for its default value. If blkid wiping
is disabled during configure and use_blkid_wiping=1 is set by chance,
it's simply ignored - this patch is just a cleanup that makes it more
obvious for the user (we use similar logic for use_lvmetad and
use_lvmpolld settings).
---
 configure                    |   12 +++++++++++-
 configure.in                 |    9 ++++++++-
 lib/config/config_settings.h |    2 +-
 lib/misc/configure.h.in      |    3 +++
 4 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index 534948f..13d10c4 100755
--- a/configure
+++ b/configure
@@ -695,6 +695,7 @@ DL_LIBS
 DEVMAPPER
 DEFAULT_USE_LVMPOLLD
 DEFAULT_USE_LVMETAD
+DEFAULT_USE_BLKID_WIPING
 DEFAULT_SYS_DIR
 DEFAULT_SPARSE_SEGTYPE
 DEFAULT_RUN_DIR
@@ -724,7 +725,6 @@ BUILD_LVMPOLLD
 BUILD_LVMETAD
 BUILD_DMEVENTD
 BUILD_CMIRRORD
-BLKID_WIPING
 BLKID_PC
 APPLIB
 MODPROBE_CMD
@@ -11052,12 +11052,22 @@ $as_echo "yes" >&6; }
 fi
 	if test "$BLKID_WIPING" = yes; then
 		BLKID_PC="blkid"
+		DEFAULT_USE_BLKID_WIPING=1
 
 $as_echo "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
 
+	else
+		DEFAULT_USE_BLKID_WIPING=1
 	fi
+else
+	DEFAULT_USE_BLKID_WIPING=0
 fi
 
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_USE_BLKID_WIPING $DEFAULT_USE_BLKID_WIPING
+_ACEOF
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use udev-systemd protocol for jobs in background" >&5
 $as_echo_n "checking whether to use udev-systemd protocol for jobs in background... " >&6; }
diff --git a/configure.in b/configure.in
index 86ab98a..d330bd2 100644
--- a/configure.in
+++ b/configure.in
@@ -1152,9 +1152,16 @@ if test "$BLKID_WIPING" != no; then
 			   fi])
 	if test "$BLKID_WIPING" = yes; then
 		BLKID_PC="blkid"
+		DEFAULT_USE_BLKID_WIPING=1
 		AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
+	else
+		DEFAULT_USE_BLKID_WIPING=1
 	fi
+else
+	DEFAULT_USE_BLKID_WIPING=0
 fi
+AC_DEFINE_UNQUOTED(DEFAULT_USE_BLKID_WIPING, [$DEFAULT_USE_BLKID_WIPING],
+		   [Use blkid wiping by default.])
 
 ################################################################################
 dnl -- Enable udev-systemd protocol to instantiate a service for background jobs
@@ -1742,7 +1749,6 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[[()]]' '{print $2}'`
 AC_SUBST(APPLIB)
 AC_SUBST(AWK)
 AC_SUBST(BLKID_PC)
-AC_SUBST(BLKID_WIPING)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(BUILD_LVMETAD)
@@ -1783,6 +1789,7 @@ AC_SUBST(DEFAULT_RAID10_SEGTYPE)
 AC_SUBST(DEFAULT_RUN_DIR)
 AC_SUBST(DEFAULT_SPARSE_SEGTYPE)
 AC_SUBST(DEFAULT_SYS_DIR)
+AC_SUBST(DEFAULT_USE_BLKID_WIPING)
 AC_SUBST(DEFAULT_USE_LVMETAD)
 AC_SUBST(DEFAULT_USE_LVMPOLLD)
 AC_SUBST(DEVMAPPER)
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 461bacc..092e86d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -423,7 +423,7 @@ cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0,
 	"the same disks.  This setting can be used to disable the changes\n"
 	"and revert to the previous algorithm.\n")
 
-cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL, 0, NULL,
+cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), "@DEFAULT_USE_BLKID_WIPING@", 0, NULL,
 	"Use blkid to detect existing signatures on new PVs and LVs.\n"
 	"The blkid library can detect more signatures than the\n"
 	"native LVM detection code, but may take longer.\n"
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 3af8ec0..9ec997f 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -95,6 +95,9 @@
 /* Path to LVM system directory. */
 #undef DEFAULT_SYS_DIR
 
+/* Use blkid wiping by default. */
+#undef DEFAULT_USE_BLKID_WIPING
+
 /* Use lvmetad by default. */
 #undef DEFAULT_USE_LVMETAD
 



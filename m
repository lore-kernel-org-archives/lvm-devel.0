From: Julian Andres Klode <julian.klode@canonical.com>
Date: Thu, 25 Jul 2019 15:56:43 -0300
Subject: [PATCH] Detect systemd at run-time in 69-dm-lvm-metad.rules
Message-ID: <20190725185643.32110-1-julian.klode@canonical.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

systems might have systemd as their normal init systems, but
might not be using it in their initramfs; or like Debian, support
different init systems.

Detect whether we are running on systemd by checking for /run/systemd/system
and then change the behavior accordingly.

This effectively breaks compatibility with systemd versions prior to
205, as 205 was the minimum version for the feature.

Bug-Debian: https://bugs.debian.org/933011
---
 configure.ac                  | 24 ------------------------
 udev/69-dm-lvm-metad.rules.in |  6 ++++--
 udev/Makefile.in              | 10 +---------
 3 files changed, 5 insertions(+), 35 deletions(-)

diff --git a/configure.ac b/configure.ac
index 1e45c0edc..5beffd8e6 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1055,29 +1055,6 @@ AC_MSG_RESULT($BLKID_WIPING)
 AC_DEFINE_UNQUOTED(DEFAULT_USE_BLKID_WIPING, [$DEFAULT_USE_BLKID_WIPING],
 		   [Use blkid wiping by default.])
 
-################################################################################
-dnl -- Enable udev-systemd protocol to instantiate a service for background jobs
-dnl -- Requires systemd version 205 at least (including support for systemd-run)
-AC_ARG_ENABLE(udev-systemd-background-jobs,
-	      AC_HELP_STRING([--disable-udev-systemd-background-jobs],
-			     [disable udev-systemd protocol to instantiate a service for background job]),
-	      UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval,
-	      UDEV_SYSTEMD_BACKGROUND_JOBS=maybe)
-
-if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
-	pkg_config_init
-	PKG_CHECK_MODULES(SYSTEMD, systemd >= 205,
-			  [UDEV_SYSTEMD_BACKGROUND_JOBS=yes],
-			  [if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then
-				UDEV_SYSTEMD_BACKGROUND_JOBS=no
-			   else
-				AC_MSG_ERROR([bailing out... systemd >= 205 is required])
-			   fi])
-fi
-
-AC_MSG_CHECKING(whether to use udev-systemd protocol for jobs in background)
-AC_MSG_RESULT($UDEV_SYSTEMD_BACKGROUND_JOBS)
-
 ################################################################################
 dnl -- Enable udev synchronisation
 AC_MSG_CHECKING(whether to enable synchronisation with udev processing)
@@ -1772,7 +1749,6 @@ AC_SUBST(CACHE_RESTORE_CMD)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
-AC_SUBST(UDEV_SYSTEMD_BACKGROUND_JOBS)
 AC_SUBST(UDEV_RULE_EXEC_DETECTION)
 AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
 AC_SUBST(USE_TRACKING)
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index d51006496..a797bbcd6 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -73,7 +73,8 @@ GOTO="lvm_end"
 # For "systemd_background" mode, systemd takes care of this by activating
 # the lvm2-pvscan at .service only once.
 LABEL="next"
-ACTION!="(PVSCAN_ACTION)", GOTO="lvm_end"
+TEST!="/run/systemd/system", ACTION!="add", GOTO="lvm_end"
+TEST=="/run/systemd/system", ACTION!="add|change", GOTO="lvm_end"
 
 LABEL="lvm_scan"
 
@@ -83,7 +84,8 @@ ENV{SYSTEMD_READY}="1"
 # --(enable|disable)-udev-systemd-background-jobs to "configure".
 # On modern distributions with recent systemd, it's "systemd_background";
 # on others, "direct_pvscan".
-GOTO="(PVSCAN_RULE)"
+TEST!="/run/systemd/system", GOTO="direct_pvscan"
+TEST=="/run/systemd/system", GOTO="systemd_background"
 
 LABEL="systemd_background"
 
diff --git a/udev/Makefile.in b/udev/Makefile.in
index e32cba921..57a96fefb 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -43,16 +43,8 @@ else
 BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
 endif
 
-ifeq ("@UDEV_SYSTEMD_BACKGROUND_JOBS@", "yes")
-PVSCAN_RULE=systemd_background
-PVSCAN_ACTION=add|change
-else
-PVSCAN_RULE=direct_pvscan
-PVSCAN_ACTION=add
-endif
-
 %.rules: $(srcdir)/%.rules.in
-	$(Q) $(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BINDIR)+$(BINDIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(PVSCAN_RULE)+$(PVSCAN_RULE)+;s+(PVSCAN_ACTION)+$(PVSCAN_ACTION)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
+	$(Q) $(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BINDIR)+$(BINDIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
 
 %_install: %.rules
 	@echo "    [INSTALL] $<"
-- 
2.20.1



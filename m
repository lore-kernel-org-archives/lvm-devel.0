From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 11:34:46 -0400
Subject: master - configure: Remove --enable-testing
Message-ID: <201804301534.w3UFYkIZ019997@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b08797419dbb6659652cbfd0e5c9759866c1bfb
Commit:        1b08797419dbb6659652cbfd0e5c9759866c1bfb
Parent:        1ddbbb67e0928ffcad45be61bd32278e9ddb4f7d
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Apr 30 16:31:33 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 16:31:33 2018 +0100

configure: Remove --enable-testing

---
 Makefile.in  |    2 --
 WHATS_NEW    |    1 +
 configure    |   17 -----------------
 configure.ac |   10 ----------
 make.tmpl.in |    1 -
 5 files changed, 1 insertions(+), 30 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 916f54d..746be15 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -210,9 +210,7 @@ endif
 
 endif
 
-ifeq ("$(TESTING)", "yes")
 include test/unit/Makefile
-endif
 
 ifneq ($(shell which ctags),)
 .PHONY: tags
diff --git a/WHATS_NEW b/WHATS_NEW
index 205a963..fbe2418 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  --enable-testing switch for ./configure has been removed.
   --with-snapshots switch for ./configure has been removed.
   --with-mirrors switch for ./configure has been removed.
   --with-raid switch for ./configure has been removed.
diff --git a/configure b/configure
index dc372c3..f2e946e 100755
--- a/configure
+++ b/configure
@@ -653,7 +653,6 @@ UDEV_RULES
 UDEV_PC
 THIN
 TESTSUITE_DATA
-TESTING
 STATIC_LINK
 STATICDIR
 SNAPSHOTS
@@ -950,7 +949,6 @@ with_cmirrord_pidfile
 enable_debug
 with_optimisation
 enable_profiling
-enable_testing
 enable_valgrind_pool
 enable_devmapper
 enable_lvmetad
@@ -1697,7 +1695,6 @@ Optional Features:
   --enable-cmirrord       enable the cluster mirror log daemon
   --enable-debug          enable debugging
   --enable-profiling      gather gcov profiling data
-  --enable-testing        enable testing targets in the makefile
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
   --enable-lvmetad        enable the LVM Metadata Daemon
@@ -11598,19 +11595,6 @@ $as_echo "$as_me: WARNING: GD.pm perl module is not installed" >&2;}
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable unit testing" >&5
-$as_echo_n "checking whether to enable unit testing... " >&6; }
-# Check whether --enable-testing was given.
-if test "${enable_testing+set}" = set; then :
-  enableval=$enable_testing; TESTING=$enableval
-else
-  TESTING=no
-fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $TESTING" >&5
-$as_echo "$TESTING" >&6; }
-
-################################################################################
 TESTSUITE_DATA='${datarootdir}/lvm2-testsuite'
 # double eval needed ${datarootdir} -> ${prefix}/share -> real path
 
@@ -15687,7 +15671,6 @@ _ACEOF
 
 
 
-
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile l
 ibdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monito
 ring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
 
diff --git a/configure.ac b/configure.ac
index edc40c7..69b97e0 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1068,15 +1068,6 @@ if test "$PROFILING" = yes; then
 fi
 
 ################################################################################
-dnl -- Enable testing
-AC_MSG_CHECKING(whether to enable unit testing)
-AC_ARG_ENABLE(testing,
-	      AC_HELP_STRING([--enable-testing],
-			     [enable testing targets in the makefile]),
-	      TESTING=$enableval, TESTING=no)
-AC_MSG_RESULT($TESTING)
-
-################################################################################
 dnl -- Set LVM2 testsuite data
 TESTSUITE_DATA='${datarootdir}/lvm2-testsuite'
 # double eval needed ${datarootdir} -> ${prefix}/share -> real path
@@ -2123,7 +2114,6 @@ AC_SUBST(SYSTEMD_LIBS)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
-AC_SUBST(TESTING)
 AC_SUBST(TESTSUITE_DATA)
 AC_SUBST(THIN)
 AC_SUBST(THIN_CHECK_CMD)
diff --git a/make.tmpl.in b/make.tmpl.in
index 76e076a..5c124b4 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -81,7 +81,6 @@ BLKID_CFLAGS = @BLKID_CFLAGS@
 BLKID_LIBS = @BLKID_LIBS@
 SYSTEMD_LIBS = @SYSTEMD_LIBS@
 VALGRIND_CFLAGS = @VALGRIND_CFLAGS@
-TESTING = @TESTING@
 
 # Setup directory variables
 prefix = @prefix@



From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2010 22:32:19 -0000
Subject: LVM2 configure
Message-ID: <20100820223219.9174.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-08-20 22:32:19

Modified files:
	.              : configure 

Log message:
	Update configure for snitm changes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/configure	2010/08/16 22:54:35	1.139
+++ LVM2/configure	2010/08/20 22:32:18	1.140
@@ -694,6 +694,7 @@
 DEVMAPPER
 DEFAULT_RUN_DIR
 DEFAULT_LOCK_DIR
+DEFAULT_DATA_ALIGNMENT
 DEFAULT_CACHE_SUBDIR
 DEFAULT_BACKUP_SUBDIR
 DEFAULT_ARCHIVE_SUBDIR
@@ -872,6 +873,7 @@
 with_default_backup_subdir
 with_default_cache_subdir
 with_default_locking_dir
+with_default_data_alignment
 with_interface
 '
       ac_precious_vars='build_alias
@@ -1615,6 +1617,8 @@
                           default metadata cache subdir [cache]
   --with-default-locking-dir=DIR
                           default locking directory [/var/lock/lvm]
+  --with-default-data-alignment=NUM
+                          set the default data alignment in MiB [1]
   --with-interface=IFACE  choose kernel interface (ioctl) [ioctl]
 
 Some influential environment variables:
@@ -18080,6 +18084,21 @@
 
 
 ################################################################################
+
+# Check whether --with-default-data-alignment was given.
+if test "${with_default_data_alignment+set}" = set; then
+  withval=$with_default_data_alignment; DEFAULT_DATA_ALIGNMENT=$withval
+else
+  DEFAULT_DATA_ALIGNMENT=1
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_DATA_ALIGNMENT $DEFAULT_DATA_ALIGNMENT
+_ACEOF
+
+
+################################################################################
 { $as_echo "$as_me:$LINENO: checking for kernel interface choice" >&5
 $as_echo_n "checking for kernel interface choice... " >&6; }
 
@@ -18220,6 +18239,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 



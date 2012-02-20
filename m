From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 20 Feb 2012 19:36:29 -0000
Subject: LVM2 configure configure.in
Message-ID: <20120220193629.11063.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-20 19:36:28

Modified files:
	.              : configure configure.in 

Log message:
	Check whether udev supports built-in blkid.
	
	Built-in blkid is supported since udev v176 - set the UDEV_HAS_BUILTIN_BLKID
	variable appropriately so we can use it in the rules to call the built-in
	blkid conditionaly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.168&r2=1.169
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.183&r2=1.184

--- LVM2/configure	2012/02/15 11:20:12	1.168
+++ LVM2/configure	2012/02/20 19:36:27	1.169
@@ -606,6 +606,7 @@
 interface
 DMEVENTD_PIDFILE
 WRITE_INSTALL
+UDEV_HAS_BUILTIN_BLKID
 UDEV_SYNC
 UDEV_RULES
 UDEV_PC
@@ -8858,6 +8859,19 @@
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_RULES" >&5
 $as_echo "$UDEV_RULES" >&6; }
 
+if test x$UDEV_RULES = xyes; then
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether udev supports builtin blkid" >&5
+$as_echo_n "checking whether udev supports builtin blkid... " >&6; }
+	udev_version=$(udevadm info --version 2>/dev/null)
+	if test -n "$udev_version" && test "$udev_version" -ge 176; then
+		UDEV_HAS_BUILTIN_BLKID=yes
+	else
+		UDEV_HAS_BUILTIN_BLKID=no
+	fi
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_HAS_BUILTIN_BLKID" >&5
+$as_echo "$UDEV_HAS_BUILTIN_BLKID" >&6; }
+fi
+
 ################################################################################
 # Check whether --enable-compat was given.
 if test "${enable_compat+set}" = set; then :
@@ -10395,6 +10409,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_mon!
 itoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
--- LVM2/configure.in	2012/02/15 11:17:57	1.183
+++ LVM2/configure.in	2012/02/20 19:36:27	1.184
@@ -873,6 +873,17 @@
 	      UDEV_RULES=$enableval, UDEV_RULES=$UDEV_SYNC)
 AC_MSG_RESULT($UDEV_RULES)
 
+if test x$UDEV_RULES = xyes; then
+	AC_MSG_CHECKING(whether udev supports builtin blkid)
+	udev_version=$(udevadm info --version 2>/dev/null)
+	if test -n "$udev_version" && test "$udev_version" -ge 176; then
+		UDEV_HAS_BUILTIN_BLKID=yes
+	else
+		UDEV_HAS_BUILTIN_BLKID=no
+	fi
+	AC_MSG_RESULT($UDEV_HAS_BUILTIN_BLKID)
+fi
+
 ################################################################################
 dnl -- Compatibility mode
 AC_ARG_ENABLE(compat,
@@ -1454,6 +1465,7 @@
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
+AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
 AC_SUBST(CUNIT_LIBS)
 AC_SUBST(CUNIT_CFLAGS)
 AC_SUBST(WRITE_INSTALL)



From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 24 Feb 2012 13:03:52 -0000
Subject: LVM2 ./configure ./configure.in scripts/Makefi ...
Message-ID: <20120224130352.25785.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-24 13:03:51

Modified files:
	.              : configure configure.in 
	scripts        : Makefile.in 
Added files:
	scripts        : lvm2_lvmetad_init_red_hat.in 

Log message:
	Add LVMetaD init script.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_init_red_hat.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/configure	2012/02/23 13:31:49	1.172
+++ LVM2/configure	2012/02/24 13:03:50	1.173
@@ -10426,7 +10426,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scrip!
 ts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvm!
 etad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11152,6 +11152,7 @@
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
     "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
+    "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.service" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
--- LVM2/configure.in	2012/02/23 13:31:49	1.187
+++ LVM2/configure.in	2012/02/24 13:03:50	1.188
@@ -1528,6 +1528,7 @@
 po/Makefile
 scripts/clvmd_init_red_hat
 scripts/cmirrord_init_red_hat
+scripts/lvm2_lvmetad_init_red_hat
 scripts/lvm2_lvmetad_systemd_red_hat.socket
 scripts/lvm2_lvmetad_systemd_red_hat.service
 scripts/lvm2_monitoring_init_red_hat
/cvs/lvm2/LVM2/scripts/lvm2_lvmetad_init_red_hat.in,v  -->  standard output
revision 1.1
--- LVM2/scripts/lvm2_lvmetad_init_red_hat.in
+++ -	2012-02-24 13:03:52.660145000 +0000
@@ -0,0 +1,113 @@
+#!/bin/bash
+#
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+#
+# This file is part of LVM2.
+# It is required for the proper handling of failures of LVM2 mirror
+# devices that were created using the -m option of lvcreate.
+#
+#
+# chkconfig: 12345 02 99
+# description: Starts and stops LVM metadata daemon
+#
+# For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
+#
+### BEGIN INIT INFO
+# Provides: lvm2-lvmetad
+# Required-Start: $local_fs
+# Required-Stop: $local_fs
+# Default-Start: 1 2 3 4 5
+# Default-Stop: 0 6
+# Short-Description: A daemon that maintains LVM metadata state for improved
+#                    performance by avoiding further scans while running
+#                    subsequent LVM commands or while using lvm2app library.
+### END INIT INFO
+
+. /etc/init.d/functions
+
+DAEMON=lvmetad
+
+exec_prefix=@exec_prefix@
+sbindir=@sbindir@
+
+lvm_vgscan=${sbindir}/vgscan
+
+LOCK_FILE="/var/lock/subsys/$DAEMON"
+
+
+rh_status() {
+	status $DAEMON
+}
+
+rh_status_q() {
+	rh_status >/dev/null 2>&1
+}
+
+start()
+{
+	ret=0
+	action "Starting LVM metadata daemon:" $DAEMON || ${lvm_vgscan} || ret=$?
+	return $ret
+}
+
+
+stop()
+{
+	ret=0
+	action "Signaling LVM metadata daemon to exit:" kill -TERM $(pidofproc $DAEMON) || ret=$?
+	return $ret
+}
+
+rtrn=1
+
+# See how we were called.
+case "$1" in
+  start)
+	rh_status_q && exit 0
+	start
+	rtrn=$?
+	[ $rtrn = 0 ] && touch $LOCK_FILE
+	;;
+
+  stop|force-stop)
+	rh_status_q || exit 0
+	stop
+	rtrn=$?
+	[ $rtrn = 0 ] && rm -f $LOCK_FILE
+	;;
+
+  restart)
+	if stop
+	then
+		start
+	fi
+	rtrn=$?
+	;;
+
+  condrestart|try-restart)
+	rh_status_q || exit 0
+	if stop
+	then
+		start
+	fi
+	rtrn=$?
+	;;
+
+  status)
+	status $DAEMON
+	;;
+
+  *)
+	echo $"Usage: $0 {start|stop|force-stop|restart|condrestart|try-restart|status}"
+	;;
+esac
+
+exit $rtrn
--- LVM2/scripts/Makefile.in	2012/02/23 13:31:49	1.27
+++ LVM2/scripts/Makefile.in	2012/02/24 13:03:50	1.28
@@ -49,6 +49,9 @@
 ifeq ("@BUILD_DMEVENTD@", "yes")
 	$(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(initdir)/lvm2-monitor
 endif
+ifeq ("@BUILD_LVMETAD@", "yes")
+	$(INSTALL_SCRIPT) lvm2_lvmetad_init_red_hat $(initdir)/lvm2-lvmetad
+endif
 ifneq ("@CLVMD@", "none")
 	$(INSTALL_SCRIPT) clvmd_init_red_hat $(initdir)/clvmd
 endif



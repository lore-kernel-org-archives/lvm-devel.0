From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Sep 2009 23:22:41 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in sc ...
Message-ID: <20090916232241.10449.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-16 23:22:40

Modified files:
	.              : WHATS_NEW configure configure.in 
	scripts        : Makefile.in 
Added files:
	scripts        : lvm2_monitoring_init_red_hat.in 

Log message:
	Update lvm2_monitoring script.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1267&r2=1.1268
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_red_hat.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2009/09/15 19:59:04	1.1267
+++ LVM2/WHATS_NEW	2009/09/16 23:22:40	1.1268
@@ -1,5 +1,6 @@
 Version 2.02.53 - 
 =====================================
+  Update lvm2 monitoring script to lvm2_monitoring_init_red_hat.in.
   Fix lvm2app test to run under test/api subdirectory only when configured.
   Add vg_is_resizeable() and cleanup reference to VG_RESIZEABLE.
 
--- LVM2/configure	2009/09/14 22:57:46	1.105
+++ LVM2/configure	2009/09/16 23:22:40	1.106
@@ -15404,7 +15404,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16029,6 +16029,7 @@
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
+    "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
--- LVM2/configure.in	2009/09/14 22:57:46	1.113
+++ LVM2/configure.in	2009/09/16 23:22:40	1.114
@@ -1159,6 +1159,7 @@
 man/Makefile
 po/Makefile
 scripts/clvmd_init_red_hat
+scripts/lvm2_monitoring_init_red_hat
 scripts/Makefile
 test/Makefile
 test/api/Makefile
/cvs/lvm2/LVM2/scripts/lvm2_monitoring_init_red_hat.in,v  -->  standard output
revision 1.1
--- LVM2/scripts/lvm2_monitoring_init_red_hat.in
+++ -	2009-09-16 23:22:41.394613000 +0000
@@ -0,0 +1,119 @@
+#!/bin/bash
+#
+# Copyright (C) 2007-2009 Red Hat, Inc. All rights reserved.
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
+# description: Starts and stops dmeventd monitoring for lvm2
+#
+# For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
+#	       
+### BEGIN INIT INFO
+# Provides: lvm2-monitoring
+# Required-Start: $local_fs
+# Required-Stop: $local_fs
+# Default-Start: 1 2 3 4 5
+# Default-Stop: 0 6
+# Short-Description: Monitoring of LVM2 mirrors, snapshots etc. using dmeventd
+### END INIT INFO
+
+. /etc/init.d/functions
+
+DAEMON=lvm2_monitoring
+
+exec_prefix=@exec_prefix@
+sbindir=@sbindir@
+
+VGCHANGE=${sbindir}/vgchange
+VGS=${sbindir}/vgs
+
+LOCK_FILE="/var/lock/subsys/$DAEMON"
+
+WARN=1
+
+start()
+{
+	ret=0
+	# TODO do we want to separate out already active groups only?
+	VGSLIST=`$VGS --noheadings -o name 2> /dev/null`
+	for vg in $VGSLIST
+	do
+	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y $vg || ret=$?
+	done
+
+	return $ret
+}
+
+
+stop()
+{
+	ret=0
+	# TODO do we want to separate out already active groups only?
+	if test "$WARN" = "1"; then
+	   echo "Not stopping monitoring, this is a dangerous operation. Please use force-stop to override."
+	   return 1
+	fi
+	VGSLIST=`$VGS --noheadings -o name 2> /dev/null`
+	for vg in $VGSLIST
+	do
+	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n $vg || ret=$?
+	done
+	return $ret
+}
+
+rtrn=1
+
+# See how we were called.
+case "$1" in
+  start)
+	start
+	rtrn=$?
+	[ $rtrn = 0 ] && touch $LOCK_FILE
+	;;
+
+  force-stop)
+	WARN=0
+	stop
+	rtrn=$?
+	[ $rtrn = 0 ] && rm -f $LOCK_FILE
+	;;
+
+  stop)
+	test "$runlevel" = "0" && WARN=0
+	test "$runlevel" = "6" && WARN=0
+	stop
+	rtrn=$?
+	[ $rtrn = 0 ] && rm -f $LOCK_FILE
+	;;
+
+  restart)
+	WARN=0
+	if stop
+	then
+		start
+	fi 
+	rtrn=$?
+	;;
+
+  status)
+	# TODO anyone with an idea how to dump monitored volumes?
+	;;
+
+  *)
+	echo $"Usage: $0 {start|stop|restart|status|force-stop}"
+	;;
+esac
+
+exit $rtrn
--- LVM2/scripts/Makefile.in	2009/05/14 16:46:13	1.9
+++ LVM2/scripts/Makefile.in	2009/09/16 23:22:40	1.10
@@ -29,4 +29,4 @@
 
 install_lvm2: install
 
-DISTCLEAN_TARGETS += clvmd_init_red_hat
+DISTCLEAN_TARGETS += clvmd_init_red_hat lvm2_monitoring_init_red_hat



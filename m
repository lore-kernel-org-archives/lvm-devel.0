From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jan 2007 23:43:28 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/l ...
Message-ID: <20070124234328.21279.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-24 23:43:27

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/log        : log.h 
	tools          : lvchange.c vgchange.c 
Added files:
	scripts        : lvm2_monitoring_init_rhel4 

Log message:
	lvm.static no longer interacts with dmeventd unless explicitly asked to.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.555&r2=1.556
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_rhel4.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2007/01/24 16:51:23	1.555
+++ LVM2/WHATS_NEW	2007/01/24 23:43:26	1.556
@@ -1,5 +1,6 @@
 Version 2.02.20 -
 ===================================
+  lvm.static no longer interacts with dmeventd unless explicitly asked to.
   Add field definitions to report help text.
   Remove unnecessary cmd arg from target_*monitor_events().
   Add private variable to dmeventd shared library interface.
--- LVM2/lib/activate/activate.c	2007/01/24 22:06:11	1.119
+++ LVM2/lib/activate/activate.c	2007/01/24 23:43:27	1.120
@@ -653,6 +653,10 @@
 	struct lv_segment *seg;
 	int (*monitor_fn) (struct lv_segment *s, int e);
 
+	/* skip dmeventd code altogether */
+	if (dmeventd_monitor_mode() == DMEVENTD_MONITOR_IGNORE)
+		return 1;
+
 	/*
 	 * Nothing to do if dmeventd configured not to be used.
 	 */
--- LVM2/lib/log/log.h	2007/01/19 22:21:45	1.33
+++ LVM2/lib/log/log.h	2007/01/24 23:43:27	1.34
@@ -90,6 +90,8 @@
 int lockingfailed(void);
 int security_level(void);
 int mirror_in_sync(void);
+
+#define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
 
 /* Suppress messages to stdout/stderr (1) or everywhere (2) */
/cvs/lvm2/LVM2/scripts/lvm2_monitoring_init_rhel4,v  -->  standard output
revision 1.1
--- LVM2/scripts/lvm2_monitoring_init_rhel4
+++ -	2007-01-24 23:43:28.352868000 +0000
@@ -0,0 +1,98 @@
+#!/bin/bash
+#
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
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
+### BEGIN INIT INFO
+# Provides: 
+### END INIT INFO
+
+. /etc/init.d/functions
+
+VGCHANGE="/usr/sbin/vgchange"
+
+start()
+{
+    for ret in 0
+    do
+	# TODO do we want to separate out already active groups only?
+	VGS=`vgs --noheadings -o name`
+	for vg in $VGS
+	do
+	    if ! action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y $vg
+	    then
+		ret=$?
+	    fi
+	done
+
+    done
+
+    return $ret
+}
+
+
+stop()
+{
+    for ret in 0
+    do
+	# TODO do we want to separate out already active groups only?
+	VGS=`vgs --noheadings -o name`
+	for vg in $VGS
+	do
+	    if ! action "Starting monitoring for VG $vg:" $VGCHANGE --monitor n $vg
+	    then
+		ret=$?
+	    fi
+	done
+
+    done
+
+}
+
+ret=1
+
+# See how we were called.
+case "$1" in
+  start)
+	start
+	ret=$?
+	;;
+
+  stop)
+	stop
+	ret=$?
+	;;
+
+  restart)
+	if stop
+	then
+		start
+	fi 
+	ret=$?
+	;;
+
+  status)
+	# TODO anyone with an idea how to dump monitored volumes?
+	;;
+
+  *)
+	echo $"Usage: $0 {start|stop|restart|status}"
+	;;
+esac
+
+exit $ret
--- LVM2/tools/lvchange.c	2007/01/19 22:21:45	1.77
+++ LVM2/tools/lvchange.c	2007/01/24 23:43:27	1.78
@@ -94,7 +94,8 @@
 	if (lv->status & PVMOVE)
 		return 1;
 
-	if (!monitor_dev_for_events(cmd, lv, dmeventd_monitor_mode()))
+	if ((dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) &&
+	    !monitor_dev_for_events(cmd, lv, dmeventd_monitor_mode()))
 		stack;
 
 	return 1;
@@ -591,7 +592,9 @@
 		return ECMD_FAILED;
 	}
 
-	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG, DEFAULT_DMEVENTD_MONITOR));
+	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
+					    cmd->is_static ?
+					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
 	/* access permission change */
 	if (arg_count(cmd, permission_ARG)) {
--- LVM2/tools/vgchange.c	2007/01/19 22:21:45	1.56
+++ LVM2/tools/vgchange.c	2007/01/24 23:43:27	1.57
@@ -105,7 +105,8 @@
 {
 	int active, monitored;
 
-	if ((active = lvs_in_vg_activated(vg))) {
+	if ((active = lvs_in_vg_activated(vg)) &&
+	    dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) {
 		monitored = _monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode());
 		log_print("%d logical volume(s) in volume group "
 			    "\"%s\" %smonitored",
@@ -146,11 +147,13 @@
 	if (activate && (active = lvs_in_vg_activated(vg))) {
 		log_verbose("%d logical volume(s) in volume group \"%s\" "
 			    "already active", active, vg->name);
-		monitored = _monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode());
-		log_verbose("%d existing logical volume(s) in volume "
-			    "group \"%s\" %smonitored",
-			    monitored, vg->name,
-			    dmeventd_monitor_mode() ? "" : "un");
+		if (dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) {
+			monitored = _monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode());
+			log_verbose("%d existing logical volume(s) in volume "
+				    "group \"%s\" %smonitored",
+				    monitored, vg->name,
+				    dmeventd_monitor_mode() ? "" : "un");
+		}
 	}
 
 	if (activate && _activate_lvs_in_vg(cmd, vg, available))
@@ -532,7 +535,9 @@
 		return ECMD_FAILED;
 	}
 
-	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG, DEFAULT_DMEVENTD_MONITOR));
+	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
+					    cmd->is_static ?
+					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
 	if (arg_count(cmd, available_ARG))
 		r = _vgchange_available(cmd, vg);



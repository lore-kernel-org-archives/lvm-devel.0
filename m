From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2010 19:03:29 -0000
Subject: LVM2/tools vgchange.c
Message-ID: <20100726190329.19464.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-26 19:03:29

Modified files:
	tools          : vgchange.c 

Log message:
	Remove unneeded "active" variable in vgchange_monitoring().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/tools/vgchange.c	2010/07/09 15:34:48	1.109
+++ LVM2/tools/vgchange.c	2010/07/26 19:03:29	1.110
@@ -160,9 +160,9 @@
 
 static int _vgchange_monitoring(struct cmd_context *cmd, struct volume_group *vg)
 {
-	int active, monitored;
+	int monitored;
 
-	if ((active = lvs_in_vg_activated(vg)) &&
+	if (lvs_in_vg_activated(vg) &&
 	    dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) {
 		monitored = _monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode());
 		log_print("%d logical volume(s) in volume group "



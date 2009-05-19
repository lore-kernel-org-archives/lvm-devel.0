From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 May 2009 10:25:17 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/mirr ...
Message-ID: <20090519102517.19842.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-19 10:25:17

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 

Log message:
	Use lvconvert --repair in dmeventd DSO (mornfall)
	
	This means two things:
	
	1) Non-mirrored LVs will be no longer affected by mirror monitoring. (Before,
	if you had a LV that went partially missing on a VG where a mirror leg failed,
	this LV would be removed automatically by dmeventd... Probably not an
	unrecoverable dataloss bug, but still quite unpleasant.)
	
	2) If enough parallel PV space is available at the time of the mirror failure,
	the failed devices will be automatically replaced using this spare space. Which
	(and whether) free space may be used is still not configurable, but is a
	planned feature. Since it is relatively easy to undo the action by converting
	the mirror manually, I don't consider this to be a showstopper. In fact, I
	think the compromise is much better than what we have now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1114&r2=1.1115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2009/05/19 09:51:02	1.1114
+++ LVM2/WHATS_NEW	2009/05/19 10:25:16	1.1115
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Use lvconvert --repair in dmeventd mirror DSO.
   Fix pvmove to revert operation if temporary mirror creation fails.
   Fix metadata export for VG with missing PVs.
   Add vgimportclone and install it and the man page by default.
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2008/09/25 15:52:29	1.20
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/05/19 10:25:16	1.21
@@ -152,7 +152,7 @@
 	}
 
 	/* FIXME Is any sanity-checking required on %s? */
-	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "vgreduce --config devices{ignore_suspended_devices=1} --removemissing --force %s", vg)) {
+	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair %s/%s", vg, lv)) {
 		/* this error should be caught above, but doesn't hurt to check again */
 		syslog(LOG_ERR, "Unable to form LVM command: Device name too long");
 		dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */



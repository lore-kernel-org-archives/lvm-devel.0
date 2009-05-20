From: agk@sourceware.org <agk@sourceware.org>
Date: 20 May 2009 22:24:49 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/mirr ...
Message-ID: <20090520222449.32576.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-20 22:24:49

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 

Log message:
	Revert:
	Use lvconvert --repair in dmeventd mirror DSO.
	for now.
	
	It replaces bad behaviour in one set of circumstances with bad behaviour
	in a different set.  We think the behaviour needs to be more configurable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1119&r2=1.1120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2009/05/20 11:09:49	1.1119
+++ LVM2/WHATS_NEW	2009/05/20 22:24:48	1.1120
@@ -5,7 +5,6 @@
   Enable online resizing of mirrors.
   Use suspend with flush when device size was changed during table preload.
   Introduce CLVMD_CMD_LOCK_QUERY command for clvmd.
-  Use lvconvert --repair in dmeventd mirror DSO.
   Fix pvmove to revert operation if temporary mirror creation fails.
   Fix metadata export for VG with missing PVs.
   Add vgimportclone and install it and the man page by default.
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/05/19 10:25:16	1.21
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/05/20 22:24:49	1.22
@@ -152,7 +152,7 @@
 	}
 
 	/* FIXME Is any sanity-checking required on %s? */
-	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair %s/%s", vg, lv)) {
+	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "vgreduce --config devices{ignore_suspended_devices=1} --removemissing --force %s", vg)) {
 		/* this error should be caught above, but doesn't hurt to check again */
 		syslog(LOG_ERR, "Unable to form LVM command: Device name too long");
 		dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */



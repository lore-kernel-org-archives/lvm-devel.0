From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Jan 2007 23:32:29 -0000
Subject: LVM2 ./WHATS_NEW dmeventd/mirror/dmeventd_mirror.c
Message-ID: <20070125233229.15148.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-25 23:32:29

Modified files:
	.              : WHATS_NEW 
	dmeventd/mirror: dmeventd_mirror.c 

Log message:
	dmeventd mirror sets ignore_suspended_devices and avoids scanning mirrors.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.559&r2=1.560
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW	2007/01/25 21:22:29	1.559
+++ LVM2/WHATS_NEW	2007/01/25 23:32:29	1.560
@@ -1,5 +1,6 @@
 Version 2.02.20 -
 ===================================
+  dmeventd mirror sets ignore_suspended_devices and avoids scanning mirrors.
   Add devices/ignore_suspended_devices to ignore suspended dm devices.
   Add some missing close() and fclose() return code checks.
   Fix exit statuses of reporting tools (2.02.19).
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/23 17:40:40	1.16
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/25 23:32:29	1.17
@@ -151,7 +151,7 @@
 	}
 
 	/* FIXME Is any sanity-checking required on %s? */
-	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "vgreduce --removemissing %s", vg)) {
+	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "vgreduce --config devices{ignore_suspended_devices=1} --removemissing %s", vg)) {
 		/* this error should be caught above, but doesn't hurt to check again */
 		syslog(LOG_ERR, "Unable to form LVM command: Device name too long");
 		dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */



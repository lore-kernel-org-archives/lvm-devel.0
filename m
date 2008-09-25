From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 25 Sep 2008 15:52:29 -0000
Subject: LVM2 ./WHATS_NEW dmeventd/mirror/dmeventd_mirror.c
Message-ID: <20080925155229.4236.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-09-25 15:52:29

Modified files:
	.              : WHATS_NEW 
	dmeventd/mirror: dmeventd_mirror.c 

Log message:
	Fix mirror DSO to call vgreduce with proper parameters.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.965&r2=1.966
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2008/09/24 16:32:51	1.965
+++ LVM2/WHATS_NEW	2008/09/25 15:52:28	1.966
@@ -1,5 +1,6 @@
 Version 2.02.41 -
 =====================================
+  Fix mirror DSO to call vgreduce with proper parameters.
   Fix validation of --minor and --major in lvcreate to require -My always.
   Fix release: clvmd build, vgreduce consolidate & tests, /dev/ioerror warning.
 
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2008/01/31 12:19:35	1.19
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2008/09/25 15:52:29	1.20
@@ -152,7 +152,7 @@
 	}
 
 	/* FIXME Is any sanity-checking required on %s? */
-	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "vgreduce --config devices{ignore_suspended_devices=1} --removemissing %s", vg)) {
+	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "vgreduce --config devices{ignore_suspended_devices=1} --removemissing --force %s", vg)) {
 		/* this error should be caught above, but doesn't hurt to check again */
 		syslog(LOG_ERR, "Unable to form LVM command: Device name too long");
 		dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */



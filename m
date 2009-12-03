From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Dec 2009 19:22:25 -0000
Subject: LVM2 ./WHATS_NEW tools/pvmove.c
Message-ID: <20091203192225.27023.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-03 19:22:24

Modified files:
	.              : WHATS_NEW 
	tools          : pvmove.c 

Log message:
	Fix pvmove test mode to not fail and do not poll.
	
	Test mode should not fail nor try to poll non-existent devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1339&r2=1.1340
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2009/12/03 19:20:48	1.1339
+++ LVM2/WHATS_NEW	2009/12/03 19:22:24	1.1340
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Fix pvmove test mode to not fail and do not poll.
   Fix error message if VG already exist in vgcreate.
   Fix tools to use log_error when stopped by user.
   Fix lvcreate --readahead.
--- LVM2/tools/pvmove.c	2009/11/03 15:50:44	1.68
+++ LVM2/tools/pvmove.c	2009/12/03 19:22:24	1.69
@@ -312,8 +312,10 @@
 	/* FIXME: Add option to use a log */
 	if (first_time) {
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
-			if (test_mode())
+			if (test_mode()) {
+				r = 1;
 				goto out;
+			}
 
 			/*
 			 * Nothing changed yet, try to revert pvmove.
@@ -570,6 +572,9 @@
 int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
 		unsigned background)
 {
+	if (test_mode())
+		return ECMD_PROCESSED;
+
 	return poll_daemon(cmd, pv_name, NULL, background, PVMOVE, &_pvmove_fns,
 			   "Moved");
 }



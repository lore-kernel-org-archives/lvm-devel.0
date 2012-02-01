From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Feb 2012 15:05:53 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20120201150553.15206.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-01 15:05:53

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Adjust comments

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.175&r2=1.176

--- LVM2/lib/metadata/mirror.c	2012/02/01 13:50:37	1.175
+++ LVM2/lib/metadata/mirror.c	2012/02/01 15:05:53	1.176
@@ -325,8 +325,9 @@
 
 	backup(log_lv->vg);
 
-	// FIXME: Wait here explicitly, so deactivation of log_lv is finished
+	/* Wait for events following any deactivation before reactivating */
 	sync_local_dev_names(cmd);
+
 	if (!activate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to activate mirror log.");
 		goto revert_new_lv;
@@ -439,8 +440,9 @@
 	if (!_activate_lv_like_model(lv, lv))
 		return_0;
 
-	// FIXME: Wait here should not be need
+	/* FIXME Is this superfluous now? */
 	sync_local_dev_names(cmd);
+
 	if (!deactivate_lv(cmd, lv))
 		return_0;
 



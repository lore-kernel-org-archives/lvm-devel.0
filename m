From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 15:05:40 -0000
Subject: LVM2/tools polldaemon.c
Message-ID: <20110218150540.12333.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 15:05:40

Modified files:
	tools          : polldaemon.c 

Log message:
	Use return_0 to get bactrace

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/tools/polldaemon.c	2011/01/19 23:11:39	1.43
+++ LVM2/tools/polldaemon.c	2011/02/18 15:05:40	1.44
@@ -148,7 +148,7 @@
 	/* Finished? Or progress to next segment? */
 	if (progress == PROGRESS_FINISHED_ALL) {
 		if (!parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed))
-			return 0;
+			return_0;
 	} else {
 		if (parms->poll_fns->update_metadata &&
 		    !parms->poll_fns->update_metadata(cmd, vg, lv, lvs_changed, 0)) {
@@ -211,7 +211,7 @@
 
 		if (!_check_lv_status(cmd, vg, lv, name, parms, &finished)) {
 			unlock_and_free_vg(cmd, vg, vg->name);
-			return 0;
+			return_0;
 		}
 
 		unlock_and_free_vg(cmd, vg, vg->name);



From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 8 Jan 2010 21:53:11 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c tools/polld ...
Message-ID: <20100108215311.26597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-08 21:53:08

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c polldaemon.c 

Log message:
	Change background polldaemon's process name to "(lvm2)".
	
	Made .update_metadata optional in 'struct poll_functions' definitions;
	eliminated _update_lvconvert_mirror() stub.
	
	Tweak a mirror-specific error message in the generic polldaemon code.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1374&r2=1.1375
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/WHATS_NEW	2010/01/08 14:03:54	1.1374
+++ LVM2/WHATS_NEW	2010/01/08 21:53:07	1.1375
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Change background polldaemon's process name to "(lvm2)".
   Allow vgremove of a VG with PVs missing.
   Keep log type consistent when changing mirror image count.
   Always set environment variables for an LVM2 device in 11-dm-lvm.rules.
--- LVM2/tools/lvconvert.c	2010/01/08 13:04:10	1.103
+++ LVM2/tools/lvconvert.c	2010/01/08 21:53:08	1.104
@@ -258,16 +258,6 @@
 	return lv;
 }
 
-static int _update_lvconvert_mirror(struct cmd_context *cmd __attribute((unused)),
-				    struct volume_group *vg __attribute((unused)),
-				    struct logical_volume *lv __attribute((unused)),
-				    struct dm_list *lvs_changed __attribute((unused)),
-				    unsigned flags __attribute((unused)))
-{
-	/* lvconvert mirror doesn't require periodical metadata update */
-	return 1;
-}
-
 static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 				    struct volume_group *vg,
 				    struct logical_volume *lv,
@@ -316,7 +306,6 @@
 	.get_copy_vg = _get_lvconvert_vg,
 	.get_copy_lv = _get_lvconvert_lv,
 	.poll_progress = poll_mirror_progress,
-	.update_metadata = _update_lvconvert_mirror,
 	.finish_copy = _finish_lvconvert_mirror,
 };
 
--- LVM2/tools/polldaemon.c	2009/11/03 15:50:44	1.29
+++ LVM2/tools/polldaemon.c	2010/01/08 21:53:08	1.30
@@ -54,7 +54,7 @@
 	close(STDOUT_FILENO);
 	close(STDERR_FILENO);
 
-	strncpy(*cmd->argv, "(lvm2copyd)", strlen(*cmd->argv));
+	strncpy(*cmd->argv, "(lvm2)", strlen(*cmd->argv));
 
 	reset_locking();
 	lvmcache_init();
@@ -137,8 +137,8 @@
 		if (!parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed))
 			return 0;
 	} else {
-		if (!parms->poll_fns->update_metadata(cmd, vg, lv, lvs_changed,
-						      0)) {
+		if (parms->poll_fns->update_metadata &&
+		    !parms->poll_fns->update_metadata(cmd, vg, lv, lvs_changed, 0)) {
 			log_error("ABORTING: Segment progression failed.");
 			parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed);
 			return 0;
@@ -177,7 +177,7 @@
 
 		if (!(lv = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid,
 							parms->lv_type))) {
-			log_error("ABORTING: Can't find mirror LV in %s for %s",
+			log_error("ABORTING: Can't find LV in %s for %s",
 				  vg->name, name);
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return 0;



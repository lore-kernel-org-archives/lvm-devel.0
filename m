From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 19 Sep 2011 14:28:24 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20110919142824.15359.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-19 14:28:24

Modified files:
	lib/metadata   : mirror.c 

Log message:
	fix compiler warning.
	
	Compiler says variable may be used uninitialized.  It can't be, but we
	initialize the variable to NULL anyway.  Also, remove the double initialization
	of another variable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.170&r2=1.171

--- LVM2/lib/metadata/mirror.c	2011/09/16 16:41:37	1.170
+++ LVM2/lib/metadata/mirror.c	2011/09/19 14:28:23	1.171
@@ -584,7 +584,7 @@
 	struct logical_volume *detached_log_lv = NULL;
 	struct lv_segment *mirrored_seg = first_seg(lv);
 	struct dm_list split_images;
-	struct lv_list *lvl, *new_lvl;
+	struct lv_list *lvl, *new_lvl = NULL;
 	struct cmd_context *cmd = lv->vg->cmd;
 
 	if (!(lv->status & MIRRORED)) {
@@ -748,7 +748,6 @@
 	 *   - activate the new LV
 	 */
 	sync_local_dev_names(lv->vg->cmd);
-	new_lv = NULL;
 	dm_list_iterate_items(lvl, &split_images) {
 		if (!new_lv) {
 			/* Grab 1st sub-LV for later */



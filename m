From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Dec 2011 18:00:04 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20111208180004.32234.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-12-08 18:00:04

Modified files:
	tools          : lvconvert.c 

Log message:
	tag uninit var

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.176&r2=1.177

--- LVM2/tools/lvconvert.c	2011/12/06 19:30:17	1.176
+++ LVM2/tools/lvconvert.c	2011/12/08 18:00:03	1.177
@@ -1460,7 +1460,7 @@
 static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
 {
 	int replace = 0;
-	int image_count;
+	int uninitialized_var(image_count);
 	struct dm_list *failed_pvs;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);



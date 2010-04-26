From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Apr 2010 18:12:47 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100426181247.17458.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-26 18:12:44

Modified files:
	tools          : lvconvert.c 

Log message:
	add comments

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/tools/lvconvert.c	2010/04/21 14:04:26	1.130
+++ LVM2/tools/lvconvert.c	2010/04/26 18:12:40	1.131
@@ -1195,6 +1195,9 @@
 	if (!_lv_update_log_type(cmd, lp, lv, failed_pvs, new_log_count))
 		return 0;
 
+	/*
+	 * Remove all failed_pvs
+	 */
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, failed_pvs,
 				    lp->mirrors, new_log_count))
 		return 0;
@@ -1570,6 +1573,9 @@
 	if (!lv)
 		goto_out;
 
+	/*
+	 * lp->pvh holds the list of PVs available for allocation or removal
+	 */
 	if (lp->pv_count) {
 		if (!(lp->pvh = create_pv_list(cmd->mem, lv->vg, lp->pv_count,
 					      lp->pvs, 0)))



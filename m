From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Jul 2011 14:56:58 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20110704145658.19241.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-04 14:56:58

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	reinstate accidentally-removed lines to fix pvmove again

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.222&r2=1.223

--- LVM2/lib/activate/dev_manager.c	2011/07/01 14:09:19	1.222
+++ LVM2/lib/activate/dev_manager.c	2011/07/04 14:56:58	1.223
@@ -1802,10 +1802,6 @@
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int *flush_required)
 {
-	/* FIXME Update the pvmove implementation! */
-	if ((lv->status & PVMOVE) || (lv->status & LOCKED))
-		return 1;
-
 	if (!_tree_action(dm, lv, laopts, PRELOAD))
 		return 0;
 



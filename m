From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Jan 2010 15:58:12 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20100105155812.29379.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-05 15:58:12

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Resume volumes in reverse order to preserve memlock pairing.
	
	If renaming snapshot with virtual origin, the origin is renamed too.
	But the code must resume LVs in reverse order to properly
	pair memlock (in cluster locking).
	
	(The resume of snapshot resumes origin too and later resume
	is ignored otherwise.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1354&r2=1.1355
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.189&r2=1.190

--- LVM2/WHATS_NEW	2009/12/18 12:45:41	1.1354
+++ LVM2/WHATS_NEW	2010/01/05 15:58:11	1.1355
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Resume renamed volumes in reverse order to preserve memlock pairing.
   Drop metadata cache after device was autorepaired and removed from VG.
   Remove missing flag in metadata if PV reappeared and is empty.
   Destroy allocated mempool in _vg_read_orphans() error path.
--- LVM2/lib/metadata/lv_manip.c	2009/12/04 17:48:32	1.189
+++ LVM2/lib/metadata/lv_manip.c	2010/01/05 15:58:11	1.190
@@ -1767,7 +1767,7 @@
 	struct volume_group *vg = lv->vg;
 	struct lv_names lv_names;
 	DM_LIST_INIT(lvs_changed);
-	struct lv_list lvl, lvl2;
+	struct lv_list lvl, lvl2, *lvlp;
 	int r = 0;
 
 	/* rename is not allowed on sub LVs */
@@ -1822,7 +1822,13 @@
 	if (!(r = vg_commit(vg)))
 		stack;
 
-	resume_lvs(cmd, &lvs_changed);
+	/*
+	 * FIXME: resume LVs in reverse order to prevent memory
+	 * lock imbalance when resuming virtual snapshot origin
+	 * (resume of snapshot resumes origin too)
+	 */
+	dm_list_iterate_back_items(lvlp, &lvs_changed)
+		resume_lv(cmd, lvlp->lv);
 out:
 	backup(vg);
 	return r;



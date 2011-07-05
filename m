From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jul 2011 01:08:43 -0000
Subject: LVM2/lib/activate activate.c
Message-ID: <20110705010843.27535.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-05 01:08:43

Modified files:
	lib/activate   : activate.c 

Log message:
	Snapshots LVs are never loaded in their own right, only along with their
	origin.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.205&r2=1.206

--- LVM2/lib/activate/activate.c	2011/07/01 14:09:19	1.205
+++ LVM2/lib/activate/activate.c	2011/07/05 01:08:42	1.206
@@ -1112,7 +1112,7 @@
 	struct lv_list *lvl_pre;
 
 	if ((lvl_pre = find_lv_in_vg(detached->lv_pre->vg, lv->name))) {
-		if (lv_is_visible(lvl_pre->lv) && lv_is_active(lv) &&
+		if (lv_is_visible(lvl_pre->lv) && lv_is_active(lv) && !lv_is_cow(lv) &&
 		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
 			return_0;
 	}



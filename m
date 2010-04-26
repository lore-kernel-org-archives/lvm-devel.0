From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Apr 2010 18:31:59 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20100426183159.28003.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-26 18:31:59

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Fix lvconvert error message when existing mirrored LV is not found.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1537&r2=1.1538
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/WHATS_NEW	2010/04/23 19:27:10	1.1537
+++ LVM2/WHATS_NEW	2010/04/26 18:31:58	1.1538
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Fix lvconvert error message when existing mirrored LV is not found.
   Disallow the direct removal of a merging snapshot.
   Set appropriate udev flags for reserved LVs.
   Don't preload the origin when removing a snapshot whose merge is pending.
--- LVM2/tools/lvconvert.c	2010/04/26 18:12:40	1.131
+++ LVM2/tools/lvconvert.c	2010/04/26 18:31:58	1.132
@@ -1533,12 +1533,11 @@
 	vg = _get_lvconvert_vg(cmd, vg_name, NULL);
 	if (vg_read_error(vg)) {
 		vg_release(vg);
-		log_error("ABORTING: Can't reread VG for %s", vg_name);
-		return NULL;
+		return_NULL;
 	}
 
 	if (!(lv = _get_lvconvert_lv(cmd, vg, lv_name, NULL, 0))) {
-		log_error("ABORTING: Can't find LV %s in VG %s", lv_name, vg_name);
+		log_error("Can't find LV %s in VG %s", lv_name, vg_name);
 		unlock_and_release_vg(cmd, vg, vg_name);
 		return NULL;
 	}
@@ -1616,8 +1615,10 @@
 	vg_name = lv->vg->name;
 	unlock_vg(cmd, vg_name);
 	refreshed_lv = get_vg_lock_and_logical_volume(cmd, vg_name, lv->name);
-	if (!refreshed_lv)
+	if (!refreshed_lv) {
+		log_error("ABORTING: Can't reread LV %s/%s", vg_name, lv->name);
 		return ECMD_FAILED;
+	}
 
 	lp->lv_to_poll = refreshed_lv;
 	ret = _lvconvert_single(cmd, refreshed_lv, lp);



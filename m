From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 31 Oct 2009 17:39:23 -0000
Subject: LVM2/tools vgcreate.c
Message-ID: <20091031173923.12626.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-31 17:39:22

Modified files:
	tools          : vgcreate.c 

Log message:
	Update vgcreate to call vg_set_clustered().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/tools/vgcreate.c	2009/10/05 20:55:57	1.70
+++ LVM2/tools/vgcreate.c	2009/10/31 17:39:22	1.71
@@ -65,7 +65,8 @@
 	if (!vg_set_extent_size(vg, vp_new.extent_size) ||
 	    !vg_set_max_lv(vg, vp_new.max_lv) ||
 	    !vg_set_max_pv(vg, vp_new.max_pv) ||
-	    !vg_set_alloc_policy(vg, vp_new.alloc))
+	    !vg_set_alloc_policy(vg, vp_new.alloc) ||
+	    !vg_set_clustered(vg, vp_new.clustered))
 		goto_bad;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
@@ -103,12 +104,9 @@
 		}
 	}
 
-	/* FIXME: move this inside vg_create? */
-	if (vp_new.clustered) {
-		vg->status |= CLUSTERED;
+	if (vg_is_clustered(vg)) {
 		clustered_message = "Clustered ";
 	} else {
-		vg->status &= ~CLUSTERED;
 		if (locking_is_clustered())
 			clustered_message = "Non-clustered ";
 	}



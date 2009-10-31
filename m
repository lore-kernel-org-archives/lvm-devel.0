From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 31 Oct 2009 17:43:58 -0000
Subject: LVM2 tools/vgsplit.c ./WHATS_NEW
Message-ID: <20091031174358.14423.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-31 17:43:57

Modified files:
	tools          : vgsplit.c 
	.              : WHATS_NEW 

Log message:
	Update vgsplit to call vg_set_clustered().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1309&r2=1.1310

--- LVM2/tools/vgsplit.c	2009/10/26 10:01:57	1.95
+++ LVM2/tools/vgsplit.c	2009/10/31 17:43:57	1.96
@@ -371,7 +371,7 @@
 		vp_def.max_pv = vg_from->max_pv;
 		vp_def.max_lv = vg_from->max_lv;
 		vp_def.alloc = vg_from->alloc;
-		vp_def.clustered = DEFAULT_CLUSTERED;
+		vp_def.clustered = vg_is_clustered(vg_from);
 
 		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def)) {
 			r = EINVALID_CMD_LINE;
@@ -386,11 +386,9 @@
 		if (!vg_set_extent_size(vg_to, vp_new.extent_size) ||
 		    !vg_set_max_lv(vg_to, vp_new.max_lv) ||
 		    !vg_set_max_pv(vg_to, vp_new.max_pv) ||
-		    !vg_set_alloc_policy(vg_to, vp_new.alloc))
+		    !vg_set_alloc_policy(vg_to, vp_new.alloc) ||
+		    !vg_set_clustered(vg_to, vp_new.clustered))
 			goto_bad;
-
-		if (vg_is_clustered(vg_from))
-			vg_to->status |= CLUSTERED;
 	}
 
 	/* Archive vg_from before changing it */
--- LVM2/WHATS_NEW	2009/10/30 13:07:49	1.1309
+++ LVM2/WHATS_NEW	2009/10/31 17:43:57	1.1310
@@ -1,5 +1,8 @@
 Version 2.02.55 -
 ===================================
+  Update vgsplit and vgcreate to use vg_set_clustered.
+  Add vg_mda_count and vg_set_clustered library function.
+  Add more vgcreate and vgsplit nightly tests.
   Insert some missing stack macros into activation code.
   Recognise DRBD device part and handle it similar to MD devices.
 



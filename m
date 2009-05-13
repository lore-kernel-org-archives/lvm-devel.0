From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2009 21:28:32 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20090513212832.30225.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-13 21:28:31

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
	                 snapshot_manip.c 
	tools          : lvcreate.c pvmove.c 

Log message:
	Remove unneeded import parameter from lv_create_empty.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1109&r2=1.1110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2009/05/13 21:27:43	1.1109
+++ LVM2/WHATS_NEW	2009/05/13 21:28:31	1.1110
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Remove unneeded import parameter from lv_create_empty.
   Merge lv_is_displayable and lv_is_visible functions.
   Introduce lv_set_visible & lv_set_invisible functions.
   Fix lv_is_visible to handle virtual origin.
--- LVM2/lib/metadata/lv_manip.c	2009/05/13 21:27:43	1.170
+++ LVM2/lib/metadata/lv_manip.c	2009/05/13 21:28:31	1.171
@@ -1811,7 +1811,6 @@
 				       union lvid *lvid,
 				       uint32_t status,
 				       alloc_policy_t alloc,
-				       int import,
 				       struct volume_group *vg)
 {
 	struct format_instance *fi = vg->fid;
@@ -1831,8 +1830,7 @@
 		return NULL;
 	}
 
-	if (!import)
-		log_verbose("Creating logical volume %s", name);
+	log_verbose("Creating logical volume %s", name);
 
 	if (!(lv = dm_pool_zalloc(vg->vgmem, sizeof(*lv))))
 		return_NULL;
@@ -2417,7 +2415,7 @@
 	}
 
 	if (!(layer_lv = lv_create_empty(name, NULL, LVM_READ | LVM_WRITE,
-					 ALLOC_INHERIT, 0, lv_where->vg))) {
+					 ALLOC_INHERIT, lv_where->vg))) {
 		log_error("Creation of layer LV failed");
 		return NULL;
 	}
--- LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:27:43	1.71
+++ LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:28:31	1.72
@@ -448,7 +448,6 @@
 				       union lvid *lvid,
 				       uint32_t status,
 				       alloc_policy_t alloc,
-				       int import,
 				       struct volume_group *vg);
 
 /* Write out LV contents */
--- LVM2/lib/metadata/mirror.c	2009/05/13 21:26:45	1.86
+++ LVM2/lib/metadata/mirror.c	2009/05/13 21:28:31	1.87
@@ -932,7 +932,7 @@
 	for (m = 0; m < num_mirrors; m++) {
 		if (!(img_lvs[m] = lv_create_empty(img_name,
 					     NULL, LVM_READ | LVM_WRITE,
-					     ALLOC_INHERIT, 0, lv->vg))) {
+					     ALLOC_INHERIT, lv->vg))) {
 			log_error("Aborting. Failed to create mirror image LV. "
 				  "Remove new LV and retry.");
 			return 0;
@@ -1266,7 +1266,7 @@
 
 	if (!(log_lv = lv_create_empty(log_name, NULL,
 				       VISIBLE_LV | LVM_READ | LVM_WRITE,
-				       alloc, 0, lv->vg)))
+				       alloc, lv->vg)))
 		return_NULL;
 
 	if (!lv_add_log_segment(ah, log_lv))
--- LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:27:43	1.41
+++ LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:28:31	1.42
@@ -105,7 +105,7 @@
 
 	if (!(snap = lv_create_empty("snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
-				     ALLOC_INHERIT, 1, origin->vg)))
+				     ALLOC_INHERIT, origin->vg)))
 		return_0;
 
 	snap->le_count = extent_count;
--- LVM2/tools/lvcreate.c	2009/05/13 21:21:59	1.186
+++ LVM2/tools/lvcreate.c	2009/05/13 21:28:31	1.187
@@ -577,7 +577,7 @@
 	}
 
 	if (!(lv = lv_create_empty(vorigin_name, NULL, permission,
-				   ALLOC_INHERIT, 0, vg)))
+				   ALLOC_INHERIT, vg)))
 		return_0;
 
 	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents, NULL, 0u, 0u,
@@ -824,7 +824,7 @@
 	}
 
 	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
-				   status, lp->alloc, 0, vg)))
+				   status, lp->alloc, vg)))
 		return_0;
 
 	if (lp->read_ahead) {
--- LVM2/tools/pvmove.c	2009/04/21 14:31:58	1.57
+++ LVM2/tools/pvmove.c	2009/05/13 21:28:31	1.58
@@ -191,7 +191,7 @@
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
 					LVM_READ | LVM_WRITE,
-					ALLOC_CONTIGUOUS, 0, vg))) {
+					ALLOC_CONTIGUOUS, vg))) {
 		log_error("Creation of temporary pvmove LV failed");
 		return NULL;
 	}



From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Oct 2007 19:20:39 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
Message-ID: <20071011192039.1291.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-10-11 19:20:38

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
	                 snapshot_manip.c 
	tools          : lvcreate.c pvmove.c toollib.c 

Log message:
	Non-functional change - refactor lv_create_empty().
	Remove struct format_instance param - we can safely obtain
	this from vg->fid inside the function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/lib/metadata/lv_manip.c	2007/09/24 21:30:00	1.129
+++ LVM2/lib/metadata/lv_manip.c	2007/10/11 19:20:38	1.130
@@ -1656,14 +1656,14 @@
 /*
  * Create a new empty LV.
  */
-struct logical_volume *lv_create_empty(struct format_instance *fi,
-				       const char *name,
+struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
 				       uint32_t status,
 				       alloc_policy_t alloc,
 				       int import,
 				       struct volume_group *vg)
 {
+	struct format_instance *fi = vg->fid;
 	struct cmd_context *cmd = vg->cmd;
 	struct lv_list *ll = NULL;
 	struct logical_volume *lv;
--- LVM2/lib/metadata/metadata-exported.h	2007/10/11 18:51:21	1.17
+++ LVM2/lib/metadata/metadata-exported.h	2007/10/11 19:20:38	1.18
@@ -349,8 +349,7 @@
 		  struct volume_group *vg_to);
 
 /* Manipulate LVs */
-struct logical_volume *lv_create_empty(struct format_instance *fi,
-				       const char *name,
+struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
 				       uint32_t status,
 				       alloc_policy_t alloc,
--- LVM2/lib/metadata/mirror.c	2007/08/29 20:19:11	1.42
+++ LVM2/lib/metadata/mirror.c	2007/10/11 19:20:38	1.43
@@ -439,7 +439,7 @@
 	}
 
 	for (m = 0; m < num_mirrors; m++) {
-		if (!(img_lvs[m] = lv_create_empty(lv->vg->fid, img_name,
+		if (!(img_lvs[m] = lv_create_empty(img_name,
 					     NULL, LVM_READ | LVM_WRITE,
 					     ALLOC_INHERIT, 0, lv->vg))) {
 			log_error("Aborting. Failed to create mirror image LV. "
--- LVM2/lib/metadata/snapshot_manip.c	2007/10/11 18:51:21	1.26
+++ LVM2/lib/metadata/snapshot_manip.c	2007/10/11 19:20:38	1.27
@@ -53,7 +53,6 @@
 		    struct logical_volume *cow, union lvid *lvid,
 		    uint32_t extent_count, uint32_t chunk_size)
 {
-	struct format_instance *fid = vg->fid;
 	struct logical_volume *snap;
 	struct lv_segment *seg;
 
@@ -65,7 +64,7 @@
 		return 0;
 	}
 
-	if (!(snap = lv_create_empty(fid, name ? name : "snapshot%d",
+	if (!(snap = lv_create_empty(name ? name : "snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
 				     ALLOC_INHERIT, 1, origin->vg))) {
 		stack;
--- LVM2/tools/lvcreate.c	2007/10/11 18:51:21	1.151
+++ LVM2/tools/lvcreate.c	2007/10/11 19:20:38	1.152
@@ -762,7 +762,7 @@
 		}
 	}
 
-	if (!(lv = lv_create_empty(vg->fid, lv_name ? lv_name : "lvol%d", NULL,
+	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
 				   status, lp->alloc, 0, vg))) {
 		stack;
 		goto error;
--- LVM2/tools/pvmove.c	2007/08/20 20:55:30	1.41
+++ LVM2/tools/pvmove.c	2007/10/11 19:20:38	1.42
@@ -119,7 +119,7 @@
 	struct lv_list *lvl;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
-	if (!(lv_mirr = lv_create_empty(vg->fid, "pvmove%d", NULL,
+	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
 					LVM_READ | LVM_WRITE,
 					ALLOC_CONTIGUOUS, 0, vg))) {
 		log_error("Creation of temporary pvmove LV failed");
--- LVM2/tools/toollib.c	2007/09/11 20:12:54	1.106
+++ LVM2/tools/toollib.c	2007/10/11 19:20:38	1.107
@@ -1347,7 +1347,7 @@
 		return NULL;
 	}
 
-	if (!(log_lv = lv_create_empty(vg->fid, log_name, NULL,
+	if (!(log_lv = lv_create_empty(log_name, NULL,
 				       VISIBLE_LV | LVM_READ | LVM_WRITE,
 				       alloc, 0, vg))) {
 		stack;



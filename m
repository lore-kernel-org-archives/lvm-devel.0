From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:38:57 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100628203857.20075.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:38:56

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Update check in vg_split_mdas to account for ignored mdas list.
	
	The check in vg_split_mdas will trigger an error if the 'from' vg
	list is empty.  However, this might be ok in some instances now
	that we have ignored mdas.  Relax this check so an error is triggered
	only in the case where there's truly no more mdas in the 'from'
	vg.
	
	One example of where this makes a difference is with vgreduce.
	If we try to vgreduce a PV with un-ignored mdas, this should trigger
	the balancing function to un-ignore mdas on another PV in the VG.
	However, we don't get to vg_write() before we fail because this
	list size check fails, and we see an error message indicating:
	"Cannot remove final metadata area ..."
	
	Another example is with vgsplit into a new VG, where the PVs
	being moved contain all ignored mdas.  We must move the mdas on
	fid->metadata_areas_ignored from 'vg_from' to 'vg_to'.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.361&r2=1.362

--- LVM2/lib/metadata/metadata.c	2010/06/28 20:38:39	1.361
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:38:56	1.362
@@ -1366,20 +1366,12 @@
 	return 1;
 }
 
-/*
- * Separate metadata areas after splitting a VG.
- * Also accepts orphan VG as destination (for vgreduce).
- */
-int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
-		  struct volume_group *vg_from, struct volume_group *vg_to)
+static int _move_mdas(struct volume_group *vg_from, struct volume_group *vg_to,
+		      struct dm_list *mdas_from, struct dm_list *mdas_to)
 {
 	struct metadata_area *mda, *mda2;
-	struct dm_list *mdas_from, *mdas_to;
 	int common_mda = 0;
 
-	mdas_from = &vg_from->fid->metadata_areas_in_use;
-	mdas_to = &vg_to->fid->metadata_areas_in_use;
-
 	dm_list_iterate_items_safe(mda, mda2, mdas_from) {
 		if (!mda->ops->mda_in_vg) {
 			common_mda = 1;
@@ -1393,9 +1385,35 @@
 				dm_list_move(mdas_to, &mda->list);
 		}
 	}
+	return common_mda;
+}
+
+/*
+ * Separate metadata areas after splitting a VG.
+ * Also accepts orphan VG as destination (for vgreduce).
+ */
+int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
+		  struct volume_group *vg_from, struct volume_group *vg_to)
+{
+	struct dm_list *mdas_from_in_use, *mdas_to_in_use;
+	struct dm_list *mdas_from_ignored, *mdas_to_ignored;
+	int common_mda = 0;
 
-	if (dm_list_empty(mdas_from) ||
-	    (!is_orphan_vg(vg_to->name) && dm_list_empty(mdas_to)))
+	mdas_from_in_use = &vg_from->fid->metadata_areas_in_use;
+	mdas_from_ignored = &vg_from->fid->metadata_areas_ignored;
+	mdas_to_in_use = &vg_to->fid->metadata_areas_in_use;
+	mdas_to_ignored = &vg_to->fid->metadata_areas_ignored;
+
+	common_mda = _move_mdas(vg_from, vg_to,
+				mdas_from_in_use, mdas_to_in_use);
+	common_mda = _move_mdas(vg_from, vg_to,
+				mdas_from_ignored, mdas_to_ignored);
+
+	if ((dm_list_empty(mdas_from_in_use) &&
+	     dm_list_empty(mdas_from_ignored)) ||
+	    ((!is_orphan_vg(vg_to->name) &&
+	      dm_list_empty(mdas_to_in_use) &&
+	      dm_list_empty(mdas_to_ignored))))
 		return common_mda;
 
 	return 1;



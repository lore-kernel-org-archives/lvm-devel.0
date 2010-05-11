From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 11 May 2010 16:36:52 -0500
Subject: [PATCH] LVM2: Disallow cluster attr change if mirror or snapshot is active
Message-ID: <1273613812.31265.3.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The new function 'lv_is_mirror' is not /really/ necessary, but I thought
it made sense given the similar snapshot functions.  However, this
probably means I need to find everywhere that the status of an LV is
checked for MIRRORED and replace it with the function.  I can go either
way...

 brassow

Disallow toggling the cluster attribute of a volume group if there
are active mirrors or snapshots.

We don't have the mechanisms in place to change the device-mapper
tables for those targets that have behavioral differences between
cluster and single machine instances.  Allowing users to change
the attribute but not changing the target's behavior can lead to
data corruption.

The following bugs are fixed/avoided by this patch:
235123 - vgchange -c [ny] do not change target types when necessary
289331 - RFE: switching from cluster domain to local domain needs to deactivate volume somehow
289541 - when changing from local to cluster, volumes can not appear to be deactivated


Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -691,6 +691,7 @@ int lv_remove_mirrors(struct cmd_context
 
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
+int lv_is_mirror(const struct logical_volume *lv);
 uint32_t lv_mirror_count(const struct logical_volume *lv);
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
                                     uint32_t region_size);
Index: LVM2/lib/metadata/metadata.c
===================================================================
--- LVM2.orig/lib/metadata/metadata.c
+++ LVM2/lib/metadata/metadata.c
@@ -1208,8 +1208,19 @@ int vg_set_alloc_policy(struct volume_gr
 int vg_set_clustered(struct volume_group *vg, int clustered)
 {
 	struct lv_list *lvl;
-	if (clustered) {
-		dm_list_iterate_items(lvl, &vg->lvs) {
+
+	/*
+	 * We do not currently support switching the cluster attribute
+	 * on active mirrors or snapshots.
+	 */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lv_is_mirror(lvl->lv) && lv_is_active(lvl->lv)) {
+			log_error("Mirror logical volumes must be inactive "
+				  "when changing the cluster attribute.");
+			return 0;
+		}
+
+		if (clustered) {
 			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
 				log_error("Volume group %s contains snapshots "
 					  "that are not yet supported.",
@@ -1217,6 +1228,13 @@ int vg_set_clustered(struct volume_group
 				return 0;
 			}
 		}
+
+		if ((lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) &&
+		    lv_is_active(lvl->lv)) {
+			log_error("Snapshot logical volumes must be inactive "
+				  "when changing the cluster attribute.");
+			return 0;
+		}
 	}
 
 	if (clustered)
Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -72,6 +72,14 @@ struct logical_volume *find_temporary_mi
 	return NULL;
 }
 
+int lv_is_mirror(const struct logical_volume *lv)
+{
+	if (lv->status & MIRRORED)
+		return 1;
+
+	return 0;
+}
+
 /*
  * Returns the number of mirrors of the LV
  */




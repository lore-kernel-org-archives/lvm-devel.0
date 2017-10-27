From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 27 Oct 2017 11:11:22 -0400
Subject: master - snapshot: relocate common code validation for snapshot origin
Message-ID: <201710271511.v9RFBMqH014721@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63c50ced89d14f90c3202167e1d07de3514dad60
Commit:        63c50ced89d14f90c3202167e1d07de3514dad60
Parent:        0c68c19c322e23242b21885d759ab5ec3bbe8e08
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 27 16:48:57 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 27 17:07:42 2017 +0200

snapshot: relocate common code validation for snapshot origin

Since both lvcreate and lvconvert needs to check for same
type of allowed origin for snapshot - move the code into
a single function.

This way we also fix several inconsitencies where snapshot
has been allowed by mistake either through lvcreate or
lvconvert path.
---
 lib/metadata/lv_manip.c          |   51 +------------------------------------
 lib/metadata/metadata-exported.h |    3 ++
 lib/metadata/snapshot_manip.c    |   44 ++++++++++++++++++++++++++++++++
 tools/lvconvert.c                |   33 ++++++++----------------
 4 files changed, 60 insertions(+), 71 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4cca5a1..01ba564 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7592,56 +7592,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 					  "Use --virtualsize.");
 				return NULL;
 			}
-			if (lv_is_cow(origin_lv)) {
-				log_error("Snapshots of snapshots are not supported.");
-				return NULL;
-			}
-			if (lv_is_locked(origin_lv)) {
-				log_error("Snapshots of locked devices are not supported.");
-				return NULL;
-			}
-			if (lv_is_merging_origin(origin_lv)) {
-				log_error("Snapshots of an origin that has a "
-					  "merging snapshot is not supported");
-				return NULL;
-			}
-
-			if (lv_is_cache_type(origin_lv) && !lv_is_cache(origin_lv)) {
-				log_error("Snapshots of cache type volume %s "
-					  "is not supported.", display_lvname(origin_lv));
-				return NULL;
-			}
 
-			if (lv_is_thin_type(origin_lv) && !lv_is_thin_volume(origin_lv)) {
-				log_error("Snapshots of thin pool %sdevices "
-					  "are not supported.",
-					  lv_is_thin_pool_data(origin_lv) ? "data " :
-					  lv_is_thin_pool_metadata(origin_lv) ?
-					  "metadata " : "");
-				return NULL;
-			}
-
-			if (lv_is_mirror_type(origin_lv)) {
-				if (!lv_is_mirror(origin_lv)) {
-					log_error("Snapshots of mirror subvolumes are not supported.");
-					return NULL;
-				}
-				log_warn("WARNING: Snapshots of mirrors can deadlock under rare device failures.");
-				log_warn("WARNING: Consider using the raid1 mirror type to avoid this.");
-				log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
-			}
-
-			if (lv_is_raid_type(origin_lv) && !lv_is_raid(origin_lv)) {
-				log_error("Snapshots of raid subvolumes are not supported.");
-				return NULL;
-			}
-
-			if (vg_is_clustered(vg) && lv_is_active(origin_lv) &&
-			    !lv_is_active_exclusive_locally(origin_lv)) {
-				log_error("%s must be active exclusively to"
-					  " create snapshot", origin_lv->name);
-				return NULL;
-			}
+			if (!validate_snapshot_origin(origin_lv))
+                                return_0;
 		}
 
 		if (!cow_has_min_chunks(vg, lp->extents, lp->chunk_size))
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 85e5838..71df955 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1074,6 +1074,9 @@ int vg_add_snapshot(struct logical_volume *origin, struct logical_volume *cow,
 
 int vg_remove_snapshot(struct logical_volume *cow);
 
+int validate_snapshot_origin(const struct logical_volume *origin_lv);
+
+
 int vg_check_status(const struct volume_group *vg, uint64_t status);
 
 int vg_check_pv_dev_block_sizes(const struct volume_group *vg);
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 57fbef9..8357ea0 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -386,3 +386,47 @@ int vg_remove_snapshot(struct logical_volume *cow)
 
 	return 1;
 }
+
+/* Check if given LV is usable as snapshot origin LV */
+int validate_snapshot_origin(const struct logical_volume *origin_lv)
+{
+	const char *err = NULL; /* For error string */
+
+	if (lv_is_cow(origin_lv))
+		err = "snapshots";
+	else if (lv_is_locked(origin_lv))
+		err = "locked volumes";
+	else if (lv_is_pvmove(origin_lv))
+		err = "pvmoved volumes";
+	else if (!lv_is_visible(origin_lv))
+		err = "hidden volumes";
+	else if (lv_is_merging_origin(origin_lv))
+		err = "an origin that has a merging snapshot";
+	else if (lv_is_cache_type(origin_lv) && !lv_is_cache(origin_lv))
+		err = "cache type volumes";
+	else if (lv_is_thin_type(origin_lv) && !lv_is_thin_volume(origin_lv))
+		err = "thin pool type volumes";
+	else if (lv_is_mirror_type(origin_lv)) {
+		if (!lv_is_mirror(origin_lv))
+			err = "mirror subvolumes";
+		else {
+			log_warn("WARNING: Snapshots of mirrors can deadlock under rare device failures.");
+			log_warn("WARNING: Consider using the raid1 mirror type to avoid this.");
+			log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
+		}
+	} else if (lv_is_raid_type(origin_lv) && !lv_is_raid(origin_lv))
+		err = "raid subvolumes";
+
+	if (err) {
+		log_error("Snapshots of %s are not supported.", err);
+		return 0;
+	}
+
+	if (vg_is_clustered(origin_lv->vg) && lv_is_active(origin_lv) &&
+	    !lv_is_active_exclusive_locally(origin_lv)) {
+		log_error("Snapshot origin must be active exclusively.");
+		return 0;
+	}
+
+	return 1;
+}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index aa61f73..76be5cb 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1909,13 +1909,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	uint32_t chunk_size;
 	int zero;
 
-	if (!(org = find_lv(lv->vg, origin_name))) {
-		log_error("Couldn't find origin volume %s in Volume group %s.",
-			  origin_name, lv->vg->name);
-		return 0;
-	}
-
-	if (org == lv) {
+	if (strcmp(lv->name, origin_name) == 0) {
 		log_error("Unable to use %s as both snapshot and origin.", snap_name);
 		return 0;
 	}
@@ -1925,34 +1919,29 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		log_error("Chunk size must be a power of 2 in the range 4K to 512K.");
 		return 0;
 	}
-	log_verbose("Setting chunk size to %s.", display_size(cmd, chunk_size));
 
 	if (!cow_has_min_chunks(lv->vg, lv->le_count, chunk_size))
 		return_0;
 
+	log_verbose("Setting chunk size to %s.", display_size(cmd, chunk_size));
+
+	if (!(org = find_lv(lv->vg, origin_name))) {
+		log_error("Couldn't find origin volume %s in Volume group %s.",
+			  origin_name, lv->vg->name);
+		return 0;
+	}
+
 	/*
 	 * check_lv_rules() checks cannot be done via command definition
 	 * rules because this LV is not processed by process_each_lv.
 	 */
-	if (lv_is_locked(org) || lv_is_pvmove(org)) {
-		log_error("Unable to use LV %s as snapshot origin: LV is %s.",
-			  display_lvname(lv), lv_is_locked(org) ? "locked" : "pvmove");
-		return 0;
-	}
 
 	/*
 	 * check_lv_types() checks cannot be done via command definition
 	 * LV_foo specification because this LV is not processed by process_each_lv.
 	 */
-	if ((lv_is_cache_type(org) && !lv_is_cache(org)) ||
-	    (lv_is_thin_type(org) && !lv_is_thin_volume(org)) ||
-	    (lv_is_mirror_type(org) && !lv_is_mirror(org)) ||
-	    (lv_is_raid_type(org) && !lv_is_raid(org)) ||
-	    lv_is_cow(org)) {
-		log_error("Unable to use LV %s as snapshot origin: invalid LV type.",
-			  display_lvname(lv));
-		return 0;
-	}
+	if (!validate_snapshot_origin(org))
+                return_0;
 
 	log_warn("WARNING: Converting logical volume %s to snapshot exception store.",
 		 snap_name);



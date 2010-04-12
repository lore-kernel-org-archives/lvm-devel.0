From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 12 Apr 2010 17:21:34 +0200
Subject: [PATCH 06/22] Replicator: check replicator segment
In-Reply-To: <cover.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
Message-ID: <0cb3beb1507972af2772ca20e168fb3df9ff6cc3.1271085009.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Check for possible problems within replicator structures.
Used also by vg_validate.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/merge.c             |    3 +
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/replicator_manip.c  |  152 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 156 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 66ff57b..9a34daf 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -137,6 +137,9 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			}
 		}
 
+		if (seg_is_replicator(seg) && !replicator_check_segment(seg))
+			inc_error_count;
+
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) == AREA_UNASSIGNED) {
 				log_error("LV %s: segment %u has unassigned "
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7b6c7fa..6d40365 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -767,6 +767,7 @@ struct logical_volume *replicator_dev_remove_slog(struct replicator_device *rdev
 int replicator_dev_add_rimage(struct replicator_device *rdev, struct logical_volume *lv);
 struct logical_volume *replicator_dev_remove_rimage(struct replicator_device *rdev);
 
+int replicator_check_segment(const struct lv_segment *replicator_seg);
 int lv_is_active_replicator_dev(const struct logical_volume *lv);
 int lv_is_replicator(const struct logical_volume *lv);
 int lv_is_replicator_dev(const struct logical_volume *lv);
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 02fd49c..7062a32 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -265,6 +265,158 @@ int lv_remove_replicator(struct logical_volume *lv)
 }
 #endif
 
+/*
+ * Check all replicator structures:
+ *  only non-clustered vg for replicator
+ *  only one segment in replicator LV
+ *  site has correct combination of operation_mode parameters
+ *  site and devices have correct index numbers
+ *  duplicate site names, site indexes, device names, device indexes
+ */
+int replicator_check_segment(const struct lv_segment *rseg)
+{
+	struct replicator_site *rsite, *rsiteb;
+	struct replicator_device *rdev, *rdevb;
+        struct logical_volume *lv = rseg->lv;
+	int r = 1;
+
+	if (vg_is_clustered(lv->vg)) {
+		log_error("Volume Group %s of replicator %s is clustered",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (dm_list_size(&lv->segments) != 1) {
+		log_error("Replicator %s segment size %d != 1",
+			  lv->name, dm_list_size(&lv->segments));
+		return 0;
+	}
+
+	dm_list_iterate_items(rsite, &lv->rsites) {
+		if (rsite->op_mode == DM_REPLICATOR_SYNC) {
+			if (rsite->fall_behind_timeout) {
+				log_error("Defined fall_behind_timeout="
+					  "%d for sync replicator %s/%s.",
+					  rsite->fall_behind_timeout, lv->name,
+					  rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_ios) {
+				log_error("Defined fall_behind_ios="
+					  "%d for sync replicator %s/%s.",
+					  rsite->fall_behind_ios, lv->name, rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_data) {
+				log_error("Defined fall_behind_data="
+					  "%" PRIu64 " for sync replicator %s/%s.",
+					  rsite->fall_behind_data, lv->name, rsite->name);
+				r = 0;
+			}
+		} else {
+			if (rsite->fall_behind_timeout && rsite->fall_behind_ios) {
+				log_error("Defined fall_behind_timeout and"
+					  " fall_behind_ios for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_timeout && rsite->fall_behind_data) {
+				log_error("Defined fall_behind_timeout and"
+					  " fall_behind_data for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_ios && rsite->fall_behind_data) {
+				log_error("Defined fall_behind_ios and"
+					  " fall_behind_data for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+			if (!rsite->fall_behind_ios && !rsite->fall_behind_data &&
+			    !rsite->fall_behind_timeout) {
+				log_error("fall_behind_timeout,"
+					  " fall_behind_ios and fall_behind_data are"
+					  " undefined for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+		}
+		dm_list_iterate_items(rsiteb, &lv->rsites) {
+			if (rsite == rsiteb)
+				break;
+			if (strcasecmp(rsite->name, rsiteb->name) == 0) {
+				log_error("Duplicate site name"
+					  " %s detected for replicator %s.",
+					  rsite->name, lv->name);
+				r = 0;
+			}
+			if ((rsite->vg_name && rsiteb->vg_name &&
+			     strcasecmp(rsite->vg_name, rsiteb->vg_name) == 0) ||
+			    (!rsite->vg_name && !rsiteb->vg_name)) {
+				log_error("Duplicate VG name"
+					  " %s detected for replicator %s.",
+					  (rsite->vg_name) ? rsite->vg_name : "<local>",
+					  lv->name);
+				r = 0;
+			}
+			if (rsite->site_index == rsiteb->site_index) {
+				log_error("Duplicate site index"
+					  " %d detected for replicator %s/%s.",
+					  rsite->site_index, lv->name,
+					  rsite->name);
+				r = 0;
+			}
+			if (rsite->site_index > rseg->rsite_index_highest) {
+				log_error("Site index %d > %d"
+					  " (too high) for replicator %s/%s.",
+					  rsite->site_index,
+					  rseg->rsite_index_highest,
+					  lv->name, rsite->name);
+				r = 0;
+			}
+		}
+
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			dm_list_iterate_items(rdevb, &rsite->rdevices) {
+				if (rdev == rdevb)
+					break;
+				if (rdev->slog && (rdev->slog == rdevb->slog)) {
+					log_error("Duplicate "
+						  "sync log %s detected for "
+						  "replicator %s.",
+						  rdev->slog->name, lv->name);
+					r = 0;
+				}
+				if (strcasecmp(rdev->name, rdevb->name) == 0) {
+					log_error("Duplicate "
+						  "device name %s detected "
+						  "for replicator %s.",
+						  rdev->name, lv->name);
+					r = 0;
+				}
+				if (rdev->device_index == rdevb->device_index) {
+					log_error("Duplicate "
+						  "device index %" PRId64
+						  " detected for replicator "
+						  "%s/%s.", rdev->device_index,
+						  lv->name, rsite->name);
+					r = 0;
+				}
+				if (rdev->device_index > rseg->rdevice_index_highest) {
+					log_error("Device index %" PRIu64 " > %"
+						  PRIu64 " (too high) for replicator %s/%s.",
+						  rdev->device_index,
+						  rseg->rdevice_index_highest,
+						  lv->name, rsite->name);
+					r = 0;
+				}
+			}
+		}
+	}
+
+	return r;
+}
+
 /**
  * Is this segment part of active replicator
  */
-- 
1.7.0.1



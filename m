From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:56:50 +0100
Subject: [PATCH 04/19] Replicator: validation of replicator segments
In-Reply-To: <cover.1265813098.git.zkabelac@redhat.com>
References: <cover.1265813098.git.zkabelac@redhat.com>
Message-ID: <a770e3c5a34b739ba6e175fcff8cbc02cdaf4e73.1265813098.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Validate segments with Replicator content

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |  157 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 157 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 28c7c47..f14647f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2082,6 +2082,160 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
 	}
 }
 
+/*
+ * Validate replicator structures:
+ * Check for:
+ *  non-clustered vg for replicator
+ *  only one segment in replicator LV
+ *  site has correct combination of operation_mode parameters
+ *  site and devices have correct index numbers
+ *  duplicate site names, site indexes, device names, device indexes
+ */
+static int _replicator_validate(const struct logical_volume *lv)
+{
+	struct replicator_site *rsite, *rsiteb;
+	struct replicator_device *rdev, *rdevb;
+	struct lv_segment *seg;
+	int r = 1;
+
+	if (vg_is_clustered(lv->vg)) {
+		log_error(INTERNAL_ERROR "Volume Group %s of replicator %s is clustered",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (dm_list_size(&lv->segments) != 1) {
+		log_error(INTERNAL_ERROR "Replicator %s segment size %d != 1",
+			  lv->name, dm_list_size(&lv->segments));
+		return 0;
+	}
+	seg = first_seg(lv);
+
+	dm_list_iterate_items(rsite, &lv->rsites) {
+		if (rsite->op_mode == DM_REPLICATOR_SYNC) {
+			if (rsite->fall_behind_timeout) {
+				log_error(INTERNAL_ERROR "Defined fall_behind_timeout="
+					  "%d for sync replicator %s/%s.",
+					  rsite->fall_behind_timeout, lv->name,
+					  rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_ios) {
+				log_error(INTERNAL_ERROR "Defined fall_behind_ios="
+					  "%d for sync replicator %s/%s.",
+					  rsite->fall_behind_ios, lv->name, rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_data) {
+				log_error(INTERNAL_ERROR "Defined fall_behind_data="
+					  "%" PRIu64 " for sync replicator %s/%s.",
+					  rsite->fall_behind_data, lv->name, rsite->name);
+				r = 0;
+			}
+		} else {
+			if (rsite->fall_behind_timeout && rsite->fall_behind_ios) {
+				log_error(INTERNAL_ERROR "Defined fall_behind_timeout and"
+					  " fall_behind_ios for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_timeout && rsite->fall_behind_data) {
+				log_error(INTERNAL_ERROR "Defined fall_behind_timeout and"
+					  " fall_behind_data for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_ios && rsite->fall_behind_data) {
+				log_error(INTERNAL_ERROR "Defined fall_behind_ios and"
+					  " fall_behind_data for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+			if (!rsite->fall_behind_ios && !rsite->fall_behind_data &&
+			    !rsite->fall_behind_timeout) {
+				log_error(INTERNAL_ERROR "fall_behind_timeout,"
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
+				log_error(INTERNAL_ERROR "Duplicate site name"
+					  " %s detected for replicator %s.",
+					  rsite->name, lv->name);
+				r = 0;
+			}
+			if ((rsite->vg_name && rsiteb->vg_name &&
+			     strcasecmp(rsite->vg_name, rsiteb->vg_name) == 0) ||
+			    (!rsite->vg_name && !rsiteb->vg_name)) {
+				log_error(INTERNAL_ERROR "Duplicate VG name"
+					  " %s detected for replicator %s.",
+					  (rsite->vg_name) ? rsite->vg_name : "<local>",
+					  lv->name);
+				r = 0;
+			}
+			if (rsite->site_index == rsiteb->site_index) {
+				log_error(INTERNAL_ERROR "Duplicate site index"
+					  " %d detected for replicator %s/%s.",
+					  rsite->site_index, lv->name,
+					  rsite->name);
+				r = 0;
+			}
+			if (rsite->site_index > seg->rsite_index_highest) {
+				log_error(INTERNAL_ERROR "Site index %d > %d"
+					  " (too high) for replicator %s/%s.",
+					  rsite->site_index,
+					  seg->rsite_index_highest,
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
+					log_error(INTERNAL_ERROR "Duplicate "
+						  "sync log %s detected for "
+						  "replicator %s.",
+						  rdev->slog->name, lv->name);
+					r = 0;
+				}
+				if (strcasecmp(rdev->name, rdevb->name) == 0) {
+					log_error(INTERNAL_ERROR "Duplicate "
+						  "device name %s detected "
+						  "for replicator %s.",
+						  rdev->name, lv->name);
+					r = 0;
+				}
+				if (rdev->device_index == rdevb->device_index) {
+					log_error(INTERNAL_ERROR "Duplicate "
+						  "device index %" PRId64
+						  " detected for replicator "
+						  "%s/%s.", rdev->device_index,
+						  lv->name, rsite->name);
+					r = 0;
+				}
+				if (rdev->device_index > seg->rdevice_index_highest) {
+					log_error(INTERNAL_ERROR "Device index %" PRIu64 " > %"
+						  PRIu64 " (too high) for replicator %s/%s.",
+						  rdev->device_index,
+						  seg->rdevice_index_highest,
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
 int vg_validate(struct volume_group *vg)
 {
 	struct pv_list *pvl, *pvl2;
@@ -2182,6 +2336,9 @@ int vg_validate(struct volume_group *vg)
 				r = 0;
 			}
 		}
+
+		if (lv_is_replicator(lvl->lv) && !_replicator_validate(lvl->lv))
+			r = 0;
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-- 
1.6.6.1



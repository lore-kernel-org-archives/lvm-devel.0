From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:42:07 +0100
Subject: [PATCH 03/18] Replicator: validation of replicator segments
In-Reply-To: <cover.1263389894.git.zkabelac@redhat.com>
References: <cover.1263389894.git.zkabelac@redhat.com>
Message-ID: <6bf250cdb16a6a13d68785a1272d619a90338d7b.1263389894.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Validate segments with Replicator content

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |   68 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 68 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4df187f..c1031c3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2088,6 +2088,71 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
 	}
 }
 
+/*
+ * Check for duplicate
+ *  site name
+ *  site index
+ *  device name
+ *  device index
+ */
+static int _replicator_validate(const struct logical_volume *lv)
+{
+	struct replicator_site *rsite, *rsiteb;
+	struct replicator_device *rdev, *rdevb;
+	int r = 1;
+
+	dm_list_iterate_items(rsite, &lv->rsites) {
+		dm_list_iterate_items(rsiteb, &lv->rsites) {
+			if (rsite == rsiteb)
+				break;
+			if (strcasecmp(rsite->name, rsiteb->name) == 0) {
+				log_error("Internal error: Duplicate site name"
+					  " %s detected for replicator %s.",
+					  rsite->name, lv->name);
+				r = 0;
+			}
+			if (rsite->site_index == rsiteb->site_index) {
+				log_error("Internal error: Duplicate site index"
+					  " %d detected for replicator %s/%s.",
+					  rsite->site_index, lv->name,
+					  rsite->name);
+				r = 0;
+			}
+		}
+
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			dm_list_iterate_items(rdevb, &rsite->rdevices) {
+				if (rdev == rdevb)
+					break;
+				if (rdev->slog && (rdev->slog == rdevb->slog)) {
+					log_error("Internal error: Duplicate "
+						  "sync log %s detected for "
+						  "replicator %s.",
+						  rdev->slog->name, lv->name);
+					r = 0;
+				}
+				if (strcasecmp(rdev->name, rdevb->name) == 0) {
+					log_error("Internal error: Duplicate "
+						  "device name %s detected "
+						  "for replicator %s.",
+						  rdev->name, lv->name);
+					r = 0;
+				}
+				if (rdev->device_index == rdevb->device_index) {
+					log_error("Internal error: Duplicate "
+						  "device index %" PRId64
+						  " detected for replicator "
+						  "%s/%s.", rdev->device_index,
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
@@ -2188,6 +2253,9 @@ int vg_validate(struct volume_group *vg)
 				r = 0;
 			}
 		}
+
+		if (lv_is_replicator(lvl->lv) && !_replicator_validate(lvl->lv))
+			r = 0;
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-- 
1.6.6



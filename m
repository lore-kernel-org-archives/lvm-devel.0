From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Jul 2014 14:00:14 +0000 (UTC)
Subject: master - lv_manip: add get_lv_type_name/lv_is_linear and lv_is_striped helper fns
Message-ID: <20140704140014.5E3F260F98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b58647848dca8f0e7bab04f4c6491dab28173ff
Commit:        6b58647848dca8f0e7bab04f4c6491dab28173ff
Parent:        a4734354ceedffc72314feb5323e73e63d5e8ec8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 1 10:37:01 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 4 15:40:17 2014 +0200

lv_manip: add get_lv_type_name/lv_is_linear and lv_is_striped helper fns

The get_lv_type_name helps with translating volume type
to human readable form (can be used in reports or
various messages if needed).

The lv_is_linear and lv_is_striped complete the set of
lv_is_* functions that identify exact volume types.
---
 lib/metadata/lv_manip.c          |  147 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    8 ++
 2 files changed, 155 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 306a34b..fc98b2a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -82,6 +82,153 @@ struct pv_and_int {
 	struct physical_volume *pv;
 	int *i;
 };
+
+typedef enum {
+	LV_TYPE_UNKNOWN,
+	LV_TYPE_PVMOVE,
+	LV_TYPE_ORIGIN,
+	LV_TYPE_EXTERNAL_ORIGIN,
+	LV_TYPE_SNAPSHOT,
+	LV_TYPE_THIN,
+	LV_TYPE_THIN_SNAPSHOT,
+	LV_TYPE_THIN_POOL,
+	LV_TYPE_THIN_POOL_DATA,
+	LV_TYPE_THIN_POOL_METADATA,
+	LV_TYPE_THIN_POOL_METADATA_SPARE,
+	LV_TYPE_CACHE,
+	LV_TYPE_CACHE_POOL,
+	LV_TYPE_CACHE_POOL_DATA,
+	LV_TYPE_CACHE_POOL_METADATA,
+	LV_TYPE_CACHE_POOL_METADATA_SPARE,
+	LV_TYPE_VIRTUAL,
+	LV_TYPE_RAID,
+	LV_TYPE_RAID_IMAGE,
+	LV_TYPE_RAID_METADATA,
+	LV_TYPE_MIRROR,
+	LV_TYPE_MIRROR_IMAGE,
+	LV_TYPE_MIRROR_LOG,
+	LV_TYPE_LINEAR,
+	LV_TYPE_STRIPED
+} lv_type_t;
+
+static const char *_lv_type_names[] = {
+	[LV_TYPE_UNKNOWN] =                     "unknown",
+	[LV_TYPE_PVMOVE] =                      "pvmove",
+	[LV_TYPE_ORIGIN] =                      "origin",
+	[LV_TYPE_EXTERNAL_ORIGIN] =             "external-origin",
+	[LV_TYPE_SNAPSHOT] =                    "snapshot",
+	[LV_TYPE_THIN] =                        "thin",
+	[LV_TYPE_THIN_SNAPSHOT] =               "thin-snapshot",
+	[LV_TYPE_THIN_POOL] =                   "thin-pool",
+	[LV_TYPE_THIN_POOL_DATA] =              "thin-pool-data",
+	[LV_TYPE_THIN_POOL_METADATA] =          "thin-pool-metadata",
+	[LV_TYPE_THIN_POOL_METADATA_SPARE] =    "thin-pool-metadata-spare",
+	[LV_TYPE_CACHE] =                       "cache",
+	[LV_TYPE_CACHE_POOL] =                  "cache-pool",
+	[LV_TYPE_CACHE_POOL_DATA] =             "cache-pool-data",
+	[LV_TYPE_CACHE_POOL_METADATA] =         "cache-pool-metadata",
+	[LV_TYPE_CACHE_POOL_METADATA_SPARE] =   "cache-pool-metadata-spare",
+	[LV_TYPE_VIRTUAL] =                     "virtual",
+	[LV_TYPE_RAID] =                        "raid",
+	[LV_TYPE_RAID_IMAGE] =                  "raid-image",
+	[LV_TYPE_RAID_METADATA] =               "raid-metadata",
+	[LV_TYPE_MIRROR] =                      "mirror",
+	[LV_TYPE_MIRROR_IMAGE] =                "mirror-image",
+	[LV_TYPE_MIRROR_LOG] =                  "mirror-log",
+	[LV_TYPE_LINEAR] =                      "linear",
+	[LV_TYPE_STRIPED] =                     "striped"
+};
+
+static lv_type_t _get_lv_type(const struct logical_volume *lv)
+{
+	lv_type_t type = LV_TYPE_UNKNOWN;
+	struct lv_segment *seg;
+
+	if (lv->status & PVMOVE)
+		type = LV_TYPE_PVMOVE;
+	else if (lv_is_origin(lv))
+		type = LV_TYPE_ORIGIN;
+	else if (lv_is_external_origin(lv))
+		type = LV_TYPE_EXTERNAL_ORIGIN;
+	else if (lv_is_cow(lv))
+		type = LV_TYPE_SNAPSHOT;
+	else if (lv_is_thin_volume(lv))
+		type = first_seg(lv)->origin ? LV_TYPE_THIN_SNAPSHOT : LV_TYPE_THIN;
+	else if (lv_is_thin_pool(lv))
+		type = LV_TYPE_THIN_POOL;
+	else if (lv_is_thin_pool_data(lv))
+		type = LV_TYPE_THIN_POOL_DATA;
+	else if (lv_is_thin_pool_metadata(lv))
+		type = LV_TYPE_THIN_POOL_METADATA;
+	else if (lv_is_pool_metadata_spare(lv))
+		type = LV_TYPE_THIN_POOL_METADATA_SPARE;
+	else if (lv_is_cache(lv))
+		type = LV_TYPE_CACHE;
+	else if (lv_is_cache_pool(lv))
+		type = LV_TYPE_CACHE_POOL;
+	else if (lv_is_cache_pool_data(lv))
+		type = LV_TYPE_CACHE_POOL_DATA;
+	else if (lv_is_cache_pool_metadata(lv))
+		type = LV_TYPE_CACHE_POOL_METADATA;
+	else if (lv_is_pool_metadata_spare(lv))
+		type = LV_TYPE_CACHE_POOL_METADATA_SPARE;
+	else if (lv_is_virtual(lv))
+		type = LV_TYPE_VIRTUAL;
+	else if (lv_is_raid(lv))
+		type = LV_TYPE_RAID;
+	else if (lv_is_raid_image(lv))
+		type = LV_TYPE_RAID_IMAGE;
+	else if (lv_is_raid_metadata(lv))
+		type = LV_TYPE_RAID_METADATA;
+	else if (lv_is_mirrored(lv))
+		type = LV_TYPE_MIRROR;
+	else if (lv_is_mirror_image(lv))
+		type = LV_TYPE_MIRROR_IMAGE;
+	else if (lv_is_mirror_log(lv))
+		type = LV_TYPE_MIRROR_LOG;
+
+	/* none of the above, check linear... */
+	if (type == LV_TYPE_UNKNOWN) {
+		type = LV_TYPE_LINEAR;
+		dm_list_iterate_items(seg, &lv->segments) {
+			if (!seg_is_linear(seg)) {
+				type = LV_TYPE_UNKNOWN;
+				break;
+			}
+		}
+	}
+
+	/* ...if not even linear, check striped... */
+	if (type == LV_TYPE_UNKNOWN) {
+		type = LV_TYPE_STRIPED;
+		dm_list_iterate_items(seg, &lv->segments) {
+			if (!seg_is_striped(seg)) {
+				type = LV_TYPE_UNKNOWN;
+				break;
+			}
+		}
+	}
+
+	return type;
+}
+
+const char *lv_type_name(const struct logical_volume *lv) {
+	lv_type_t type = _get_lv_type(lv);
+	return _lv_type_names[type];
+}
+
+int lv_is_linear(const struct logical_volume *lv)
+{
+	lv_type_t type = _get_lv_type(lv);
+	return type == LV_TYPE_LINEAR;
+}
+
+int lv_is_striped(const struct logical_volume *lv)
+{
+	lv_type_t type = _get_lv_type(lv);
+	return type == LV_TYPE_STRIPED;
+}
+
 static int _lv_is_on_pv(struct logical_volume *lv, void *data)
 {
 	int *is_on_pv = ((struct pv_and_int *)data)->i;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 85ea944..bfb4651 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -899,6 +899,14 @@ int get_pv_list_for_lv(struct dm_pool *mem,
 struct lv_segment *first_seg(const struct logical_volume *lv);
 struct lv_segment *last_seg(const struct logical_volume *lv);
 
+/* Human-readable LV type name. */
+const char *lv_type_name(const struct logical_volume *lv);
+
+/*
+ * Useful function to determine linear and striped volumes.
+ */
+int lv_is_linear(const struct logical_volume *lv);
+int lv_is_striped(const struct logical_volume *lv);
 
 /*
 * Useful functions for managing snapshots.



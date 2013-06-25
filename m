From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 25 Jun 2013 13:56:01 +0200
Subject: [PATCH 1/6] thin: add spare lv support
In-Reply-To: <cover.1372161214.git.zkabelac@redhat.com>
References: <cover.1372161214.git.zkabelac@redhat.com>
Message-ID: <f29a2fd3b417dbf408224b7e46610b46e0329ffd.1372161214.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add support for SPARE volume.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/flags.c          |  1 +
 lib/format_text/import_vsn1.c    | 10 ++++++++++
 lib/metadata/metadata-exported.h |  3 +++
 lib/metadata/metadata.c          | 24 ++++++++++++++++--------
 lib/metadata/snapshot_manip.c    |  3 ++-
 lib/metadata/vg.h                |  2 ++
 6 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 28a7dc4..6d15d20 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -59,6 +59,7 @@ static const struct flag _lv_flags[] = {
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
+	{SPARE_LV, "SPARE", STATUS_FLAG},
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},
 	{RAID_IMAGE, NULL, 0},
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 852f2c5..d9f05c9 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -605,6 +605,16 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	if (timestamp && !lv_set_creation(lv, hostname, timestamp))
 		return_0;
 
+	if (lv_is_spare(lv)) {
+		if (lv->vg->spare) {
+			/* CHECKME: maybe just ignore all others ? */
+			log_error("VG with multiple spare LVs is not supported.");
+			return 0;
+		}
+		log_debug_metadata("Logical volume %s is spare.", lv->name);
+		lv->vg->spare = lv;
+	}
+
 	return 1;
 }
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 10aea9e..453b98b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -92,6 +92,8 @@
 
 #define LV_WRITEMOSTLY		UINT64_C(0x0000010000000000)	/* LV (RAID1) */
 
+#define SPARE_LV		UINT64_C(0x0000020000000000)	/* LV internal use */
+
 #define LVM_READ		UINT64_C(0x00000100)	/* LV, VG */
 #define LVM_WRITE		UINT64_C(0x00000200)	/* LV, VG */
 
@@ -153,6 +155,7 @@
 #define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
 
 #define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
+#define lv_is_spare(lv)		(((lv)->status & SPARE_LV) ? 1 : 0)
 
 /* Ordered list - see lv_manip.c */
 typedef enum {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8a98aa6..ecedbdc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2290,9 +2290,10 @@ int vg_validate(struct volume_group *vg)
 	struct str_list *sl;
 	char uuid[64] __attribute__((aligned(8)));
 	int r = 1;
-	uint32_t hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
-	uint32_t pv_count = 0;
-	uint32_t num_snapshots = 0;
+	unsigned hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
+	unsigned pv_count = 0;
+	unsigned num_snapshots = 0;
+	unsigned spare_count = 0;
 	struct validate_hash vhash = { NULL };
 
 	if (vg->alloc == ALLOC_CLING_BY_TAGS) {
@@ -2404,6 +2405,12 @@ int vg_validate(struct volume_group *vg)
 				r = 0;
 			}
 
+		if (lv_is_spare(lvl->lv) && ++spare_count > 1) {
+			log_error(INTERNAL_ERROR "LV %s is %d. spare (allowed is one).",
+				  lvl->lv->name, spare_count);
+			r = 0;
+		}
+
 		if (lvl->lv->status & VISIBLE_LV)
 			continue;
 
@@ -2429,11 +2436,12 @@ int vg_validate(struct volume_group *vg)
 	/*
 	 * all volumes = visible LVs + snapshot_cows + invisible LVs
 	 */
-	if (lv_count != lv_visible_count + num_snapshots + hidden_lv_count) {
-		log_error(INTERNAL_ERROR "#internal LVs (%u) != #LVs (%"
-			  PRIu32 ") + #snapshots (%" PRIu32 ") + #internal LVs (%u) in VG %s",
-			  lv_count, lv_visible_count,
-			  num_snapshots, hidden_lv_count, vg->name);
+	if (lv_count != lv_visible_count + num_snapshots + hidden_lv_count + spare_count) {
+		log_error(INTERNAL_ERROR "#LVs (%u) != #visible LVs (%u) "
+			  "+ #snapshots (%u) + #internal LVs (%u) "
+			  "+ #spare LV (%u) in VG %s",
+			  lv_count, lv_visible_count, num_snapshots,
+			  hidden_lv_count, spare_count, vg->name);
 		r = 0;
 	}
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index e0d2f5b..6da592e 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -75,7 +75,8 @@ int lv_is_cow_covering_origin(const struct logical_volume *lv)
 
 int lv_is_visible(const struct logical_volume *lv)
 {
-	if (lv->status & SNAPSHOT)
+	/* spare LV is implicitely invisible */
+	if (lv->status & (SNAPSHOT | SPARE_LV))
 		return 0;
 
 	if (lv_is_cow(lv)) {
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 0dc3ba7..dc5bb12 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -20,6 +20,7 @@ struct dm_pool;
 struct format_instance;
 struct dm_list;
 struct id;
+struct logical_volume;
 
 typedef enum {
 	ALLOC_INVALID,
@@ -120,6 +121,7 @@ struct volume_group {
 	uint32_t mda_copies; /* target number of mdas for this VG */
 
 	struct dm_hash_table *hostnames; /* map of creation hostnames */
+	struct logical_volume *spare; /* pointer for spare LV in this VG */
 };
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
-- 
1.8.2.1



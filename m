From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:31 +0000 (GMT)
Subject: dev-next - raid: move non dm functions from DEVMAPPER ifdef
Message-ID: <20210322153931.372933854808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=79d8d06217b6e0ac2ef8d0303ce84f748faebb9b
Commit:        79d8d06217b6e0ac2ef8d0303ce84f748faebb9b
Parent:        cc140f68a505aad117a6e8222f65a5ea13139083
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 19 11:02:21 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 19 23:20:23 2021 +0100

raid: move non dm functions from DEVMAPPER ifdef

When lvm is compiled without device-mapper - this functions
do not need this kernel support so move them from ifdef DEVMAPPER
sections.
---
 lib/activate/activate.c |  36 ++++++++-------
 lib/raid/raid.c         | 114 ++++++++++++++++++++++++------------------------
 2 files changed, 77 insertions(+), 73 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8151293c3..71db98191 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -178,6 +178,22 @@ int lv_passes_auto_activation_filter(struct cmd_context *cmd, struct logical_vol
 	return _lv_passes_volumes_filter(cmd, lv, cn, activation_auto_activation_volume_list_CFG);
 }
 
+static int _passes_readonly_filter(struct cmd_context *cmd,
+				   const struct logical_volume *lv)
+{
+	const struct dm_config_node *cn;
+
+	if (!(cn = find_config_tree_array(cmd, activation_read_only_volume_list_CFG, NULL)))
+		return 0;
+
+	return _lv_passes_volumes_filter(cmd, lv, cn, activation_read_only_volume_list_CFG);
+}
+
+int lv_passes_readonly_filter(const struct logical_volume *lv)
+{
+	return _passes_readonly_filter(lv->vg->cmd, lv);
+}
+
 #ifndef DEVMAPPER_SUPPORT
 void set_activation(int act, int silent)
 {
@@ -275,6 +291,10 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 {
 	return 0;
 }
+int lv_raid_status(const struct logical_volume *lv, struct lv_status_raid **status)
+{
+	return 0;
+}
 int lv_writecache_message(const struct logical_volume *lv, const char *msg)
 {
 	return 0;
@@ -456,22 +476,6 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 	return _lv_passes_volumes_filter(cmd, lv, cn, activation_volume_list_CFG);
 }
 
-static int _passes_readonly_filter(struct cmd_context *cmd,
-				   const struct logical_volume *lv)
-{
-	const struct dm_config_node *cn;
-
-	if (!(cn = find_config_tree_array(cmd, activation_read_only_volume_list_CFG, NULL)))
-		return 0;
-
-	return _lv_passes_volumes_filter(cmd, lv, cn, activation_read_only_volume_list_CFG);
-}
-
-int lv_passes_readonly_filter(const struct logical_volume *lv)
-{
-	return _passes_readonly_filter(lv->vg->cmd, lv);
-}
-
 int library_version(char *version, size_t size)
 {
 	if (!activation())
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 4bb21d758..941ba8dc8 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -247,6 +247,63 @@ static void _raid_destroy(struct segment_type *segtype)
 	free(segtype);
 }
 
+/* Check availability of raid10 taking data copies into consideration. */
+static bool _raid10_is_available(const struct logical_volume *lv)
+{
+	uint32_t i, rebuilds_per_group = 0, s;
+	const uint32_t copies = 2; /* FIXME: we only support 2-way mirrors (i.e. 2 data copies) in RAID10 for now. */
+	struct lv_segment *seg = first_seg(lv); /* We only have one segment in RaidLVs for now. */
+
+	for (i = 0; i < seg->area_count * copies; ++i) {
+		s = i % seg->area_count;
+
+		if (!(i % copies))
+			rebuilds_per_group = 0;
+
+		if (seg_type(seg, s) == AREA_LV &&
+		    (lv_is_partial(seg_lv(seg, s)) ||
+		     lv_is_virtual(seg_lv(seg, s))))
+			rebuilds_per_group++;
+
+		if (rebuilds_per_group >= copies)
+			return false;
+	}
+
+	return true;
+}
+
+/*
+ * Return true in case RaidLV with specific RAID level is available.
+ *
+ * - raid0: all legs have to be live
+ * - raid1 : minimum of 1 leg live
+ * - raid4/5: maximum of 1 leg unavailable
+ * - raid6:  maximum of 2 legs unavailable
+ * - raid10: minimum of 1 leg per mirror group available
+ *
+ */
+bool raid_is_available(const struct logical_volume *lv)
+{
+	uint32_t s, missing_legs = 0;
+	struct lv_segment *seg = first_seg(lv); /* We only have one segment in RaidLVs for now. */
+
+	/* Be cautious about bogus calls. */
+	if (!seg || !seg_is_raid(seg))
+		return false;
+
+	if (seg_is_any_raid10(seg))
+		return _raid10_is_available(lv);
+
+	/* Count missing RAID legs */
+	for (s = 0; s < seg->area_count; ++s)
+		if (seg_type(seg, s) == AREA_LV &&
+		    lv_is_partial(seg_lv(seg, s)))
+			missing_legs++;
+
+	/* Degradation: segtype raid1 may miss legs-1, raid0/4/5/6 may loose parity devices. */
+	return missing_legs <= (seg_is_raid1(seg) ? seg->area_count - 1 : seg->segtype->parity_devs);
+}
+
 #ifdef DEVMAPPER_SUPPORT
 static int _raid_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg __attribute__((unused)),
@@ -468,63 +525,6 @@ static int _check_feature(const struct raid_feature *feature, uint32_t maj, uint
 	       (maj == feature->maj && min == feature->min && patchlevel >= feature->patchlevel);
 }
 
-/* Check availability of raid10 taking data copies into consideration. */
-static bool _raid10_is_available(const struct logical_volume *lv)
-{
-	uint32_t i, rebuilds_per_group = 0, s;
-	const uint32_t copies = 2; /* FIXME: we only support 2-way mirrors (i.e. 2 data copies) in RAID10 for now. */
-	struct lv_segment *seg = first_seg(lv); /* We only have one segment in RaidLVs for now. */
-
-	for (i = 0; i < seg->area_count * copies; ++i) {
-		s = i % seg->area_count;
-
-		if (!(i % copies))
-			rebuilds_per_group = 0;
-
-		if (seg_type(seg, s) == AREA_LV &&
-		    (lv_is_partial(seg_lv(seg, s)) ||
-		     lv_is_virtual(seg_lv(seg, s))))
-			rebuilds_per_group++;
-
-		if (rebuilds_per_group >= copies)
-			return false;
-	}
-
-	return true;
-}
-
-/*
- * Return true in case RaidLV with specific RAID level is available.
- *
- * - raid0: all legs have to be live
- * - raid1 : minimum of 1 leg live
- * - raid4/5: maximum of 1 leg unavailable
- * - raid6:  maximum of 2 legs unavailable
- * - raid10: minimum of 1 leg per mirror group available
- *
- */
-bool raid_is_available(const struct logical_volume *lv)
-{
-	uint32_t s, missing_legs = 0;
-	struct lv_segment *seg = first_seg(lv); /* We only have one segment in RaidLVs for now. */
-
-	/* Be cautious about bogus calls. */
-	if (!seg || !seg_is_raid(seg))
-		return false;
-
-	if (seg_is_any_raid10(seg))
-		return _raid10_is_available(lv);
-
-	/* Count missing RAID legs */
-	for (s = 0; s < seg->area_count; ++s)
-		if (seg_type(seg, s) == AREA_LV &&
-		    lv_is_partial(seg_lv(seg, s)))
-			missing_legs++;
-
-	/* Degradation: segtype raid1 may miss legs-1, raid0/4/5/6 may loose parity devices. */
-	return missing_legs <= (seg_is_raid1(seg) ? seg->area_count - 1 : seg->segtype->parity_devs);
-}
-
 static int _raid_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg __attribute__((unused)),
 				unsigned *attributes)



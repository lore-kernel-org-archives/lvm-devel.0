From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 27 Jul 2016 21:10:58 +0000 (UTC)
Subject: master - vg_validate: fix seg->extents_copied check introduced with commit 8f62b7bfe5 and add comment for the member to 'struct lv_segment'
Message-ID: <20160727211058.2E0FF61128@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df02917d7eef511f16edb195198f5f85583b44f0
Commit:        df02917d7eef511f16edb195198f5f85583b44f0
Parent:        ea90a3d622319fd15a3e85d772b25cd352a3544b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jul 27 23:09:54 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jul 27 23:09:54 2016 +0200

vg_validate: fix seg->extents_copied check introduced with              commit 8f62b7bfe5 and add comment for the member              to 'struct lv_segment'

---
 lib/metadata/merge.c             |    5 +++--
 lib/metadata/metadata-exported.h |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 8e7d107..681ec72 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -192,8 +192,6 @@ static void _check_non_raid_seg_members(struct lv_segment *seg, int *error_count
 		raid_seg_error("non-zero cow LV");
 	if (!dm_list_empty(&seg->origin_list)) /* snap */
 		raid_seg_error("non-zero origin_list");
-	if (seg->extents_copied)
-		raid_seg_error("non-zero extents_copied");
 	if (seg->log_lv)
 		raid_seg_error("non-zero log LV");
 	if (seg->segtype_private)
@@ -256,6 +254,9 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 	if (!seg->areas)
 		raid_seg_error("zero areas");
 
+	if (seg->extents_copied > seg->area_len)
+		raid_seg_error_val("extents_copied too large", seg->extents_copied);
+
 	/* Default still 8, change! */
 	if (seg->area_count > DEFAULT_RAID_MAX_IMAGES) {
 		log_error("LV %s invalid: maximum supported areas %u (is %u) for %s segment",
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ff879bb..a8cbfa2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -463,7 +463,7 @@ struct lv_segment {
 	struct logical_volume *cow;
 	struct dm_list origin_list;
 	uint32_t region_size;	/* For mirrors, replicators - in sectors */
-	uint32_t extents_copied;
+	uint32_t extents_copied;/* Number of extents synced for raids/mirrors */
 	struct logical_volume *log_lv;
 	struct lv_segment *pvmove_source_seg;
 	void *segtype_private;



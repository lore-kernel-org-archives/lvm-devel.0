From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 18 Jan 2016 22:06:28 +0000 (UTC)
Subject: master - report: Fix seg_pe_ranges LV sizes.
Message-ID: <20160118220628.0B03160A52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3f484f812bfb89063fbc25e378f34cacd50bf7d
Commit:        a3f484f812bfb89063fbc25e378f34cacd50bf7d
Parent:        6d7dc87cb356162f912b13c8a0cd198037c0226b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 18 22:04:43 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 18 22:04:43 2016 +0000

report: Fix seg_pe_ranges LV sizes.

When reporting on LVs, take the end of the range from the size of the
underlying (hidden) LV rather than the logical size of the current
segment (that PVs use).
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0499469..5a16d16 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.141 - 
 ====================================
+  Change LV sizes in seg_pe_ranges report field to match underlying devices.
   Add kernel_cache_settings report field for cache LV settings used in kernel.
 
 Version 2.02.140 - 16th January 2016
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 49c195f..6d52577 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -36,6 +36,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 	unsigned int s;
 	const char *name = NULL;
 	uint32_t extent = 0;
+	uint32_t seg_len = 0;
 	char extent_str[32];
 	struct logical_volume *lv;
 	int visible = 1;
@@ -52,6 +53,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 		switch (metadata_areas_only ? seg_metatype(seg, s) : seg_type(seg, s)) {
 		case AREA_LV:
 			lv = metadata_areas_only ? seg_metalv(seg, s) : seg_lv(seg, s);
+			seg_len = metadata_areas_only ? seg_metalv(seg, s)->le_count - 1 : seg_lv(seg, s)->le_count;
 			visible = lv_is_visible(lv);
 			name = lv->name;
 			extent = metadata_areas_only ? seg_le(seg, s) : 0;
@@ -62,10 +64,12 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 				continue;
 			name = dev_name(seg_dev(seg, s));
 			extent = seg_pe(seg, s);
+			seg_len = seg->area_len;
 			break;
 		case AREA_UNASSIGNED:
 			name = "unassigned";
 			extent = 0;
+			seg_len = 0;
 			break;
 		default:
 			log_error(INTERNAL_ERROR "Unknown area segtype.");
@@ -101,7 +105,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 
 		if (range_format) {
 			if (dm_snprintf(extent_str, sizeof(extent_str),
-					FMTu32, metadata_areas_only ? extent + seg_metalv(seg, s)->le_count - 1 : extent + seg->area_len - 1) < 0) {
+					FMTu32, extent + seg_len - 1) < 0) {
 				log_error("Extent number dm_snprintf failed");
 				return NULL;
 			}



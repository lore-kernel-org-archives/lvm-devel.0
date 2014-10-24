From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:07 +0000 (UTC)
Subject: master - tools: refactor reporter code
Message-ID: <20141024144007.A8F4E60E3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bdf48b489660d1e99631fcb950c2094a9d158c2
Commit:        5bdf48b489660d1e99631fcb950c2094a9d158c2
Parent:        482e572e5de327ce3b8786215cf33e6d6223c543
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 22 14:30:33 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

tools: refactor reporter code

Use new libdm macro DM_LIST_HEAD_INIT().
Embeded 'free' segment type (so it's not needed in the list)
Drop assignments of 0,NULL since they are defaults.
---
 lib/report/report.c |   10 +++++-----
 tools/reporter.c    |   46 ++++++++++++++++++----------------------------
 2 files changed, 23 insertions(+), 33 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 445f603..ebf3b3f 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1696,17 +1696,17 @@ static int _lvskipactivation_disp(struct dm_report *rh, struct dm_pool *mem,
 
 /* necessary for displaying something for PVs not belonging to VG */
 static struct format_instance _dummy_fid = {
-	.metadata_areas_in_use = { &(_dummy_fid.metadata_areas_in_use), &(_dummy_fid.metadata_areas_in_use) },
-	.metadata_areas_ignored = { &(_dummy_fid.metadata_areas_ignored), &(_dummy_fid.metadata_areas_ignored) },
+	.metadata_areas_in_use = DM_LIST_HEAD_INIT(_dummy_fid.metadata_areas_in_use),
+	.metadata_areas_ignored = DM_LIST_HEAD_INIT(_dummy_fid.metadata_areas_ignored),
 };
 
 static struct volume_group _dummy_vg = {
 	.fid = &_dummy_fid,
 	.name = "",
 	.system_id = (char *) "",
-	.pvs = { &(_dummy_vg.pvs), &(_dummy_vg.pvs) },
-	.lvs = { &(_dummy_vg.lvs), &(_dummy_vg.lvs) },
-	.tags = { &(_dummy_vg.tags), &(_dummy_vg.tags) },
+	.pvs = DM_LIST_HEAD_INIT(_dummy_vg.pvs),
+	.lvs = DM_LIST_HEAD_INIT(_dummy_vg.lvs),
+	.tags = DM_LIST_HEAD_INIT(_dummy_vg.tags),
 };
 
 static void *_obj_get_vg(void *obj)
diff --git a/tools/reporter.c b/tools/reporter.c
index c55d653..9688151 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -97,52 +97,42 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
-	struct lvinfo lvinfo;
+	struct lvinfo lvinfo = { .exists = 0 };
+
+	struct segment_type _freeseg_type = {
+		.cmd = cmd,
+		.name = "free",
+		.flags = SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED,
+	};
 
 	struct volume_group _free_vg = {
 		.cmd = cmd,
 		.name = "",
-		.vgmem = NULL,
+		.pvs = DM_LIST_HEAD_INIT(_free_vg.pvs),
+		.lvs = DM_LIST_HEAD_INIT(_free_vg.lvs),
+		.tags = DM_LIST_HEAD_INIT(_free_vg.tags),
 	};
 
 	struct logical_volume _free_logical_volume = {
 		.vg = vg ?: &_free_vg,
 		.name = "",
-		.snapshot = NULL,
 		.status = VISIBLE_LV,
 		.major = -1,
 		.minor = -1,
+		.tags = DM_LIST_HEAD_INIT(_free_logical_volume.tags),
+		.segments = DM_LIST_HEAD_INIT(_free_logical_volume.segments),
+		.segs_using_this_lv = DM_LIST_HEAD_INIT(_free_logical_volume.segs_using_this_lv),
+		.snapshot_segs = DM_LIST_HEAD_INIT(_free_logical_volume.snapshot_segs),
 	};
 
 	struct lv_segment _free_lv_segment = {
 		.lv = &_free_logical_volume,
-		.le = 0,
-		.status = 0,
-		.stripe_size = 0,
-		.area_count = 0,
-		.area_len = 0,
-		.origin = NULL,
-		.cow = NULL,
-		.chunk_size = 0,
-		.region_size = 0,
-		.extents_copied = 0,
-		.log_lv = NULL,
-		.areas = NULL,
+		.segtype = &_freeseg_type,
+		.len = pvseg->len,
+		.tags = DM_LIST_HEAD_INIT(_free_lv_segment.tags),
+		.origin_list = DM_LIST_HEAD_INIT(_free_lv_segment.origin_list),
 	};
 
-	_free_lv_segment.segtype = get_segtype_from_string(cmd, "free");
-	_free_lv_segment.len = pvseg->len;
-	dm_list_init(&_free_vg.pvs);
-	dm_list_init(&_free_vg.lvs);
-	dm_list_init(&_free_vg.tags);
-	dm_list_init(&_free_lv_segment.tags);
-	dm_list_init(&_free_lv_segment.origin_list);
-	dm_list_init(&_free_logical_volume.tags);
-	dm_list_init(&_free_logical_volume.segments);
-	dm_list_init(&_free_logical_volume.segs_using_this_lv);
-	dm_list_init(&_free_logical_volume.snapshot_segs);
-
-	lvinfo.exists = 0;
 	if (seg && lv_info_needed)
 	    _get_lv_info_for_report(cmd, seg->lv, &lvinfo);
 



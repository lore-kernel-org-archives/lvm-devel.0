From: Milan Broz <mbroz@redhat.com>
Date: Fri, 29 May 2009 10:35:37 +0200
Subject: [PATCH] Fix readahead calculation segfault.
Message-ID: <4A1F9E59.3010905@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix readahead calculation problems.

During vgreduce is failed mirror image replaced with error segment,
this segmant type has always area_count == 0.
Current code expects that there is at least one area with device,
patch fixes it by additional check (fixes segfault during vgreduce).

Also do not calculate readahead in every lv_info call, we only need
to cache PV readahead before suspend.

(In all other cases should be calling readahead calculation in
device_manager/add_lv enough.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c |   10 +++++-----
 lib/metadata/metadata.c |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 12e8b20..42058d7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -469,11 +469,6 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv, in
 	info->live_table = dminfo.live_table;
 	info->inactive_table = dminfo.inactive_table;
 
-	/*
-	 * Cache read ahead value for PV devices now (before possible suspend)
-	 */
-	(void)lv_calculate_readhead(lv);
-
 	if (name)
 		dm_pool_free(cmd->mem, name);
 
@@ -874,6 +869,11 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (!lv_info(cmd, lv, &info, 0, 0))
 		goto_out;
 
+	/*
+	 * Cache read ahead value for PV devices now (before suspend)
+	 */
+	(void)lv_calculate_readhead(lv);
+
 	if (!info.exists || info.suspended) {
 		r = error_if_not_suspended ? 0 : 1;
 		goto out;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6e4091a..3378ece 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1423,7 +1423,7 @@ static int _lv_read_ahead_single(struct logical_volume *lv, void *data)
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t seg_read_ahead = 0, *read_ahead = data;
 
-	if (seg && seg_type(seg, 0) == AREA_PV)
+	if (seg && seg->area_count && seg_type(seg, 0) == AREA_PV)
 		dev_get_read_ahead(seg_pv(seg, 0)->dev, &seg_read_ahead);
 
 	if (seg_read_ahead > *read_ahead)




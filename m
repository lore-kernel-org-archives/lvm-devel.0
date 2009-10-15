From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 15 Oct 2009 10:07:30 -0400
Subject: [PATCH] Change process_each_lv_in_vg() iterator to only process non-hidden LVs.
Message-ID: <1255615650-3655-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Unless the "--all" flag is given, the iterator functions should not be
processing hidden LVs.  I have checked all the tools and this seems to
be how they all behave.  Somehow before I missed the fact I could re-use
the "--all" flag to qualify the hidden LV check (perhaps it's because
the all flag is not documented well).  If there are things I've overlooked
I can deal with them in another patch.  I am working on patches to clarify
and document the usage of "--all".

Remove redundant checks in a few tools.

This addresses rhbz 232499 (benign error messages when lvchange used
with VG containing hidden LVs).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvdisplay.c |    3 ---
 tools/lvscan.c    |    3 ---
 tools/reporter.c  |    6 ------
 tools/toollib.c   |    3 +++
 4 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index f5531cb..65c1012 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -18,9 +18,6 @@
 static int _lvdisplay_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
-		return ECMD_PROCESSED;
-
 	if (arg_count(cmd, colon_ARG))
 		lvdisplay_colons(lv);
 	else {
diff --git a/tools/lvscan.c b/tools/lvscan.c
index a65bd1d..a4f419d 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -28,9 +28,6 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	const char *active_str, *snapshot_str;
 
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
-		return ECMD_PROCESSED;
-
 	inkernel = lv_info(cmd, lv, &info, 1, 0) && info.exists;
 	if (lv_is_origin(lv)) {
 		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
diff --git a/tools/reporter.c b/tools/reporter.c
index 1e93689..6186d5b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -33,9 +33,6 @@ static int _vgs_single(struct cmd_context *cmd __attribute((unused)),
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
-		return ECMD_PROCESSED;
-
 	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL)) {
 		stack;
 		return ECMD_FAILED;
@@ -116,9 +113,6 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
 			  void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
-		return ECMD_PROCESSED;
-
 	return process_each_segment_in_lv(cmd, lv, handle, _segs_single);
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index d14dc77..d85f731 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -122,6 +122,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
 
+		if (!lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
+			continue;
+
 		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
 			continue;
 
-- 
1.6.0.6



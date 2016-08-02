From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  2 Aug 2016 18:52:37 +0000 (UTC)
Subject: master - lvconvert: Preserve mirror region size with --repair.
Message-ID: <20160802185237.8277860FE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a234cebbed19657058cdba87a5e2c23d50ff05fe
Commit:        a234cebbed19657058cdba87a5e2c23d50ff05fe
Parent:        415c5fd5d8e58b34fd016ba1e45dc43c6ed10e18
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 2 19:50:04 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 2 19:50:04 2016 +0100

lvconvert: Preserve mirror region size with --repair.

---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   10 ++++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aa839bd..3a64bbd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.163 - 
 =================================
+  Preserve existing mirror region size when using --repair.
   Forbid stripe parameters with lvconvert --repair.
   Unify stripe size validation into get_stripe_params to catch missing cases.
   Further lvconvert validation logic refactoring.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8444b35..c01eec9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1365,7 +1365,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 				  uint32_t new_log_count)
 {
 	uint32_t region_size;
-	struct lv_segment *seg;
+	struct lv_segment *seg = first_seg(lv);
 	struct logical_volume *layer_lv;
 	uint32_t old_mimage_count = lv_mirror_count(lv);
 	uint32_t old_log_count = _get_log_count(lv);
@@ -1378,14 +1378,12 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 
 	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
 						  lv->le_count,
-						  lp->region_size, 0,
+						  lp->region_size ? : seg->region_size, 0,
 						  vg_is_clustered(lv->vg));
 
 	if (!operable_pvs)
 		operable_pvs = lp->pvh;
 
-	seg = first_seg(lv);
-
 	/*
 	 * Up-convert from linear to mirror
 	 */
@@ -1605,6 +1603,10 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	failed_mimages = _failed_mirrors_count(lv);
 	failed_logs = _failed_logs_count(lv);
 
+	/* Retain existing region size in case we need it later */
+	if (!lp->region_size)
+		lp->region_size = first_seg(lv)->region_size;
+
 	if (!mirror_remove_missing(cmd, lv, 0))
 		return_0;
 



From: Mike Snitzer <msnitzer@fedoraproject.org>
Date: Tue,  2 Jul 2013 21:02:51 +0000 (UTC)
Subject: master - lvconvert: Rename _swap_lv to _swap_lv_identifiers and move to allow an additional user
Message-ID: <20130702210251.4687B610AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe09d84668487f2a6b64edccced1ed049cc9ac18
Commit:        fe09d84668487f2a6b64edccced1ed049cc9ac18
Parent:        f9e0adcce56055f625ab8c77c7d66e4db61fe23a
Author:        Mike Snitzer <snitzer@redhat.com>
AuthorDate:    Tue Jul 2 17:02:25 2013 -0400
Committer:     Mike Snitzer <snitzer@redhat.com>
CommitterDate: Tue Jul 2 17:02:25 2013 -0400

lvconvert: Rename _swap_lv to _swap_lv_identifiers and move to allow an additional user

---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   42 +++++++++++++++++++++---------------------
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 60b2fac..f1f9a82 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Rename _swap_lv to _swap_lv_identifiers and move to allow an additional user.
   Rename snapshot segment returning methods from find_*_cow to find_*_snapshot.
   liblvm/python API: Additions: PV create/removal/resize/listing
   liblvm/python API: Additions: LV attr/origin/Thin pool/Thin LV creation
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4ac7e54..4d2a432 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -650,6 +650,25 @@ static progress_t _poll_merge_progress(struct cmd_context *cmd,
 	return PROGRESS_UNFINISHED;
 }
 
+/* Swap lvid and LV names */
+static int _swap_lv_identifiers(struct cmd_context *cmd,
+				struct logical_volume *a, struct logical_volume *b)
+{
+	union lvid lvid;
+	const char *name;
+
+	lvid = a->lvid;
+	a->lvid = b->lvid;
+	b->lvid = lvid;
+
+	name = a->name;
+	a->name = b->name;
+	if (!lv_rename_update(cmd, b, name, 0))
+		return_0;
+
+	return 1;
+}
+
 static struct poll_functions _lvconvert_mirror_fns = {
 	.get_copy_vg = _get_lvconvert_vg,
 	.get_copy_lv = _get_lvconvert_lv,
@@ -1869,25 +1888,6 @@ out:
 	return r;
 }
 
-/* Swap lvid and LV names */
-static int _swap_lv(struct cmd_context *cmd,
-		    struct logical_volume *a, struct logical_volume *b)
-{
-	union lvid lvid;
-	const char *name;
-
-	lvid = a->lvid;
-	a->lvid = b->lvid;
-	b->lvid = lvid;
-
-	name = a->name;
-	a->name = b->name;
-	if (!lv_rename_update(cmd, b, name, 0))
-		return_0;
-
-	return 1;
-}
-
 static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 					struct logical_volume *pool_lv,
 					struct logical_volume *external_lv,
@@ -1932,7 +1932,7 @@ static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 	 * which could be easily removed by the user after i.e. power-off
 	 */
 
-	if (!_swap_lv(cmd, torigin_lv, external_lv)) {
+	if (!_swap_lv_identifiers(cmd, torigin_lv, external_lv)) {
 		stack;
 		goto revert_new_lv;
 	}
@@ -1956,7 +1956,7 @@ static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 	return 1;
 
 deactivate_and_revert_new_lv:
-	if (!_swap_lv(cmd, torigin_lv, external_lv))
+	if (!_swap_lv_identifiers(cmd, torigin_lv, external_lv))
 		stack;
 
 	if (!deactivate_lv(cmd, torigin_lv)) {



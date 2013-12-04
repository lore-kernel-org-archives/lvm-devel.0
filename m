From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:29 +0000 (UTC)
Subject: master - cleanup: code move
Message-ID: <20131204133129.3297160EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d7a76ccbfcfe6579333a58c61a51d556ba8507f
Commit:        6d7a76ccbfcfe6579333a58c61a51d556ba8507f
Parent:        5a6794a2ce74416c399f8cf28f2625de8ba9cd55
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 17:20:56 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:25 2013 +0100

cleanup: code move

Move _swap_lv_identifiers() above  _finish_lvconvert_merge()
so it could be used from this function.
---
 tools/lvconvert.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a0fa679..273f56a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -670,6 +670,25 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 	return 1;
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
 static int _finish_lvconvert_merge(struct cmd_context *cmd,
 				   struct volume_group *vg,
 				   struct logical_volume *lv,
@@ -723,25 +742,6 @@ static progress_t _poll_merge_progress(struct cmd_context *cmd,
 	return PROGRESS_UNFINISHED;
 }
 
-/* Swap lvid and LV names */
-static int _swap_lv_identifiers(struct cmd_context *cmd,
-				struct logical_volume *a, struct logical_volume *b)
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
 static struct poll_functions _lvconvert_mirror_fns = {
 	.get_copy_vg = _get_lvconvert_vg,
 	.get_copy_lv = _get_lvconvert_lv,



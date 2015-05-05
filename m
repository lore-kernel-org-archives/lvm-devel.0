From: okozina <okozina@fedoraproject.org>
Date: Tue,  5 May 2015 18:54:09 +0000 (UTC)
Subject: master - lvconvert: code cleanup and preps for refactoring
Message-ID: <20150505185409.2FCE360ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=991d646354a10e9953fdf0e75cb2a33a81f6ffef
Commit:        991d646354a10e9953fdf0e75cb2a33a81f6ffef
Parent:        32527861d02bbd0bd3d0e0adec0f193f1f5eb98b
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 5 15:11:50 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 5 20:51:27 2015 +0200

lvconvert: code cleanup and preps for refactoring

just a code cleanup and preparations for adding
new code required for polldaemon refactoring.
This commit should not have any functional impact.
---
 tools/lvconvert.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 357a3ce..5f5b551 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -734,6 +734,7 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 	char uuid[sizeof(lv->lvid)];
 	char lv_full_name[NAME_LEN];
+	int is_thin, r;
 
 	if (dm_snprintf(lv_full_name, sizeof(lv_full_name), "%s/%s", lv->vg->name, lv->name) < 0) {
 		log_error(INTERNAL_ERROR "Name \"%s/%s\" is too long.", lv->vg->name, lv->name);
@@ -742,14 +743,16 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 
 	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));
 
-	if (lv_is_merging_origin(lv))
-		return poll_daemon(cmd, lv_full_name, uuid, background, 0,
-				   seg_is_thin_volume(find_snapshot(lv)) ?
-				   &_lvconvert_thin_merge_fns : &_lvconvert_merge_fns,
-				   "Merged");
+	if (lv_is_merging_origin(lv)) {
+		is_thin = seg_is_thin_volume(find_snapshot(lv));
+		r = poll_daemon(cmd, lv_full_name, uuid, background, 0,
+				is_thin ? &_lvconvert_thin_merge_fns : &_lvconvert_merge_fns,
+				"Merged");
+	} else
+		r = poll_daemon(cmd, lv_full_name, uuid, background, 0,
+				&_lvconvert_mirror_fns, "Converted");
 
-	return poll_daemon(cmd, lv_full_name, uuid, background, 0,
-			   &_lvconvert_mirror_fns, "Converted");
+	return r;
 }
 
 static int _insert_lvconvert_layer(struct cmd_context *cmd,



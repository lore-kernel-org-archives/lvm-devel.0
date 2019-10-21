From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Oct 2019 09:33:08 -0400
Subject: master - lvconvert: use new functions
Message-ID: <201910211333.x9LDX8S1019573@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a5f8e7a96cd26afd14a8ddc6ab1a64a32dcf6fc6
Commit:        a5f8e7a96cd26afd14a8ddc6ab1a64a32dcf6fc6
Parent:        766dedb62899f764ef75f21b17b86c0f17f9d009
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 21 09:18:34 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 21 12:14:15 2019 +0200

lvconvert: use new functions

---
 tools/lvconvert.c |   18 +++---------------
 1 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a21f965..8b5bf51 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1841,7 +1841,6 @@ static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 				   struct logical_volume *lv_fast)
 {
 	char cvol_name[NAME_LEN];
-	char *c;
 	struct lv_segment *cache_seg = first_seg(lv);
 	int cache_mode = cache_seg->cache_mode;
 
@@ -1882,23 +1881,12 @@ static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 		return_0;
 
 	/* Cut off suffix _cvol */
-	if (!dm_strncpy(cvol_name, lv_fast->name, sizeof(cvol_name)) ||
-	    !(c = strstr(cvol_name, "_cvol"))) {
+	if (!drop_lvname_suffix(cvol_name, lv_fast->name, "cvol")) {
 		/* likely older instance of metadata */
 		log_debug("LV %s has no suffix for cachevol (skipping rename).",
 			  display_lvname(lv_fast));
-	} else {
-		*c = 0;
-		/* If the name is in use, generate new lvol%d */
-		if (lv_name_is_used_in_vg(lv->vg, cvol_name, NULL) &&
-		    !generate_lv_name(lv->vg, "lvol%d", cvol_name, sizeof(cvol_name))) {
-			log_error("Failed to generate unique name for unused logical volume.");
-			return 0;
-		}
-
-		if (!lv_rename_update(cmd, lv_fast, cvol_name, 0))
-			return_0;
-	}
+	} else if (!lv_uniq_rename_update(cmd, lv_fast, cvol_name, 0))
+		return_0;
 
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;



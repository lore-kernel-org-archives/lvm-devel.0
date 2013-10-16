From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 16 Oct 2013 08:56:13 +0000 (UTC)
Subject: master - thin: fix lvconvert for active pool.
Message-ID: <20131016085613.C7B5F60BAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b7631101b2ac34d25cd5d3140001e86371997f9
Commit:        1b7631101b2ac34d25cd5d3140001e86371997f9
Parent:        48df36b8c531a43da8602b50759c9e841e1d9f44
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 10:11:37 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 16 10:53:01 2013 +0200

thin: fix lvconvert for active pool.

Prohibit conversion of pool device with active thin volumes.
Properly restore active states only for active thin pool volume.
Use new LV_NOSCAN when converting volume into thin pool's metadata.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   16 +++++++++++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f5f0256..79a960c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Fix lvconvert swap of poolmetadata volume for active thin pool.
   Check for open count with a timeout before removal/deactivation of an LV.
   Report RAID images split with tracking as out-of-sync ("I").
   Improve parsing of snapshot lv segment.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ee6d868..eaac565 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2275,6 +2275,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	struct logical_volume *pool_metadata_lv;
 	struct logical_volume *external_lv = NULL;
 	char metadata_name[NAME_LEN], data_name[NAME_LEN];
+	int activate_pool;
 
 	if (!lv_is_visible(pool_lv)) {
 		log_error("Can't convert internal LV %s/%s.",
@@ -2303,6 +2304,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		}
 
 		if (lv_is_thin_pool(pool_lv)) {
+			activate_pool = lv_is_active(pool_lv);
 			r = 1; /* Already existing thin pool */
 			goto out;
 		}
@@ -2315,6 +2317,9 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/* Allow to have only thinpool active and restore it's active state */
+	activate_pool = lv_is_active(pool_lv);
+
 	/* We are changing target type, so deactivate first */
 	if (!deactivate_lv(cmd, pool_lv)) {
 		log_error("Aborting. Failed to deactivate logical volume %s/%s.",
@@ -2322,6 +2327,13 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (pool_is_active(pool_lv)) {
+		/* If any thin volume is also active - abort here */
+		log_error("Cannot convert pool %s/%s with active thin volumes.",
+			  pool_lv->vg->name, pool_lv->name);
+		return 0;
+	}
+
 	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s_tmeta",
 			 pool_lv->name) < 0) ||
 	    (dm_snprintf(data_name, sizeof(data_name), "%s_tdata",
@@ -2423,6 +2435,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 			goto mda_write;
 		}
 
+		metadata_lv->status |= LV_NOSCAN;
 		if (!lv_is_active(metadata_lv) &&
 		    !activate_lv_local(cmd, metadata_lv)) {
 			log_error("Aborting. Failed to activate thin metadata lv.");
@@ -2515,7 +2528,8 @@ mda_write:
 	if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
 		return_0;
 
-	if (!activate_lv_excl(cmd, pool_lv)) {
+	if (activate_pool &&
+	    !activate_lv_excl(cmd, pool_lv)) {
 		log_error("Failed to activate pool logical volume %s/%s.",
 			  pool_lv->vg->name, pool_lv->name);
 		/* Deactivate subvolumes */



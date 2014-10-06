From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:08 +0000 (UTC)
Subject: master - cache: lvremoved cached LV removes cache pool
Message-ID: <20141006133308.7F3DA611CF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75119d85b3dfe9f53187f37130fd6d215705c166
Commit:        75119d85b3dfe9f53187f37130fd6d215705c166
Parent:        cb273fe16423a2868c0bdde7c8e56cb21131338d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 23:36:11 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:06 2014 +0200

cache: lvremoved cached LV removes cache pool

When we remove cached volume, whole tree must go down.
There is  'lvconvert --splitcache' to preserve cache pool.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   23 +++++++++++++++++++++--
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3d5f9c4..a11fa16 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Lvremoving cached LV removes cachepool (keep with lvconvert --splitcache).
   Always remove spare LV with last removed pool volume.
   Support lvconvert --splitcache and --uncache of cached LV.
   Option --cache has also shortcut -H (i.e. lvcreate -H).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 00f0fbc..168ce05 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1272,6 +1272,7 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 	struct lv_segment *seg;
 	uint32_t count = extents;
 	uint32_t reduction;
+	struct logical_volume *pool_lv;
 
 	if (lv_is_merging_origin(lv)) {
 		log_debug_metadata("Dropping snapshot merge of %s to removed origin %s.",
@@ -1302,8 +1303,13 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 			if (delete && seg_is_cache(seg) && !lv_remove(seg_lv(seg, 0)))
 				return_0;
 
-			if (seg->pool_lv && !detach_pool_lv(seg))
-				return_0;
+			if ((pool_lv = seg->pool_lv)) {
+				if (!detach_pool_lv(seg))
+					return_0;
+				/* When removing cached LV, remove pool as well */
+				if (seg_is_cache(seg) && !lv_remove(pool_lv))
+					return_0;
+			}
 
 			dm_list_del(&seg->list);
 			reduction = seg->len;
@@ -5454,6 +5460,19 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!archive(vg))
 		return 0;
 
+	if (lv_is_cache(lv)) {
+		if (!lv_remove_single(cmd, first_seg(lv)->pool_lv, force,
+				      suppress_remove_message)) {
+			if (force < DONT_PROMPT_OVERRIDE) {
+				log_error("Failed to uncache %s.", display_lvname(lv));
+				return 0;
+			}
+			/* Proceed with -ff */
+			log_print_unless_silent("Ignoring uncache failure of %s.",
+						display_lvname(lv));
+		}
+	}
+
 	if (lv_is_cow(lv)) {
 		/* Old format1 code */
 		if (!(lv->vg->fid->fmt->features & FMT_MDAS))



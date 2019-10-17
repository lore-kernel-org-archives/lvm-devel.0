From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Oct 2019 07:05:18 -0400
Subject: master - cachevol: support removal of cachevol
Message-ID: <201910171105.x9HB5IeI023654@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ec85dfe0f8096ee486c39c22b740f3938932707e
Commit:        ec85dfe0f8096ee486c39c22b740f3938932707e
Parent:        5938cde11bb7298104871acf47d60b0fd5835b71
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 17 12:48:56 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 13:03:50 2019 +0200

cachevol: support removal of cachevol

Removal of cachevol is equivalent of lvconvert --uncache
and works the same way as with cachepool.
---
 lib/metadata/lv_manip.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b5b9a4a..815ea99 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6278,7 +6278,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* FIXME Ensure not referred to by another existing LVs */
 	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
 
-	if (lv_is_active(lv)) {
+	if (!lv_is_cache_vol(lv) &&
+	    lv_is_active(lv)) {
 		if (!lv_check_not_in_use(lv, 1))
 			return_0;
 
@@ -6355,6 +6356,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* Used cache pool, COW or historical LV cannot be activated */
 	if (!lv_is_used_cache_pool(lv) &&
+	    !lv_is_cache_vol(lv) &&
 	    !lv_is_cow(lv) && !lv_is_historical(lv) &&
 	    !deactivate_lv_with_sub_lv(lv))
 		/* FIXME Review and fix the snapshot error paths! */
@@ -6404,7 +6406,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (lv_is_used_cache_pool(lv)) {
+	if (lv_is_used_cache_pool(lv) || lv_is_cache_vol(lv)) {
 		/* Cache pool removal drops cache layer
 		 * If the cache pool is not linked, we can simply remove it. */
 		if (!(cache_seg = get_only_segment_using_this_lv(lv)))



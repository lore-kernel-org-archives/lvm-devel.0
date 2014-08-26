From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Aug 2014 12:17:40 +0000 (UTC)
Subject: master - cleanup: indent and stacktrack
Message-ID: <20140826121740.F41A160E57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25fe716b123109dee83a593d3c354ffac13b06b1
Commit:        25fe716b123109dee83a593d3c354ffac13b06b1
Parent:        24001a08ab92737b32968aeba5f6b2b9c036c480
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 26 11:39:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 26 14:13:07 2014 +0200

cleanup: indent and stacktrack

Add missing stacktrace on error path
and newline indent.
---
 lib/activate/dev_manager.c |    2 +-
 lib/metadata/lv_manip.c    |    1 +
 lib/metadata/metadata.c    |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2cf0b65..d336afc 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2330,7 +2330,7 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 						  &dm->target_state, seg,
 						  laopts, dnode,
 						  extent_size * seg->len,
-						  &dm-> pvmove_mirror_count);
+						  &dm->pvmove_mirror_count);
 }
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e57e7b3..3d91856 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5698,6 +5698,7 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	if (lv_is_used_thin_pool(lv) &&
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
 		return_0;
+
 	if ((lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) &&
 	    lv->vg->pool_metadata_spare_lv) {
 		/* When removing last pool, also remove the spare */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 168c110..f8ffe30 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -531,7 +531,7 @@ int remove_lvs_in_vg(struct cmd_context *cmd,
 	while ((lst = dm_list_first(&vg->lvs))) {
 		lvl = dm_list_item(lst, struct lv_list);
 		if (!lv_remove_with_dependencies(cmd, lvl->lv, force, 0))
-		    return 0;
+			return_0;
 	}
 
 	return 1;



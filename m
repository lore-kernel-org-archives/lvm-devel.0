From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 May 2016 16:41:36 +0000 (UTC)
Subject: master - debug: use display_lvname
Message-ID: <20160519164136.2D0A3606EF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c083d34af0bc3ce690b3086714dd812c6a15193
Commit:        9c083d34af0bc3ce690b3086714dd812c6a15193
Parent:        197066c863607a884c0eef2f16d969aa00adcab1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 18 15:22:26 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 19 18:40:14 2016 +0200

debug: use display_lvname

Add some tracing message
---
 lib/activate/dev_manager.c    |    2 ++
 lib/format_text/import_vsn1.c |    5 ++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c07af2d..f6cc0be 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2154,6 +2154,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		dm_list_iterate(snh, &lv->snapshot_segs)
 			if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, 0))
 				return_0;
+
 	if (dm->activation && !origin_only && lv_is_merging_origin(lv) &&
 	    !_add_lv_to_dtree(dm, dtree, find_snapshot(lv)->lv, 1))
 		return_0;
@@ -3104,6 +3105,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 	/* Some targets may build bigger tree for activation */
 	dm->activation = ((action == PRELOAD) || (action == ACTIVATE));
 	dm->suspend = (action == SUSPEND_WITH_LOCKFS) || (action == SUSPEND);
+
 	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))
 		return_0;
 
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index f9a1040..d2219e4 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -569,8 +569,11 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	if (!(lv->name = dm_pool_strdup(mem, lvn->key)))
 		return_0;
 
+	log_debug_metadata("Importing logical volume %s.", display_lvname(lv));
+
 	if (!(lvn = lvn->child)) {
-		log_error("Empty logical volume section.");
+		log_error("Empty logical volume section for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:53:44 +0000 (UTC)
Subject: master - debug: fix backtracing
Message-ID: <20140520195344.E076460190@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9fd0be2a8507e1134bf1f5d0e84dd80b765a6b19
Commit:        9fd0be2a8507e1134bf1f5d0e84dd80b765a6b19
Parent:        c70c100cce6cdd1f3723203c2cec4427eba7a464
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 12:53:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:28 2014 +0200

debug: fix backtracing

---
 lib/metadata/mirror.c |    2 +-
 tools/lvconvert.c     |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 86ec4ca..9a413e8 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2156,7 +2156,7 @@ int lv_split_mirror_images(struct logical_volume *lv, const char *split_name,
 	 */
 	r = _split_mirror_images(lv, split_name, split_count, removable_pvs);
 	if (!r)
-		return 0;
+		return_0;
 
 	return 1;
 }
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3c20257..2200ba2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1001,7 +1001,7 @@ static struct dm_list *_failed_pv_list(struct volume_group *vg)
 
 	if (!(failed_pvs = dm_pool_alloc(vg->vgmem, sizeof(*failed_pvs)))) {
 		log_error("Allocation of list of failed_pvs failed.");
-		return_NULL;
+		return NULL;
 	}
 
 	dm_list_init(failed_pvs);
@@ -1022,7 +1022,7 @@ static struct dm_list *_failed_pv_list(struct volume_group *vg)
 
 		if (!(new_pvl = dm_pool_alloc(vg->vgmem, sizeof(*new_pvl)))) {
 			log_error("Allocation of failed_pvs list entry failed.");
-			return_NULL;
+			return NULL;
 		}
 		new_pvl->pv = pvl->pv;
 		dm_list_add(failed_pvs, &new_pvl->list);
@@ -1539,7 +1539,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 			}
 			if (!lv_split_mirror_images(lv, lp->lv_split_name,
 						    nmc, operable_pvs))
-				return 0;
+				return_0;
 		} else if (!lv_remove_mirrors(cmd, lv, nmc, nlc,
 					      is_mirror_image_removable, operable_pvs, 0))
 			return_0;
@@ -1584,17 +1584,17 @@ int mirror_remove_missing(struct cmd_context *cmd,
 	 * will get stuck during a suspend.
 	 */
 	if (!_lv_update_mirrored_log(lv, failed_pvs, log_count))
-		return 0;
+		return_0;
 
 	if (_failed_mirrors_count(lv) > 0 &&
 	    !lv_remove_mirrors(cmd, lv, _failed_mirrors_count(lv),
 			       log_count ? 0U : 1U,
 			       _is_partial_lv, NULL, 0))
-		return 0;
+		return_0;
 
 	if (lv_is_mirrored(lv) &&
 	    !_lv_update_log_type(cmd, NULL, lv, failed_pvs, log_count))
-		return 0;
+		return_0;
 
 	if (!_reload_lv(cmd, lv->vg, lv))
 		return_0;



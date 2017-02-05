From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  5 Feb 2017 16:56:43 +0000 (UTC)
Subject: master - comment: update
Message-ID: <20170205165643.3D74060C86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=12bbfbe89de5201f89ebad372ddd5f393142b13a
Commit:        12bbfbe89de5201f89ebad372ddd5f393142b13a
Parent:        fb3f4ed72d6be15e99fdfe490049264eecc07997
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 4 15:44:25 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 5 17:55:37 2017 +0100

comment: update

Fix can -> cannot.
---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d36f113..cde026e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3075,7 +3075,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 				     (laopts->origin_only) ? " origin-only" : "",
 				     display_lvname(lv));
 
-	/* Some LV can be used for top level tree */
+	/* Some LV cannot be used for top level tree */
 	/* TODO: add more.... */
 	if (lv_is_cache_pool(lv) && !dm_list_empty(&lv->segs_using_this_lv)) {
 		log_error(INTERNAL_ERROR "Cannot create tree for %s.",



From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:41 +0000 (UTC)
Subject: dev-prajnoha-selout - clenaup: drop unused assigns
Message-ID: <20140509065641.9B53560C5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9845f8c7674892d7760526b36e45c6425bd1950f
Commit:        9845f8c7674892d7760526b36e45c6425bd1950f
Parent:        9bccaf7ae40ca0d17e5d1b65f7c7aaf2d78eb2b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 7 11:58:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:17:46 2014 +0200

clenaup: drop unused assigns

---
 lib/metadata/cache_manip.c |    2 +-
 tools/lvcreate.c           |    1 -
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 6a0f0f6..0e2569c 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -123,7 +123,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool,
 		return_NULL;
 
 	cache_lv = origin;
-	if (!(origin = insert_layer_for_lv(cmd, cache_lv, CACHE, "_corig")))
+	if (!insert_layer_for_lv(cmd, cache_lv, CACHE, "_corig"))
 		return_NULL;
 
 	seg = first_seg(cache_lv);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0e009b1..2156265 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -323,7 +323,6 @@ static int _determine_cache_argument(struct volume_group *vg,
 		lp->poolmetadataspare = arg_int_value(vg->cmd,
 						      poolmetadataspare_ARG,
 						      DEFAULT_POOL_METADATA_SPARE);
-		lp->origin = lp->origin;
 	}
 
 	return 1;



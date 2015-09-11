From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Sep 2015 19:54:31 +0000 (UTC)
Subject: master - thin: lvconvert use passed PVs for _pmspare
Message-ID: <20150911195431.1B65660F52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=280a6275ce7262baae0062c58a63b910bc16327d
Commit:        280a6275ce7262baae0062c58a63b910bc16327d
Parent:        95b5d24f434b6f2174d500a0c7b2bba78b7cd2e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 20:56:02 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:48:19 2015 +0200

thin: lvconvert use passed PVs for _pmspare

When PVs are given on 'lvconvert' respect them when converting
volume to thin-pool and allocating i.e. _pmspare.
---
 WHATS_NEW         |    3 ++-
 tools/lvconvert.c |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6e23fcb..163077f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.131 - 
 =====================================
-  Disallow usage of --stripe and --stripsize when creating cache pool.
+  Use passed list of PVS when allocating space in lvconvert --thinpool.
+  Disallow usage of --stripe and --stripesize when creating cache pool.
   Warn user when caching raid or thin pool data LV.
   When layering LV, move LV flags with segments.
   Ignore persistent cache if configuration changed. (2.02.127)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 237de2d..6b8f7aa 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2348,7 +2348,7 @@ static int _lvconvert_pool_repair(struct cmd_context *cmd,
 	pmslv = pool_lv->vg->pool_metadata_spare_lv;
 
 	/* Check we have pool metadata spare LV */
-	if (!handle_pool_metadata_spare(pool_lv->vg, 0, NULL, 1))
+	if (!handle_pool_metadata_spare(pool_lv->vg, 0, lp->pvh, 1))
 		return_0;
 
 	if (pmslv != pool_lv->vg->pool_metadata_spare_lv) {
@@ -2473,7 +2473,7 @@ deactivate_pmslv:
 	}
 
 	/* Try to allocate new pool metadata spare LV */
-	if (!handle_pool_metadata_spare(pool_lv->vg, 0, NULL, 1))
+	if (!handle_pool_metadata_spare(pool_lv->vg, 0, lp->pvh, 1))
 		stack;
 
 	if (dm_snprintf(meta_path, sizeof(meta_path), "%s_meta%%d", pool_lv->name) < 0) {



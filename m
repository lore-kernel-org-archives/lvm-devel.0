From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:56:52 +0000 (UTC)
Subject: master - thin: no pool can be used for external origins
Message-ID: <20140924085652.1B42C6109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd3345a5b06ee1626101619f94b346a77295ca03
Commit:        cd3345a5b06ee1626101619f94b346a77295ca03
Parent:        a84d0d0c7b843168516a940a8bc4debafc5f980c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 22 14:09:55 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:52:02 2014 +0200

thin: no pool can be used for external origins

Cache pool can't be external origin either.
For simplicity use vg from passed LV.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 39282c2..a94edc6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Pools cannot be used as external origin.
   Use lv_update_and_reload() for snapshot reload.
   Don't print message in adjusted_mirror_region_size() in activation.
   Improve lv_update_and_reload() to find out proper lock holding LV.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e501978..62e560c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2511,7 +2511,7 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 			   struct lvconvert_params *lp)
 {
 	struct logical_volume *torigin_lv, *pool_lv = lp->pool_data_lv;
-	struct volume_group *vg = pool_lv->vg;
+	struct volume_group *vg = lv->vg;
 	struct lvcreate_params lvc = {
 		.activate = CHANGE_AEY,
 		.alloc = ALLOC_INHERIT,
@@ -2533,7 +2533,7 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_is_thin_pool(lv)) {
+	if (lv_is_pool(lv)) {
 		log_error("Can't use pool %s as external origin.",
 			  display_lvname(lv));
 		return 0;



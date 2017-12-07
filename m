From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 7 Dec 2017 11:24:51 -0500
Subject: master - lvmetad: drop stray underscore
Message-ID: <201712071624.vB7GOp3E005516@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2166d7be72c7371f0f94934625252646c5164a2c
Commit:        2166d7be72c7371f0f94934625252646c5164a2c
Parent:        d591d041033ce66f092becb285fc43f6fef63ee8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Dec 7 16:24:14 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Dec 7 16:24:14 2017 +0000

lvmetad: drop stray underscore

---
 lib/cache/lvmetad.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 6755ed6..e1f829c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1519,7 +1519,7 @@ int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 	return 1;
 }
 
-struct _extract_dl_baton {
+struct extract_dl_baton {
 	int i;
 	struct dm_config_tree *cft;
 	struct dm_config_node *pre_sib;
@@ -1527,7 +1527,7 @@ struct _extract_dl_baton {
 
 static int _extract_mda(struct metadata_area *mda, void *baton)
 {
-	struct _extract_dl_baton *b = baton;
+	struct extract_dl_baton *b = baton;
 	struct dm_config_node *cn;
 	char id[32];
 
@@ -1548,7 +1548,7 @@ static int _extract_mda(struct metadata_area *mda, void *baton)
 
 static int _extract_disk_location(const char *name, struct disk_locn *dl, void *baton)
 {
-	struct _extract_dl_baton *b = baton;
+	struct extract_dl_baton *b = baton;
 	struct dm_config_node *cn;
 	char id[32];
 
@@ -1583,7 +1583,7 @@ static int _extract_ba(struct disk_locn *ba, void *baton)
 static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
 			 struct dm_config_node *pre_sib)
 {
-	struct _extract_dl_baton baton = { .cft = cft };
+	struct extract_dl_baton baton = { .cft = cft };
 
 	if (!lvmcache_foreach_mda(info, &_extract_mda, &baton))
 		return 0;



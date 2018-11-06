From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:43:16 -0500
Subject: master - cache: reorganize cache_set_policy
Message-ID: <201811062143.wA6LhGtt004793@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a686391eca557fc35eb90c1ef4cdc57418b6ee19
Commit:        a686391eca557fc35eb90c1ef4cdc57418b6ee19
Parent:        23948e99b3d723f09456f75c93655817f87f1a82
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 16:14:45 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:29 2018 -0600

cache: reorganize cache_set_policy

to prepare for future addition
---
 lib/metadata/cache_manip.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 66f759f..8e8e704 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -748,23 +748,30 @@ static cache_metadata_format_t _get_default_cache_metadata_format(struct cmd_con
 	return f;
 }
 
-int cache_set_policy(struct lv_segment *seg, const char *name,
+int cache_set_policy(struct lv_segment *lvseg, const char *name,
 		     const struct dm_config_tree *settings)
 {
+	struct lv_segment *seg;
 	struct dm_config_node *cn;
 	const struct dm_config_node *cns;
 	struct dm_config_tree *old = NULL, *new = NULL, *tmp = NULL;
 	int r = 0;
-	struct profile *profile = seg->lv->profile;
+	struct profile *profile = lvseg->lv->profile;
 
-	if (seg_is_cache(seg))
-		seg = first_seg(seg->pool_lv);
-	else if (seg_is_cache_pool(seg)) {
+	if (seg_is_cache_pool(lvseg)) {
 		if (!name && !settings)
 			return 1; /* Policy and settings can be selected later when caching LV */
-	} else {
+	}
+
+	if (seg_is_cache_pool(lvseg))
+		seg = lvseg;
+
+	else if (seg_is_cache(lvseg))
+		seg = first_seg(lvseg->pool_lv);
+
+	else {
 		log_error(INTERNAL_ERROR "Cannot set cache metadata format for non cache volume %s.",
-			  display_lvname(seg->lv));
+			  display_lvname(lvseg->lv));
 		return 0;
 	}
 



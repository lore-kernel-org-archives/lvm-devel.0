From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:43:22 -0500
Subject: master - cache: factor lvchange_cache
Message-ID: <201811062143.wA6LhM60004810@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c9d9a744605e37799a2475932ae7dfd43831d08
Commit:        8c9d9a744605e37799a2475932ae7dfd43831d08
Parent:        e548e7c29d18034d153dc2ebe4ff0cc6bb99dc81
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 16:38:08 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:34 2018 -0600

cache: factor lvchange_cache

to prepare for future addition
---
 tools/lvchange.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 07a578b..52b3bda 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -636,18 +636,26 @@ static int _lvchange_cache(struct cmd_context *cmd,
 	cache_mode_t mode;
 	const char *name;
 	struct dm_config_tree *settings = NULL;
-	struct lv_segment *pool_seg = first_seg(lv);
+	struct lv_segment *seg;
+	struct lv_segment *setting_seg = NULL;
 	int r = 0, is_clean;
 	uint32_t chunk_size = 0; /* FYI: lvchange does NOT support its change */
 
-	if (lv_is_cache(lv))
-		pool_seg = first_seg(pool_seg->pool_lv);
+	seg = first_seg(lv);
+
+	if (seg_is_cache_pool(seg))
+		setting_seg = seg;
+
+	else if (seg_is_cache(seg))
+		setting_seg = first_seg(seg->pool_lv);
+	else
+		goto_out;
 
 	if (!get_cache_params(cmd, &chunk_size, &format, &mode, &name, &settings))
 		goto_out;
 
 	if ((mode != CACHE_MODE_UNSELECTED) &&
-	    (mode != pool_seg->cache_mode) &&
+	    (mode != setting_seg->cache_mode) &&
 	    lv_is_cache(lv)) {
 		if (!lv_cache_wait_for_clean(lv, &is_clean))
 			return_0;
@@ -658,11 +666,11 @@ static int _lvchange_cache(struct cmd_context *cmd,
 		}
 	}
 
-	if (mode && !cache_set_cache_mode(first_seg(lv), mode))
+	if (mode && !cache_set_cache_mode(seg, mode))
 		goto_out;
 
 	if ((name || settings) &&
-	    !cache_set_policy(first_seg(lv), name, settings))
+	    !cache_set_policy(seg, name, settings))
 		goto_out;
 
 	/* Request caller to commit and reload metadata */



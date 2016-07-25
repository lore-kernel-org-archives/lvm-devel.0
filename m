From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 25 Jul 2016 16:03:19 +0000 (UTC)
Subject: master - lvconvert: remove warnings about deprecated split option
Message-ID: <20160725160319.A6990606DB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b1daa248ffdc473e016b9694c1f85a827334c89
Commit:        7b1daa248ffdc473e016b9694c1f85a827334c89
Parent:        70bad99894003c9e2fcec5db2b1f39cf09f75077
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 25 11:01:56 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 25 11:01:56 2016 -0500

lvconvert: remove warnings about deprecated split option

A warning seems too severe for this message, so leave it
out until there's a better idea.
---
 tools/lvconvert.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5d29cc4..c31a8a3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4047,10 +4047,8 @@ static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv
 	if (arg_is_set(cmd, splitcache_ARG))
 		return _convert_thin_pool_splitcache(cmd, lv, lp);
 
-	if (arg_is_set(cmd, split_ARG)) {
-		log_warn("WARNING: Using --splitcache which has replaced the --split option.");
+	if (arg_is_set(cmd, split_ARG))
 		return _convert_thin_pool_splitcache(cmd, lv, lp);
-	}
 
 	if (arg_is_set(cmd, uncache_ARG))
 		return _convert_thin_pool_uncache(cmd, lv, lp);
@@ -4084,10 +4082,8 @@ static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume
 	if (arg_is_set(cmd, splitcache_ARG))
 		return _convert_cache_volume_splitcache(cmd, lv, lp);
 
-	if (arg_is_set(cmd, split_ARG)) {
-		log_warn("WARNING: Using --splitcache which has replaced the --split option.");
+	if (arg_is_set(cmd, split_ARG))
 		return _convert_cache_volume_splitcache(cmd, lv, lp);
-	}
 
 	if (arg_is_set(cmd, uncache_ARG))
 		return _convert_cache_volume_uncache(cmd, lv, lp);
@@ -4117,10 +4113,8 @@ static int _convert_cache_pool(struct cmd_context *cmd, struct logical_volume *l
 	if (arg_is_set(cmd, splitcache_ARG))
 		return _convert_cache_pool_splitcache(cmd, lv, lp);
 
-	if (arg_is_set(cmd, split_ARG)) {
-		log_warn("WARNING: Using --splitcache which has replaced the --split option.");
+	if (arg_is_set(cmd, split_ARG))
 		return _convert_cache_pool_splitcache(cmd, lv, lp);
-	}
 
 	/* FIXME: swapping the cache pool metadata LV needs a specific option like --swapmetadata */
 	if (arg_is_set(cmd, poolmetadata_ARG))



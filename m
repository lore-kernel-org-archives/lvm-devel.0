From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 30 Jul 2016 14:58:44 +0000 (UTC)
Subject: master - lvconvert: Rely upon lp->thin and lp->cache.
Message-ID: <20160730145844.25A0A6111B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ce958bc5ea2827fdb945b2177616e8f253486a1
Commit:        1ce958bc5ea2827fdb945b2177616e8f253486a1
Parent:        48d9c46daabd73c694404c48d3820c2a229f1ad2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 30 15:56:17 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 30 15:58:09 2016 +0100

lvconvert: Rely upon lp->thin and lp->cache.

---
 tools/lvconvert.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 822df53..ed3bd88 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4072,7 +4072,7 @@ static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv
 	if (arg_is_set(cmd, uncache_ARG))
 		return _convert_thin_pool_uncache(cmd, lv, lp);
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE) || arg_is_set(cmd, cache_ARG))
+	if (lp->cache)
 		return _convert_thin_pool_cache(cmd, lv, lp);
 
 	if (arg_is_set(cmd, repair_ARG))
@@ -4216,10 +4216,10 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) || arg_is_set(cmd, snapshot_ARG))
 		return _convert_raid_snapshot(cmd, lv, lp);
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN) || arg_is_set(cmd, thin_ARG))
+	if (lp->thin)
 		return _convert_raid_thin(cmd, lv, lp);
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE) || arg_is_set(cmd, cache_ARG))
+	if (lp->cache)
 		return _convert_raid_cache(cmd, lv, lp);
 
 	/* Using --thinpool is ambiguous and not preferred. */
@@ -4273,10 +4273,10 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) || arg_is_set(cmd, snapshot_ARG))
 		return _convert_striped_snapshot(cmd, lv, lp);
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN) || lp->thin)
+	if (lp->thin)
 		return _convert_striped_thin(cmd, lv, lp);
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE) || arg_is_set(cmd, cache_ARG))
+	if (lp->cache)
 		return _convert_striped_cache(cmd, lv, lp);
 
 	/* Using --thinpool is ambiguous and not preferred. */



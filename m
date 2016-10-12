From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Oct 2016 09:18:55 +0000 (UTC)
Subject: master - lvconvert: still use strcmp for now
Message-ID: <20161012091855.3D62261B98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=900e899739b95bcf5a429fc46dd6f16a4b7b50d0
Commit:        900e899739b95bcf5a429fc46dd6f16a4b7b50d0
Parent:        8859d4508a9862af25b4c7d75aee84367b19da79
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 12 11:12:48 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 12 11:18:23 2016 +0200

lvconvert: still use  strcmp for now

Keep for now function logic making its decision on string content.
We need bigger patch converting all things to bit-checks later.
This needs however bigger refactoring.
So this commit reverts some changes from:
c8b6c130158e1cc1a639afc21f5fd6306286fdb3
---
 tools/lvconvert.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c3ec1a6..772c268 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4180,7 +4180,7 @@ static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume
 	if (arg_is_set(cmd, splitmirrors_ARG))
 		return _convert_cache_volume_splitmirrors(cmd, lv, lp);
 
-	if (segtype_is_thin_pool(lp->segtype) ||
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) ||
 	    arg_is_set(cmd, thinpool_ARG))
 		return _convert_cache_volume_thin_pool(cmd, lv, lp);
 
@@ -4340,11 +4340,11 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 		if (lp->cache)
 			return _convert_raid_cache(cmd, lv, lp);
 
-		if (segtype_is_thin_pool(lp->segtype) ||
+		if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) ||
 		    arg_is_set(cmd, thinpool_ARG))
 			return _convert_raid_thin_pool(cmd, lv, lp);
 
-		if (segtype_is_cache_pool(lp->segtype) ||
+		if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL)  ||
 		    arg_is_set(cmd, cachepool_ARG))
 			return _convert_raid_cache_pool(cmd, lv, lp);
 	}
@@ -4365,7 +4365,7 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->merge)
 		return _convert_striped_merge(cmd, lv, lp);
 
-	if (lp->snapshot || segtype_is_snapshot(lp->segtype))
+	if (lp->snapshot || !strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT))
 		return _convert_striped_snapshot(cmd, lv, lp);
 
 	if (lp->thin)
@@ -4374,11 +4374,11 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->cache)
 		return _convert_striped_cache(cmd, lv, lp);
 
-	if (segtype_is_thin_pool(lp->segtype) ||
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) ||
 	    arg_is_set(cmd, thinpool_ARG))
 		return _convert_striped_thin_pool(cmd, lv, lp);
 
-	if (segtype_is_cache_pool(lp->segtype) ||
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) ||
 	    arg_is_set(cmd, cachepool_ARG))
 		return _convert_striped_cache_pool(cmd, lv, lp);
 



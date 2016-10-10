From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Mon, 10 Oct 2016 15:33:02 +0000 (UTC)
Subject: master - lvconvert: certain repair of cache raid volumes fails "Cannot convert internal LV"
Message-ID: <20161010153302.B901A60B22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=088b3d036a73a7d947f6e9b12e8fad8a9f40d97f
Commit:        088b3d036a73a7d947f6e9b12e8fad8a9f40d97f
Parent:        a8bb8dfb08d38cfda5493ca9d35d1cb3bf2d32bf
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Oct 10 17:29:40 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Oct 10 17:31:29 2016 +0200

lvconvert: certain repair of cache raid volumes fails "Cannot convert internal LV"

In case a RAID orig LV is being cached and fails, repair is impossible because
"lvconvert --repair" gets rejected.

Fix by allowing repair on cache orig RAID LVs and
"lvconvert --replace/--mirrors/--type {raid*|mirror|striped|linear}" as well.

Allow the same lvconvert actions on any cache pool and metadata RAID SubLVs.

Resolves: rhbz1380532
---
 tools/lvconvert.c |  113 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 71 insertions(+), 42 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2f38c9d..daa2af4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -236,6 +236,12 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		return 0;
 	}
 
+	/*
+	 * FIXME: avoid this distinct validation out of scope of _convert_*()
+	 *
+ 	 *        We should not rely on namespace here any more!
+ 	 *        It is the duty of lvcreate/lvrename to avoid reserved names.
+ 	 */
 	if (!lp->merge_mirror &&
 	    !lp->repair &&
 	    !lp->keep_mimages &&
@@ -243,6 +249,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	    !strstr(lp->lv_name, "_tmeta") &&
 	    !strstr(lp->lv_name, "_cdata") &&
 	    !strstr(lp->lv_name, "_cmeta") &&
+	    !strstr(lp->lv_name, "_corig") &&
 	    !apply_lvname_restrictions(lp->lv_name))
 		return_0;
 
@@ -4262,42 +4269,48 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 			 struct lvconvert_params *lp)
 {
+	/* Permitted convert options on visible or hidden RaidLVs */
+	const char *permitted_options = lv_is_visible(lv) ?
+	  	"  --mirrors\n"
+	  	"  --splitmirrors\n"
+	  	"  --merge\n"
+	  	"  --repair\n"
+	  	"  --replace\n"
+	  	"  --type snapshot\n"
+	  	"  --type thin\n"
+	  	"  --type cache\n"
+	  	"  --type thin-pool\n"
+	  	"  --type cache-pool\n"
+	  	"  --type raid*\n"
+	  	"  --type mirror\n"
+	  	"  --type striped\n"
+	  	"  --type linear\n"
+		:
+	  	"  --mirrors\n"
+	  	"  --repair\n"
+	  	"  --replace\n"
+	  	"  --type raid*\n"
+	  	"  --type mirror\n"
+	  	"  --type striped\n"
+	  	"  --type linear\n";
+
+	/* Applicable to any hidden _or_ visible LVs. */
 	if (arg_is_set(cmd, mirrors_ARG))
 		return _convert_raid_number(cmd, lv, lp);
 
-	if (arg_is_set(cmd, splitmirrors_ARG))
-		return _convert_raid_splitmirrors(cmd, lv, lp);
-
-	if (arg_is_set(cmd, merge_ARG))
-		return _convert_raid_merge(cmd, lv, lp);
-
 	if (arg_is_set(cmd, repair_ARG))
 		return _convert_raid_repair(cmd, lv, lp);
 
 	if (arg_is_set(cmd, replace_ARG))
 		return _convert_raid_replace(cmd, lv, lp);
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) || arg_is_set(cmd, snapshot_ARG))
-		return _convert_raid_snapshot(cmd, lv, lp);
-
-	if (lp->thin)
-		return _convert_raid_thin(cmd, lv, lp);
-
-	if (lp->cache)
-		return _convert_raid_cache(cmd, lv, lp);
-
-	/* Using --thinpool is ambiguous and not preferred. */
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) || arg_is_set(cmd, thinpool_ARG))
-		return _convert_raid_thin_pool(cmd, lv, lp);
-
-	/* Using --cachepool is ambiguous and not preferred. */
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) || arg_is_set(cmd, cachepool_ARG))
-		return _convert_raid_cache_pool(cmd, lv, lp);
+	if (segtype_is_raid(lp->segtype)) {
+		/* Only --type allowed on hidden RaidLV. */
+		if (!lv_is_visible(lv) && !arg_is_set(cmd, type_ARG))
+			goto out;
 
-	if (segtype_is_raid(lp->segtype))
 		return _convert_raid_raid(cmd, lv, lp);
+	}
 
 	if (segtype_is_mirror(lp->segtype))
 		return _convert_raid_mirror(cmd, lv, lp);
@@ -4308,24 +4321,39 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (_linear_type_requested(lp->type_str))
 		return _convert_raid_linear(cmd, lv, lp);
 
-	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
+	/* Applicable to visible LVs only. */
+	if (lv_is_visible(lv)) {
+		if (arg_is_set(cmd, splitmirrors_ARG))
+			return _convert_raid_splitmirrors(cmd, lv, lp);
+
+		if (arg_is_set(cmd, merge_ARG))
+			return _convert_raid_merge(cmd, lv, lp);
+
+		if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) || arg_is_set(cmd, snapshot_ARG))
+			return _convert_raid_snapshot(cmd, lv, lp);
+
+		if (lp->thin)
+			return _convert_raid_thin(cmd, lv, lp);
+
+		if (lp->cache)
+			return _convert_raid_cache(cmd, lv, lp);
+
+		/* Using --thinpool is ambiguous and not preferred. */
+
+		if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) || arg_is_set(cmd, thinpool_ARG))
+			return _convert_raid_thin_pool(cmd, lv, lp);
+
+		/* Using --cachepool is ambiguous and not preferred. */
+
+		if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) || arg_is_set(cmd, cachepool_ARG))
+			return _convert_raid_cache_pool(cmd, lv, lp);
+
+		/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
+	}
 
+out:
 	log_error("Operation not permitted on raid LV %s.", display_lvname(lv));
-	log_error("Operations permitted on a raid LV are:\n"
-		  "  --mirrors\n"
-		  "  --splitmirrors\n"
-		  "  --merge\n"
-		  "  --repair\n"
-		  "  --replace\n"
-		  "  --type snapshot\n"
-		  "  --type thin\n"
-		  "  --type cache\n"
-		  "  --type thin-pool\n"
-		  "  --type cache-pool\n"
-		  "  --type raid*\n"
-		  "  --type mirror\n"
-		  "  --type striped\n"
-		  "  --type linear\n");
+	log_error("Operations permitted on a raid LV are:\n%s", permitted_options);
 	return 0;
 }
 
@@ -4440,7 +4468,8 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		    !lv_is_thin_pool_metadata(lv) &&
 		    !lv_is_thin_pool_data(lv) &&
 		    !lv_is_used_cache_pool(lv) &&
-		    !lv_is_raid_image(lv)) {
+		    !lv_is_mirrored(lv) &&
+		    !lv_is_raid(lv)) {
 			log_error("Cannot convert internal LV %s.", display_lvname(lv));
 			ret = 0;
 			goto out;



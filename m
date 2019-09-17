From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 17 Sep 2019 05:35:06 -0400
Subject: stable-2.02 - lvconvert: improve validation thin and cache pool conversion
Message-ID: <201909170935.x8H9Z6cw020679@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e147786bac52fea240955329963c9eed0eebfb18
Commit:        e147786bac52fea240955329963c9eed0eebfb18
Parent:        1c07c5482916d493caf951cac5b5b22af0620724
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 6 18:09:40 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 17 11:33:53 2019 +0200

lvconvert: improve validation thin and cache pool conversion

Limit convertible LVs to thin-pool and cache-pools.
Also fix return code on  interal error path to return ECMD_FAILED.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 48 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index afdf523..8a597ba 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.187 - 
 ===================================
+  Enhance validation for thin and cache pool conversion and swapping.
 
 Version 2.02.186 - 27th August 2019
 ===================================
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8a07a84..31ca5a1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4304,24 +4304,66 @@ static int _lvconvert_to_pool_or_swap_metadata_single(struct cmd_context *cmd,
 	struct dm_list *use_pvh = NULL;
 	int to_thinpool = 0;
 	int to_cachepool = 0;
+	int lvt_enum = get_lvt_enum(lv);
+	struct lv_type *lvtype;
 
 	switch (cmd->command->command_enum) {
 	case lvconvert_to_thinpool_or_swap_metadata_CMD:
+		if (lv_is_cache(lv))
+			/* For cached LV check the cache origin LV type */
+			lvt_enum = get_lvt_enum(seg_lv(first_seg(lv), 0));
 		to_thinpool = 1;
 		break;
 	case lvconvert_to_cachepool_or_swap_metadata_CMD:
+		if (lv_is_cache(lv))
+			goto_bad; /* Cache over cache is not supported */
 		to_cachepool = 1;
 		break;
 	default:
-		log_error(INTERNAL_ERROR "Invalid lvconvert pool command");
-		return 0;
-	};
+		log_error(INTERNAL_ERROR "Invalid lvconvert pool command.");
+		return ECMD_FAILED;
+	}
+
+	switch (lvt_enum) {
+	case thinpool_LVT:
+		if (!to_thinpool)
+			goto_bad; /* can't accept cache-pool */
+		break; /* swap thin-pool */
+	case cachepool_LVT:
+		if (!to_cachepool)
+			goto_bad; /* can't accept thin-pool */
+		break; /* swap cache-pool */
+	case linear_LVT:
+	case raid_LVT:
+	case striped_LVT:
+	case zero_LVT:
+		break;
+	default:
+bad:
+		lvtype = get_lv_type(lvt_enum);
+		log_error("LV %s with type %s cannot be used as a %s pool LV.",
+			  display_lvname(lv), lvtype ? lvtype->name : "unknown",
+			  to_thinpool ? "thin" : "cache");
+		return ECMD_FAILED;
+	}
 
 	if (lv_is_origin(lv)) {
 		log_error("Cannot convert logical volume %s under snapshot.",
 			  display_lvname(lv));
-		return 0;
-	};
+		return ECMD_FAILED;
+	}
+
+	if (!lv_is_visible(lv)) {
+		log_error("Can't convert internal LV %s.",
+			  display_lvname(lv));
+		return ECMD_FAILED;
+	}
+
+	if (lv_is_locked(lv)) {
+		log_error("Can't convert locked LV %s.",
+			  display_lvname(lv));
+		return ECMD_FAILED;
+	}
 
 	if (cmd->position_argc > 1) {
 		/* First pos arg is required LV, remaining are optional PVs. */



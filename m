From: David Teigland <teigland@redhat.com>
Date: Tue, 2 Sep 2014 16:59:05 -0500
Subject: [PATCH] lvconvert: mirrors and snapshots do not work with cache
Message-ID: <20140902215905.GI374@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Refuse these:
lvconvert -m1 <cache_type_lv>
lvconvert -s <lv> <cache_type_lv>

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1e106cf3abf8..819c3aea6627 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1823,6 +1823,11 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (lv_is_cache_type(lv)) {
+		log_error("Mirrors of cache LVs are not yet supported");
+		return 0;
+	}
+
 	/* Adjust mimage and/or log count */
 	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
 					     &old_mimage_count, &old_log_count,
@@ -2109,6 +2114,11 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (lv_is_cache_type(lv)) {
+		log_error("Cache types are not yet supported with snapshots.");
+		return 0;
+	}
+
 	if (!(org = find_lv(lv->vg, lp->origin_lv_name))) {
 		log_error("Couldn't find origin volume %s.", lp->origin_lv_name);
 		return 0;
-- 
1.8.3.1



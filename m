From: David Teigland <teigland@redhat.com>
Date: Tue, 2 Sep 2014 16:35:12 -0500
Subject: [PATCH] lvconvert: require pool arg to match thin or cache
Message-ID: <20140902213512.GH374@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A --thinpool arg should not be a cache pool, and
a --cachepool arg should not be a thin pool.
---
 tools/lvconvert.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ba7c4bad29b4..1e106cf3abf8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2867,6 +2867,16 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			return 0;
 		}
 
+		if (arg_str_value(cmd, cachepool_ARG, NULL) && lv_is_thin_pool(pool_lv)) {
+			log_error("Error: cachepool arg is a thin pool");
+			return 0;
+		}
+
+		if (arg_str_value(cmd, thinpool_ARG, NULL) && lv_is_cache_pool(pool_lv)) {
+			log_error("Error: thinpool arg is a cache pool");
+			return 0;
+		}
+
 		/* FIXME cache pool */
 		if (lv_is_thin_pool(pool_lv) && pool_is_active(pool_lv)) {
 			/* If any volume referencing pool active - abort here */
-- 
1.8.3.1



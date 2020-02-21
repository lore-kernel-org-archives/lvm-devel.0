From: David Teigland <teigland@sourceware.org>
Date: Fri, 21 Feb 2020 13:43:19 -0500
Subject: master - writecache: allow removing wcorig lv
Message-ID: <202002211843.01LIhJiW019261@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81d03330670f392cfe938d8bb12df2ed4c30f2d0
Commit:        81d03330670f392cfe938d8bb12df2ed4c30f2d0
Parent:        2284f845b0328df97dfef6200905b3b462cd3cce
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 21 12:40:42 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 21 12:41:52 2020 -0600

writecache: allow removing wcorig lv

like removing corig
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3604a63..3090a93 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6638,7 +6638,7 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 		return 0;
 	}
 
-	if (lv_is_cache_origin(lv)) {
+	if (lv_is_cache_origin(lv) || lv_is_writecache_origin(lv)) {
 		if (!_lv_remove_segs_using_this_lv(cmd, lv, force, level, "cache origin"))
 			return_0;
 		/* Removal of cache LV also removes caching origin */




From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 22:01:52 +0000 (UTC)
Subject: master - cleanup: smaller timeout
Message-ID: <20160426220152.2A3A760971@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c81005dcc46bc55d0d4e5094f6ef99e36cecd486
Commit:        c81005dcc46bc55d0d4e5094f6ef99e36cecd486
Parent:        07d92322c13e942b8a47b4370a82b70d33a6f0c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 26 23:59:20 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 26 23:59:20 2016 +0200

cleanup: smaller timeout

1s -> 0.5s
Also indent fix.
---
 lib/metadata/cache_manip.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index bf3d405..e998670 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -314,10 +314,11 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 			break;
 
 		if (cleaner_policy) {
-		    log_print_unless_silent(FMTu64 " blocks must still be flushed.",
-					    dirty_blocks);
-		    sleep(1);
-                    continue;
+			log_print_unless_silent(FMTu64 " blocks must still be flushed.",
+						dirty_blocks);
+			/* TODO: Use centralized place */
+			usleep(500000);
+			continue;
 		}
 
 		/* Switch to cleaner policy to flush the cache */
@@ -326,7 +327,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 		cache_seg->cleaner_policy = 1;
 		/* Reaload kernel with "cleaner" policy */
 		if (!lv_update_and_reload_origin(cache_lv))
-		    return_0;
+			return_0;
 	}
 
 	*is_clean = 1;



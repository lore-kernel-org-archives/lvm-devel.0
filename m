From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 22 Jun 2017 14:18:10 -0400
Subject: master - cache: make syncing abortable by user
Message-ID: <201706221818.v5MIIAu9006586@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca9e6cec619e242fe6283fc5acbf773f763c1f5a
Commit:        ca9e6cec619e242fe6283fc5acbf773f763c1f5a
Parent:        2df9a786845af2ce34cb3942dc2b16342e359a2c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 22 17:08:47 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 22 20:11:43 2017 +0200

cache: make syncing abortable by user

When user runs command like 'lvconvert --splitcache' the operation
might be actually either slow or not making any progress in kernel,
so lets give user a chance to abort such operation.

When user press 'Ctrl+C' device table is restored to pre-flushing state.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |   18 ++++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e60380a..25571cc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Support aborting of flushing cache LV.
   Reenable conversion of data and metadata thin-pool volumes to raid.
   Improve raid status reporting with lvs.
   No longer necessary to '--force' a repair for RAID1
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index e7da899..cc3482b 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -22,6 +22,7 @@
 #include "activate.h"
 #include "defaults.h"
 #include "lv_alloc.h"
+#include "lvm-signal.h"
 
 /* https://github.com/jthornber/thin-provisioning-tools/blob/master/caching/cache_metadata_size.cc */
 #define DM_TRANSACTION_OVERHEAD		4096  /* KiB */
@@ -431,6 +432,20 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 
 	//FIXME: use polling to do this...
 	for (;;) {
+		sigint_allow();
+		sigint_restore();
+		if (sigint_caught()) {
+			sigint_clear();
+			log_error("Flushing of %s aborted.", display_lvname(cache_lv));
+			if (cache_seg->cleaner_policy) {
+				cache_seg->cleaner_policy = 0;
+				/* Restore normal table */
+				if (!lv_update_and_reload(cache_lv))
+					stack;
+			}
+			return 0;
+		}
+
 		if (!lv_cache_status(cache_lv, &status))
 			return_0;
 
@@ -452,9 +467,12 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 
 		log_print_unless_silent("Flushing " FMTu64 " blocks for cache %s.",
 					dirty_blocks, display_lvname(cache_lv));
+
 		if (cleaner_policy) {
 			/* TODO: Use centralized place */
+			sigint_allow();
 			usleep(500000);
+			sigint_restore();
 			continue;
 		}
 



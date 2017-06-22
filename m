From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 22 Jun 2017 14:18:16 -0400
Subject: master - cache: drop usage of origin_only
Message-ID: <201706221818.v5MIIGEi006596@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=58a9f88b8c021a5e056b883053f257f1a898adf7
Commit:        58a9f88b8c021a5e056b883053f257f1a898adf7
Parent:        ca9e6cec619e242fe6283fc5acbf773f763c1f5a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 22 17:12:27 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 22 20:14:31 2017 +0200

cache: drop usage of origin_only

Since cache LV can be a stacked device, there is no real reason
trying to use slight optimised tree for origin_only cache reload
(it could be even wrongly implemented in this case).

We can easily go with stardard tree load here.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 25571cc..2f1ec8a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Avoid using origin_only manipulation with cached device.
   Support aborting of flushing cache LV.
   Reenable conversion of data and metadata thin-pool volumes to raid.
   Improve raid status reporting with lvs.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index cc3482b..057d043 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -485,7 +485,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 		/* Switch to cleaner policy to flush the cache */
 		cache_seg->cleaner_policy = 1;
 		/* Reload cache volume with "cleaner" policy */
-		if (!lv_update_and_reload_origin(cache_lv))
+		if (!lv_update_and_reload(cache_lv))
 			return_0;
 
 		if (!sync_local_dev_names(cache_lv->vg->cmd)) {



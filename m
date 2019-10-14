From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:21:49 -0400
Subject: master - cache: reload only when switched to cleaner policy
Message-ID: <201910141321.x9EDLn0v018729@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=36944e1009e932902269d3eab547e0b19da13468
Commit:        36944e1009e932902269d3eab547e0b19da13468
Parent:        ddaf2002c94a33863ef7adf69ad4cdffcfbd73c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 12 11:12:11 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:14:22 2019 +0200

cache: reload only when switched to cleaner policy

Reload cache target only when lvm2 reload table with
cache with clearer policy.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d530d9f..bb806ac 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Reload cleanered cache DM only with cleaner policy.
   Fix cmd return when zering of cachevol fails.
   Extend lvs to show all VDO properties.
   Preserve VDO write policy with vdopool.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 65589f7..e4cd345 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -545,7 +545,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	 * TODO: add check if extra suspend resume is necessary
 	 * ATM this is workaround for missing cache sync when cache gets clean
 	 */
-	if (1) {
+	if (cleaner_policy) {
 		if (!lv_refresh_suspend_resume(lock_lv))
 			return_0;
 



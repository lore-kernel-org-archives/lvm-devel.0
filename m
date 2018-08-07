From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Aug 2018 12:01:15 -0400
Subject: master - cache: drop metadata_format validation
Message-ID: <201808071601.w77G1F2L026505@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c34291e3bf61cc2644389cbce77e9953f67a843a
Commit:        c34291e3bf61cc2644389cbce77e9953f67a843a
Parent:        9adae653e98256901897e65aa349bb83a9f9ad5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 7 10:33:19 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 7 17:57:00 2018 +0200

cache: drop metadata_format validation

Allow to use any combination of cache metadata format for policy.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    5 -----
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2c5b5d3..2cf7969 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Do not pair cache policy and cache metadata format.
   lvconvert: reject conversions on raid1 LVs with split tracked SubLVs
   lvconvert: reject conversions on raid1 split tracked SubLVs
   Add basic creation support for VDO target.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 4132e2f..5ba353c 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -842,15 +842,10 @@ int cache_set_metadata_format(struct lv_segment *seg, cache_metadata_format_t fo
 
 	/*
 	 * If policy is unselected, but format 2 is selected, policy smq is enforced.
-	 * ATM no other then smq & cleaner policy is allowed to select format 2.
 	 */
 	if (!seg->policy_name) {
 		if (format == CACHE_METADATA_FORMAT_2)
 			seg->policy_name = "smq";
-	} else if (strcmp(seg->policy_name, "smq") &&
-		   strcmp(seg->policy_name, "cleaner")) {
-		seg->cache_metadata_format = CACHE_METADATA_FORMAT_1;
-		return 1;
 	}
 
 	/* Check if we need to search for configured cache metadata format */



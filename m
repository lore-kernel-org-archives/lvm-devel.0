From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Aug 2018 12:06:50 -0400
Subject: 2018-06-01-stable - cache: drop metadata_format validation
Message-ID: <201808071606.w77G6oTX028654@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc96eea0298e537bb6299a3ecc9c68737cae2e68
Commit:        cc96eea0298e537bb6299a3ecc9c68737cae2e68
Parent:        5f648406b0f2e322851fce36b062a298cb3d6736
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 7 10:33:19 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 7 18:04:14 2018 +0200

cache: drop metadata_format validation

Allow to use any combination of cache metadata format for policy.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    5 -----
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5e8b00d..e31aca2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.182 - 
 ==============================
+  Do not pair cache policy and cache metadata format.
 
 Version 2.02.181 - 01 August 2018
 =================================
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index c15f117..8376bfb 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -843,15 +843,10 @@ int cache_set_metadata_format(struct lv_segment *seg, cache_metadata_format_t fo
 
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



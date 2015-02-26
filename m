From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Feb 2015 19:45:16 +0000 (UTC)
Subject: master - mirror: Avoid region size compiler warning.
Message-ID: <20150226194516.4155C6118E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb727a1cccc1518a2b193c92ad5bff122b9220c9
Commit:        cb727a1cccc1518a2b193c92ad5bff122b9220c9
Parent:        66d074e913d61bd9e5fa7cc67f25f90b4608b071
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Feb 26 19:45:55 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 26 19:45:55 2015 +0000

mirror: Avoid region size compiler warning.

format ???%u??? expects type ???unsigned int???, but argument 7 has type ???uint64_t???
---
 lib/metadata/mirror.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 3f2fa2f..df91002 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -193,9 +193,7 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 		 * This code should be removed when the CPG restriction is
 		 * lifted.
 		 */
-		region_min = extents;
-		region_min *= extent_size;
-		region_min /= CMIRROR_REGION_COUNT_LIMIT;
+		region_min = extents * extent_size / CMIRROR_REGION_COUNT_LIMIT;
 		region_min_pow2 = 1;
 		while (region_min_pow2 < region_min)
 			region_min_pow2 *= 2;
@@ -203,11 +201,11 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 		if (region_size < region_min_pow2) {
 			if (internal)
 				log_print_unless_silent("Increasing mirror region size from %"
-							PRIu32 " to %" PRIu32 " sectors.",
+							PRIu32 " to %" PRIu64 " sectors.",
 							region_size, region_min_pow2);
 			else
 				log_verbose("Increasing mirror region size from %"
-					    PRIu32 " to %" PRIu32 " sectors.",
+					    PRIu32 " to %" PRIu64 " sectors.",
 					    region_size, region_min_pow2);
 			region_size = region_min_pow2;
 		}



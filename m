From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Feb 2015 19:48:43 +0000 (UTC)
Subject: master - mirror: Explicit cast in region_size_max
Message-ID: <20150226194843.BA41B60DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a432066c7c52f59b1d38fbef3896b3ff0c50100f
Commit:        a432066c7c52f59b1d38fbef3896b3ff0c50100f
Parent:        cb727a1cccc1518a2b193c92ad5bff122b9220c9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Feb 26 19:49:25 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 26 19:49:25 2015 +0000

mirror: Explicit cast in region_size_max

---
 lib/metadata/mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index df91002..028de84 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -193,7 +193,7 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 		 * This code should be removed when the CPG restriction is
 		 * lifted.
 		 */
-		region_min = extents * extent_size / CMIRROR_REGION_COUNT_LIMIT;
+		region_min = (uint64_t) extents * extent_size / CMIRROR_REGION_COUNT_LIMIT;
 		region_min_pow2 = 1;
 		while (region_min_pow2 < region_min)
 			region_min_pow2 *= 2;



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:46 +0000 (UTC)
Subject: master - cleanup: use 64bit ulongs
Message-ID: <20150508131646.AB31D60E32@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed2a08bf25e3b4e6a88c55402ab5dc11061ad68e
Commit:        ed2a08bf25e3b4e6a88c55402ab5dc11061ad68e
Parent:        5232fd13f362334286ca2076db99a0063919341c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 11:17:36 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 15:15:10 2015 +0200

cleanup: use 64bit ulongs

Use 64bit arithmetics for all numbers (Coverity).
---
 lib/metadata/mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 028de84..a0418ce 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -164,7 +164,7 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 	uint64_t region_max;
 	uint64_t region_min, region_min_pow2;
 
-	region_max = (1 << (ffs((int)extents) - 1)) * (uint64_t) (1 << (ffs((int)extent_size) - 1));
+	region_max = (1UL << (ffs((int)extents) - 1)) * (1UL << (ffs((int)extent_size) - 1));
 
 	if (region_max < UINT32_MAX && region_size > region_max) {
 		region_size = (uint32_t) region_max;



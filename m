From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 May 2015 20:54:07 +0000 (UTC)
Subject: master - mirror: use proper 64bit constants
Message-ID: <20150515205407.1766E60781@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e102ecbd9b6efc36e09c84b8f0882d993038f84
Commit:        9e102ecbd9b6efc36e09c84b8f0882d993038f84
Parent:        190e91231c7822fd7b1a3dcf0e17dd2fdf162a57
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 22:53:12 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 15 22:53:12 2015 +0200

mirror: use proper 64bit constants

ed2a08bf25e3b4e6a88c55402ab5dc11061ad68e missed to use 64bit
constants.
---
 lib/metadata/mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index ff8b657..543c00e 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -164,7 +164,7 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 	uint64_t region_max;
 	uint64_t region_min, region_min_pow2;
 
-	region_max = (1UL << (ffs((int)extents) - 1)) * (1UL << (ffs((int)extent_size) - 1));
+	region_max = (UINT64_C(1) << (ffs((int)extents) - 1)) * (UINT64_C(1) << (ffs((int)extent_size) - 1));
 
 	if (region_max < UINT32_MAX && region_size > region_max) {
 		region_size = (uint32_t) region_max;



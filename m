From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:26 +0000 (UTC)
Subject: dev-prajnoha-selout - cache: avoid expression overflow
Message-ID: <20140509065626.B91B860774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48a8cf28f751156471a3fc65650fc600cd24833c
Commit:        48a8cf28f751156471a3fc65650fc600cd24833c
Parent:        e585a6bbcf8416f5eeb6b57e0b02ca5e52f23f96
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 7 11:12:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:14:54 2014 +0200

cache: avoid expression overflow

Cast data_extents to 64bit so calculation is in 64b arithmetic.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f0c36cb..88ae713 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Use proper uint64 casting for calculation of cache metadata size.
   Better support for nesting of blocking signals.
   Use only sigaction handler and drop duplicate signal handler.
   Separate signal handling and flock code out into lib/misc.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 9a055e8..deae6f2 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -57,7 +57,7 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 	 * ... plus a good amount of padding (2x) to cover any
 	 * policy hint data that may be added in the future.
 	 */
-	min_meta_size = 16 * (data_extents * vg->extent_size);
+	min_meta_size = (uint64_t)data_extents * vg->extent_size * 16;
 	min_meta_size /= *chunk_size; /* # of Bytes we need */
 	min_meta_size *= 2;              /* plus some padding */
 	min_meta_size /= 512;            /* in sectors */



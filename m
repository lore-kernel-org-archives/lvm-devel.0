From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Nov 2014 09:05:05 +0000 (UTC)
Subject: master - coverity: fix possible integer overflow
Message-ID: <20141112090505.CD59D60223@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce8730b5080b85192af1aadea3d9e9b5333a2405
Commit:        ce8730b5080b85192af1aadea3d9e9b5333a2405
Parent:        60cc666c949ca16b1d7297eb2a3abc78dfbf3bf9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 12 10:03:27 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 12 10:03:27 2014 +0100

coverity: fix possible integer overflow

LVM2.2.02.112/lib/metadata/cache_manip.c:73: overflow_before_widen: Potentially overflowing expression "*pool_metadata_extents *vg->extent_size" with type "unsigned int" (32 bits, unsigned) is evaluated using 32-bit arithmetic, and then used in a context that expects an expression of type "uint64_t" (64 bits, unsigned).
LVM2.2.02.112/lib/activate/dev_manager.c:217: overflow_before_widen: Potentially overflowing expression "seg_status->seg->len * extent_size" with type "unsigned int" (32 bits, unsigned) is evaluated using 32-bit arithmetic, and then used in a context that expects an expression of type "uint64_t" (64 bits, unsigned).
LVM2.2.02.112/lib/activate/dev_manager.c:217: overflow_before_widen: Potentially overflowing expression "seg_status->seg->le * extent_size" with type "unsigned int" (32 bits, unsigned) is evaluated using 32-bit arithmetic, and then used in a context that expects an expression of type "uint64_t" (64 bits, unsigned).
---
 lib/activate/dev_manager.c |    4 ++--
 lib/metadata/cache_manip.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c62dcb8..a17cd25 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -217,8 +217,8 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 		do {
 			target = dm_get_next_target(dmt, target, &target_start,
 						    &target_length, &target_name, &target_params);
-			if ((seg_status->seg->le * extent_size == target_start) &&
-			    (seg_status->seg->len * extent_size == target_length)) {
+			if (((uint64_t) seg_status->seg->le * extent_size == target_start) &&
+			    ((uint64_t) seg_status->seg->len * extent_size == target_length)) {
 				params_to_process = target_params;
 				break;
 			}
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index d7813c3..27f381d 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -70,7 +70,7 @@ int update_cache_pool_params(const struct segment_type *segtype,
 {
 	uint64_t min_meta_size;
 	uint32_t extent_size = vg->extent_size;
-	uint64_t pool_metadata_size = *pool_metadata_extents * vg->extent_size;
+	uint64_t pool_metadata_size = (uint64_t) *pool_metadata_extents * vg->extent_size;
 
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE))
 		*chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;



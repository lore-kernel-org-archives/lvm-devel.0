From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 15:50:31 -0400
Subject: master - cleanup: define really uses KB
Message-ID: <201706091950.v59JoVpq010274@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db5938a4f8b5f13f5bc804f0d8e931f36dcbbef3
Commit:        db5938a4f8b5f13f5bc804f0d8e931f36dcbbef3
Parent:        5e7db7d85de7285eaee1867c73c10ee212c00631
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 21:29:34 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 21:49:19 2017 +0200

cleanup: define really uses KB

Cleanup also units for DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE define
(128MB) and update calcs for it.
---
 lib/config/defaults.h     |    2 +-
 lib/metadata/thin_manip.c |    2 +-
 liblvm/lvm_lv.c           |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 51542df..d9e19d9 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -106,7 +106,7 @@
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (DM_THIN_MAX_METADATA_SIZE / 2)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
-#define DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE (128 * 1024 * 1024) /* KB */
+#define DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE (128 * 1024) /* KB */
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY "generic"
 #define DEFAULT_THIN_POOL_CHUNK_SIZE	    64	  /* KB */
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE 512 /* KB */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 726b26b..7f7d314 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -673,7 +673,7 @@ int update_thin_pool_params(struct cmd_context *cmd,
 
 			/* Check if we should eventually use bigger chunk size */
 			while ((pool_metadata_size >
-				(DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE / SECTOR_SIZE)) &&
+				(DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE * 2)) &&
 			       (*chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE)) {
 				*chunk_size <<= 1;
 				pool_metadata_size >>= 1;
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 46fc3d9..13d6cbf 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -507,7 +507,7 @@ static int _lv_set_pool_params(struct lvcreate_params *lp,
 		pool_metadata_size = extents * vg->extent_size /
 			(lp->chunk_size * (SECTOR_SIZE / 64));
 		while ((pool_metadata_size >
-			(2 * DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE / SECTOR_SIZE)) &&
+			(DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE * 2)) &&
 		       lp->chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE) {
 			lp->chunk_size <<= 1;
 			pool_metadata_size >>= 1;



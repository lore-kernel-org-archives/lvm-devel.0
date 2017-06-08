From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Jun 2017 06:03:29 -0400
Subject: master - cleanup: rename internal define
Message-ID: <201706081003.v58A3TQY007752@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=719d0996930dfad8608c49af2f81008b6ca77cb8
Commit:        719d0996930dfad8608c49af2f81008b6ca77cb8
Parent:        39703cb48514415633bc027e49e99e1ee7c4bbb4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 2 11:18:04 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 8 11:07:18 2017 +0200

cleanup: rename internal define

More descriptive name of #define.
---
 lib/config/defaults.h     |    2 +-
 lib/metadata/thin_manip.c |    2 +-
 liblvm/lvm_lv.c           |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 65b81f1..05747fa 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -106,7 +106,7 @@
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
-#define DEFAULT_THIN_POOL_OPTIMAL_SIZE     (128 * 1024 * 1024)	/* KB */
+#define DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE (128 * 1024 * 1024) /* KB */
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY "generic"
 #define DEFAULT_THIN_POOL_CHUNK_SIZE	    64	  /* KB */
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE 512 /* KB */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index f9cd3d0..c2629ac 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -666,7 +666,7 @@ int update_thin_pool_params(struct cmd_context *cmd,
 
 			/* Check if we should eventually use bigger chunk size */
 			while ((pool_metadata_size >
-				(DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
+				(DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE / SECTOR_SIZE)) &&
 			       (*chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE)) {
 				*chunk_size <<= 1;
 				pool_metadata_size >>= 1;
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index d5ca821..46fc3d9 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -507,7 +507,7 @@ static int _lv_set_pool_params(struct lvcreate_params *lp,
 		pool_metadata_size = extents * vg->extent_size /
 			(lp->chunk_size * (SECTOR_SIZE / 64));
 		while ((pool_metadata_size >
-			(2 * DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
+			(2 * DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE / SECTOR_SIZE)) &&
 		       lp->chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE) {
 			lp->chunk_size <<= 1;
 			pool_metadata_size >>= 1;



From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 12 Feb 2010 22:54:51 -0500
Subject: [PATCH 1/3] Fix off by 512 sizes for lvm2app.
Message-ID: <1266033293-14492-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Internally we store sizes in sectors, but lvm2app exports sizes
in bytes.  We could get fancier and allow units configuration but
this fix should do for now.

Fixes rhbz561422.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.h          |    2 +-
 liblvm/lvm_lv.c                  |    2 +-
 liblvm/lvm_vg.c                  |    8 ++++----
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f8329d5..acb7b52 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -25,6 +25,7 @@
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
+#define SECTOR_SIZE ( 1L << SECTOR_SHIFT )
 #define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
 #define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 #define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 391734b..542be6e 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -28,7 +28,7 @@
 
 //#define MAX_STRIPES 128U
 //#define SECTOR_SHIFT 9L
-#define SECTOR_SIZE ( 1L << SECTOR_SHIFT )
+//#define SECTOR_SIZE ( 1L << SECTOR_SHIFT )
 //#define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
 //#define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 //#define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index d28e6bd..74950e3 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -26,7 +26,7 @@
 /* FIXME: have lib/report/report.c _disp function call lv_size()? */
 uint64_t lvm_lv_get_size(const lv_t lv)
 {
-	return lv_size(lv);
+	return SECTOR_SIZE*lv_size(lv);
 }
 
 char *lvm_lv_get_uuid(const lv_t lv)
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 9a5c239..30c7aad 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -86,7 +86,7 @@ int lvm_vg_set_extent_size(vg_t vg, uint32_t new_size)
 	if (!vg_check_write_mode(vg))
 		return -1;
 
-	if (!vg_set_extent_size(vg, new_size))
+	if (!vg_set_extent_size(vg, new_size/SECTOR_SIZE))
 		return -1;
 	return 0;
 }
@@ -256,17 +256,17 @@ uint64_t lvm_vg_is_partial(const vg_t vg)
 /* FIXME: invalid handle? return INTMAX? */
 uint64_t lvm_vg_get_size(const vg_t vg)
 {
-	return vg_size(vg);
+	return SECTOR_SIZE*vg_size(vg);
 }
 
 uint64_t lvm_vg_get_free_size(const vg_t vg)
 {
-	return vg_free(vg);
+	return SECTOR_SIZE*vg_free(vg);
 }
 
 uint64_t lvm_vg_get_extent_size(const vg_t vg)
 {
-	return vg_extent_size(vg);
+	return SECTOR_SIZE*vg_extent_size(vg);
 }
 
 uint64_t lvm_vg_get_extent_count(const vg_t vg)
-- 
1.6.0.6



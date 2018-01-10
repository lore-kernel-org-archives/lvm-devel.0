From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 10:53:22 -0500
Subject: master - libdm: Introduce dm_malloc_aligned
Message-ID: <201801101553.w0AFrM7S004708@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ea96381534360d6a893f0a48db8dd15fcb9ced33
Commit:        ea96381534360d6a893f0a48db8dd15fcb9ced33
Parent:        943b21779770f1cd93e73925e62f108e2efbd6cc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 9 20:25:43 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 15:48:03 2018 +0000

libdm: Introduce dm_malloc_aligned

---
 WHATS_NEW_DM                        |    1 +
 lib/device/dev-io.c                 |   10 ++++++++-
 lib/label/label.c                   |    1 -
 libdm/.exported_symbols.DM_1_02_147 |    1 +
 libdm/libdevmapper.h                |    3 ++
 libdm/mm/dbg_malloc.c               |   38 ++++++++++++++++++++++++++++++++++-
 6 files changed, 51 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index bcd6deb..5c6b888 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.147 - 
 =====================================
+  Introduce dm_malloc_aligned for page alignment of buffers.
 
 Version 1.02.146 - 18th December 2017
 =====================================
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 22a0d4c..ee4a0a5 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -257,6 +257,13 @@ static int _aligned_io(struct device_area *where, char *buffer,
 		/* Perform the I/O directly. */
 		return _io(where, buffer, should_write, reason);
 
+#ifndef DEBUG_MEM
+	/* Allocate a bounce buffer with an extra block */
+	if (!(bounce_buf = bounce = dm_malloc_aligned((size_t) widened.size, 0))) {
+		log_error("Bounce buffer malloc failed");
+		return 0;
+	}
+#else
 	/* Allocate a bounce buffer with an extra block */
 	if (!(bounce_buf = bounce = dm_malloc((size_t) widened.size + block_size))) {
 		log_error("Bounce buffer malloc failed");
@@ -268,6 +275,7 @@ static int _aligned_io(struct device_area *where, char *buffer,
 	 */
 	if (((uintptr_t) bounce) & mask)
 		bounce = (char *) ((((uintptr_t) bounce) + mask) & ~mask);
+#endif
 
 	/* Do we need to read into the bounce buffer? */
 	if ((!should_write || buffer_was_widened) &&
@@ -887,7 +895,7 @@ int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t r
 int dev_set(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, int value)
 {
 	size_t s;
-	char buffer[4096] __attribute__((aligned(8)));
+	char buffer[4096] __attribute__((aligned(4096)));
 
 	if (!dev_open(dev))
 		return_0;
diff --git a/lib/label/label.c b/lib/label/label.c
index 3a5c9fc..ccee95d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -318,7 +318,6 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 {
 	struct lvmcache_info *info;
 	struct find_labeller_params *flp;
-	char *readbuf = NULL;
 
 	if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 1))) {
 		log_debug_devs("Reading label from lvmcache for %s", dev_name(dev));
diff --git a/libdm/.exported_symbols.DM_1_02_147 b/libdm/.exported_symbols.DM_1_02_147
new file mode 100644
index 0000000..97f00f7
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_147
@@ -0,0 +1 @@
+dm_malloc_aligned_wrapper
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 5e77906..2438f74 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2075,6 +2075,8 @@ uint32_t dm_tree_get_cookie(struct dm_tree_node *node);
  */
 void *dm_malloc_wrapper(size_t s, const char *file, int line)
 	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
+void *dm_malloc_aligned_wrapper(size_t s, size_t a, const char *file, int line)
+	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
 void *dm_zalloc_wrapper(size_t s, const char *file, int line)
 	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
 void *dm_realloc_wrapper(void *p, unsigned int s, const char *file, int line)
@@ -2086,6 +2088,7 @@ int dm_dump_memory_wrapper(void);
 void dm_bounds_check_wrapper(void);
 
 #define dm_malloc(s) dm_malloc_wrapper((s), __FILE__, __LINE__)
+#define dm_malloc_aligned(s, a) dm_malloc_aligned_wrapper((s), (a),  __FILE__, __LINE__)
 #define dm_zalloc(s) dm_zalloc_wrapper((s), __FILE__, __LINE__)
 #define dm_strdup(s) dm_strdup_wrapper((s), __FILE__, __LINE__)
 #define dm_free(p) dm_free_wrapper(p)
diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index 0667bf3..f108e7b 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -18,7 +18,6 @@
 #ifdef VALGRIND_POOL
 #include "memcheck.h"
 #endif
-
 #include <assert.h>
 #include <stdarg.h>
 
@@ -26,6 +25,8 @@ void *dm_malloc_aux(size_t s, const char *file, int line)
         __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
 void *dm_malloc_aux_debug(size_t s, const char *file, int line)
         __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
+static void *_dm_malloc_aligned_aux(size_t s, size_t a, const char *file, int line)
+        __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
 void *dm_zalloc_aux(size_t s, const char *file, int line)
         __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
 void *dm_zalloc_aux_debug(size_t s, const char *file, int line)
@@ -286,6 +287,30 @@ void *dm_malloc_aux(size_t s, const char *file __attribute__((unused)),
 	return malloc(s);
 }
 
+/* Allocate size s with alignment a (or page size if 0) */
+static void *_dm_malloc_aligned_aux(size_t s, size_t a, const char *file __attribute__((unused)),
+				    int line __attribute__((unused)))
+{
+	void *memptr;
+	int r;
+
+	if (!a)
+		a = getpagesize();
+
+	if (s > 50000000) {
+		log_error("Huge memory allocation (size %" PRIsize_t
+			  ") rejected - metadata corruption?", s);
+		return 0;
+	}
+
+	if ((r = posix_memalign(&memptr, a, s))) {
+		log_error("Failed to allocate %" PRIsize_t " bytes aligned to %d: %s", s, a, strerror(r));
+		return 0;
+	}
+
+	return memptr;
+}
+
 void *dm_zalloc_aux(size_t s, const char *file, int line)
 {
 	void *ptr = dm_malloc_aux(s, file, line);
@@ -303,6 +328,12 @@ void *dm_malloc_wrapper(size_t s, const char *file, int line)
 	return dm_malloc_aux_debug(s, file, line);
 }
 
+void *dm_malloc_aligned_wrapper(size_t s, size_t a, const char *file, int line)
+{
+	/* FIXME Implement alignment when debugging - currently just ignored */
+	return _dm_malloc_aux_debug(s, file, line);
+}
+
 void *dm_zalloc_wrapper(size_t s, const char *file, int line)
 {
 	return dm_zalloc_aux_debug(s, file, line);
@@ -340,6 +371,11 @@ void *dm_malloc_wrapper(size_t s, const char *file, int line)
 	return dm_malloc_aux(s, file, line);
 }
 
+void *dm_malloc_aligned_wrapper(size_t s, size_t a, const char *file, int line)
+{
+	return _dm_malloc_aligned_aux(s, a, file, line);
+}
+
 void *dm_zalloc_wrapper(size_t s, const char *file, int line)
 {
 	return dm_zalloc_aux(s, file, line);



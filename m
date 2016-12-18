From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 21:10:33 +0000 (UTC)
Subject: master - libdm: add dm_stats_bind_from_fd()
Message-ID: <20161218211033.7516660D37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c90e9392e47a04f0d89c8ab0e0dca7fe9de00143
Commit:        c90e9392e47a04f0d89c8ab0e0dca7fe9de00143
Parent:        009b711834d26610d23d14bd8b7540eb69c836a7
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 14:40:57 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 20:47:17 2016 +0000

libdm: add dm_stats_bind_from_fd()

dmsetup already has a version of this function, and dmfilemapd will
need it too: move it to libdevmapper to avoid copying it around.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_138 |    1 +
 libdm/libdevmapper.h                |   10 ++++++++++
 libdm/libdm-stats.c                 |   19 +++++++++++++++++++
 tools/dmsetup.c                     |   20 +-------------------
 5 files changed, 32 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d57ddd7..3f9eeac 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Add dm_stats_bind_from_fd() to bind a stats handle from a file descriptor.
   Do not try call callback when reverting activation on error path.
   Fix file mapping for extents with physically adjacent extents.
   Validation vsnprintf result in runtime translate of dm_log (1.02.136).
diff --git a/libdm/.exported_symbols.DM_1_02_138 b/libdm/.exported_symbols.DM_1_02_138
index 7535829..08f936f 100644
--- a/libdm/.exported_symbols.DM_1_02_138
+++ b/libdm/.exported_symbols.DM_1_02_138
@@ -1,3 +1,4 @@
 dm_bit_get_last
 dm_bit_get_prev
 dm_bitset_parse_list
+dm_stats_bind_from_fd
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ed46795..363cf8e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -518,6 +518,16 @@ int dm_stats_bind_name(struct dm_stats *dms, const char *name);
 int dm_stats_bind_uuid(struct dm_stats *dms, const char *uuid);
 
 /*
+ * Bind a dm_stats handle to the device backing the file referenced
+ * by the specified file descriptor.
+ *
+ * File descriptor fd must reference a regular file, open for reading,
+ * in a local file system, backed by a device-mapper device, that
+ * supports the FIEMAP ioctl, and that returns data describing the
+ * physical location of extents.
+ */
+int dm_stats_bind_from_fd(struct dm_stats *dms, int fd);
+/*
  * Test whether the running kernel supports the precise_timestamps
  * feature. Presence of this feature also implies histogram support.
  * The library will check this call internally and fails any attempt
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 3978244..6e79a09 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -16,6 +16,7 @@
  */
 
 #include "dmlib.h"
+#include "kdev_t.h"
 
 #include "math.h" /* log10() */
 
@@ -452,6 +453,24 @@ int dm_stats_bind_uuid(struct dm_stats *dms, const char *uuid)
 	return 1;
 }
 
+int dm_stats_bind_from_fd(struct dm_stats *dms, int fd)
+{
+        int major, minor;
+        struct stat buf;
+
+        if (fstat(fd, &buf)) {
+                log_error("fstat failed for fd %d.", fd);
+                return 0;
+        }
+
+        major = (int) MAJOR(buf.st_dev);
+        minor = (int) MINOR(buf.st_dev);
+
+        if (!dm_stats_bind_devno(dms, major, minor))
+                return_0;
+        return 1;
+}
+
 static int _stats_check_precise_timestamps(const struct dm_stats *dms)
 {
 	/* Already checked? */
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 3f2c619..fabb183 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4640,24 +4640,6 @@ static int _bind_stats_device(struct dm_stats *dms, const char *name)
 	return 1;
 }
 
-static int _bind_stats_from_fd(struct dm_stats *dms, int fd)
-{
-	int major, minor;
-	struct stat buf;
-
-	if (fstat(fd, &buf)) {
-		log_error("fstat failed for fd %d.", fd);
-		return 0;
-	}
-
-	major = (int) MAJOR(buf.st_dev);
-	minor = (int) MINOR(buf.st_dev);
-
-	if (!dm_stats_bind_devno(dms, major, minor))
-		return_0;
-	return 1;
-}
-
 static int _stats_clear_one_region(struct dm_stats *dms, uint64_t region_id)
 {
 
@@ -5068,7 +5050,7 @@ static int _stats_create_file(CMD_ARGS)
 		goto bad;
 	}
 
-	if (!_bind_stats_from_fd(dms, fd))
+	if (!dm_stats_bind_from_fd(dms, fd))
 		goto_bad;
 
 	if (!strlen(program_id))



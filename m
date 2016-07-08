From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 22:43:54 +0000 (UTC)
Subject: master - libdm: add configure.in checks for fiemap.h and magic.h
Message-ID: <20160708224354.0751F6100A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=309bdfa22417cf77e7be2349c414295d83d47fbc
Commit:        309bdfa22417cf77e7be2349c414295d83d47fbc
Parent:        61cb58e549e5ff55095733bc3c7277c83584e5a0
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 23:38:32 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 23:42:32 2016 +0100

libdm: add configure.in checks for fiemap.h and magic.h

---
 configure              |    2 +-
 configure.in           |    2 +-
 include/configure.h.in |    6 ++++++
 libdm/libdm-stats.c    |   29 ++++++++++++++++++++++++++---
 4 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/configure b/configure
index 83d5964..8253bfc 100755
--- a/configure
+++ b/configure
@@ -5875,7 +5875,7 @@ fi
 done
 
 
-for ac_header in termios.h sys/statvfs.h sys/timerfd.h
+for ac_header in termios.h sys/statvfs.h sys/timerfd.h linux/magic.h linux/fiemap.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
 ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
diff --git a/configure.in b/configure.in
index b87f8ff..33b5c76 100644
--- a/configure.in
+++ b/configure.in
@@ -103,7 +103,7 @@ AC_CHECK_HEADERS([assert.h ctype.h dirent.h errno.h fcntl.h float.h \
   sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h \
   unistd.h], , [AC_MSG_ERROR(bailing out)])
 
-AC_CHECK_HEADERS(termios.h sys/statvfs.h sys/timerfd.h)
+AC_CHECK_HEADERS(termios.h sys/statvfs.h sys/timerfd.h linux/magic.h linux/fiemap.h)
 
 case "$host_os" in
 	linux*)
diff --git a/include/configure.h.in b/include/configure.h.in
index d94d55d..3c43bd5 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -264,9 +264,15 @@
 /* Define to 1 if you have the <limits.h> header file. */
 #undef HAVE_LIMITS_H
 
+/* Define to 1 if you have the <linux/fiemap.h> header file. */
+#undef HAVE_LINUX_FIEMAP_H
+
 /* Define to 1 if you have the <linux/fs.h> header file. */
 #undef HAVE_LINUX_FS_H
 
+/* Define to 1 if you have the <linux/magic.h> header file. */
+#undef HAVE_LINUX_MAGIC_H
+
 /* Define to 1 if you have the <locale.h> header file. */
 #undef HAVE_LOCALE_H
 
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 612f9bf..57ef11d 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -21,9 +21,18 @@
 
 #include <sys/ioctl.h>
 #include <sys/vfs.h> /* fstatfs */
-#include <linux/fs.h> /* FS_IOC_FIEMAP */
-#include <linux/fiemap.h> /* fiemap */
-#include <linux/magic.h> /* BTRFS_SUPER_MAGIC */
+
+#ifdef __linux__
+  #include <linux/fs.h> /* FS_IOC_FIEMAP */
+#endif
+
+#ifdef HAVE_LINUX_FIEMAP_H
+  #include <linux/fiemap.h> /* fiemap */
+#endif
+
+#ifdef HAVE_LINUX_MAGIC_H
+  #include <linux/magic.h> /* BTRFS_SUPER_MAGIC */
+#endif
 
 #define DM_STATS_REGION_NOT_PRESENT UINT64_MAX
 #define DM_STATS_GROUP_NOT_PRESENT DM_STATS_GROUP_NONE
@@ -4064,6 +4073,7 @@ int dm_stats_get_group_descriptor(const struct dm_stats *dms,
 	return 1;
 }
 
+#ifdef HAVE_LINUX_FIEMAP_H
 /*
  * Group a table of region_ids corresponding to the extents of a file.
  */
@@ -4258,6 +4268,7 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 	struct statfs fsbuf;
 	struct stat buf;
 
+#ifdef BTRFS_SUPER_MAGIC
 	if (fstatfs(fd, &fsbuf)) {
 		log_error("fstatfs failed for fd %d", fd);
 		return 0;
@@ -4268,6 +4279,7 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 			  "physical FIEMAP extent data.");
 		return 0;
 	}
+#endif
 
 	if (fstat(fd, &buf)) {
 		log_error("fstat failed for fd %d", fd);
@@ -4360,6 +4372,17 @@ out:
 	return NULL;
 }
 
+#else /* HAVE_LINUX_FIEMAP */
+uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
+					  int group, int precise,
+					  struct dm_histogram *bounds,
+					  const char *alias)
+{
+	log_error("File mapping requires FIEMAP ioctl support.");
+	return 0;
+}
+#endif /* HAVE_LINUX_FIEMAP */
+
 /*
  * Backward compatible dm_stats_create_region() implementations.
  *



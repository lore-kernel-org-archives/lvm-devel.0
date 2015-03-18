From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Mar 2015 12:46:45 +0000 (UTC)
Subject: master - lvm-file: wrapper to read ctim from stat
Message-ID: <20150318124645.2E62760C9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6606b1bff3fba90cc7af92dcda1c6eafdbf5e200
Commit:        6606b1bff3fba90cc7af92dcda1c6eafdbf5e200
Parent:        17583f1b591bc4f84acf1e6be76083ddd84020ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 18 10:54:08 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 18 13:42:24 2015 +0100

lvm-file: wrapper to read ctim from stat

When available use nanosecond stat info.

If commands are running closely enough after config update,
the .cache file from persistent filter could have been ignored.

This happens sometimes during i.e. synthetic test suite run.
---
 lib/misc/lvm-file.c |   11 +++++++++++
 lib/misc/lvm-file.h |   11 +++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index f0e2841..2e896ec 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -21,6 +21,7 @@
 #include <sys/file.h>
 #include <fcntl.h>
 #include <dirent.h>
+#include <sys/time.h>
 
 /*
  * Creates a temporary filename, and opens a descriptor to the
@@ -273,3 +274,13 @@ int lvm_fclose(FILE *fp, const char *filename)
 
 	return EOF;
 }
+
+void lvm_stat_ctim(struct timespec *ctim, const struct stat *buf)
+{
+#ifdef HAVE_STAT_ST_CTIM
+	*ctim = buf->st_ctim;
+#else
+	ctim->tv_sec = buf->st_ctime;
+	ctim->tv_nsec = 0;
+#endif
+}
diff --git a/lib/misc/lvm-file.h b/lib/misc/lvm-file.h
index c23d8ad..a4f332c 100644
--- a/lib/misc/lvm-file.h
+++ b/lib/misc/lvm-file.h
@@ -62,4 +62,15 @@ void fcntl_unlock_file(int lockfd);
  */
 int lvm_fclose(FILE *fp, const char *filename);
 
+/*
+ * Convert stat->st_ctim  status of last change in nanoseconds
+ * uses  st_ctime when not available.
+ */
+void lvm_stat_ctim(struct timespec *ts, const struct stat *buf);
+
+/* Inspired by <sys/time.h>  timercmp() macro for timeval */
+#define timespeccmp(tsp, usp, cmp)\
+	(((tsp)->tv_sec == (usp)->tv_sec) ?\
+		((tsp)->tv_nsec cmp (usp)->tv_nsec) :\
+		((tsp)->tv_sec cmp (usp)->tv_sec))
 #endif



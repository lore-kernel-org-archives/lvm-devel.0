From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 31 Jul 2012 09:16:28 +0000 (UTC)
Subject: master - libdm-string: Add dm_vasprintf.
Message-ID: <20120731091628.75EF155BD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0c2211c34f49784e30c6001b383e5a493d991a5
Commit:        e0c2211c34f49784e30c6001b383e5a493d991a5
Parent:        88ae8840959e353268057684365e00b02b2c29c4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 30 16:41:15 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jul 31 11:12:34 2012 +0200

libdm-string: Add dm_vasprintf.

---
 libdm/libdevmapper.h |    1 +
 libdm/libdm-string.c |   14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 02bf421..0786b38 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1291,6 +1291,7 @@ int dm_fclose(FILE *stream);
  */
 int dm_asprintf(char **buf, const char *format, ...)
     __attribute__ ((format(printf, 2, 3)));
+int dm_vasprintf(char **buf, const char *format, va_list ap);
 
 /*
  * create lockfile (pidfile) - create and lock a lock file
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 776ec97..5ef6334 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -129,7 +129,7 @@ const char *dm_basename(const char *path)
 	return p ? p + 1 : path;
 }
 
-int dm_asprintf(char **result, const char *format, ...)
+int dm_vasprintf(char **result, const char *format, va_list aq)
 {
 	int i, n, size = 16;
 	va_list ap;
@@ -141,7 +141,7 @@ int dm_asprintf(char **result, const char *format, ...)
 		return -1;
 
 	for (i = 0;; i++) {
-		va_start(ap, format);
+		va_copy(ap, aq);
 		n = vsnprintf(buf, size, format, ap);
 		va_end(ap);
 
@@ -168,6 +168,16 @@ int dm_asprintf(char **result, const char *format, ...)
 	return n + 1;
 }
 
+int dm_asprintf(char **result, const char *format, ...)
+{
+	int r;
+	va_list ap;
+	va_start(ap, format);
+	r = dm_vasprintf(result, format, ap);
+	va_end(ap);
+	return r;
+}
+
 /*
  * Count occurences of 'c' in 'str' until we reach a null char.
  *



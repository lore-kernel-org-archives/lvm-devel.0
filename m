From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Aug 2019 11:26:13 -0400
Subject: master - configure: check for prlimit
Message-ID: <201908261526.x7QFQDU4009023@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55f1d8a2697c6641215604ee32181d7ead7b8d85
Commit:        55f1d8a2697c6641215604ee32181d7ead7b8d85
Parent:        a50c127904a99b5862c323ddc76bfcf760dd0805
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 26 17:19:16 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 26 17:24:37 2019 +0200

configure: check for prlimit

Update configure and make code compilable if prlimit() is not present.
Since the code is suspicious do not cope yet with it's replacement
with  set/getrlimit().
---
 configure              |    4 ++--
 configure.ac           |    2 +-
 include/configure.h.in |    3 +++
 lib/label/label.c      |    2 ++
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index 4c84765..7bb038a 100755
--- a/configure
+++ b/configure
@@ -1715,7 +1715,7 @@ Optional Packages:
                           cache_restore tool: [autodetect]
   --with-vdo=TYPE         vdo support: internal/none [internal]
   --with-vdo-format=PATH  vdoformat tool: [autodetect]
-  --with-writecache=TYPE  writecache support: internal/none [internal]
+  --with-writecache=TYPE  writecache support: internal/none [none]
   --with-ocfdir=DIR       install OCF files in
                           [PREFIX/lib/ocf/resource.d/lvm2]
   --with-default-pid-dir=PID_DIR
@@ -6647,7 +6647,7 @@ $as_echo "#define _REENTRANT 1" >>confdefs.h
 
 ################################################################################
 for ac_func in ftruncate gethostname getpagesize gettimeofday localtime_r \
-  memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
+  memchr memset mkdir mkfifo munmap nl_langinfo prlimit pselect realpath rmdir setenv \
   setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
   strrchr strspn strstr strtol strtoul uname
 do :
diff --git a/configure.ac b/configure.ac
index 830edb8..e3af0c4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -153,7 +153,7 @@ AC_DEFINE([_REENTRANT], 1, [Define to use re-entrant thread safe versions])
 ################################################################################
 dnl -- Check for functions
 AC_CHECK_FUNCS([ftruncate gethostname getpagesize gettimeofday localtime_r \
-  memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
+  memchr memset mkdir mkfifo munmap nl_langinfo prlimit pselect realpath rmdir setenv \
   setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
   strrchr strspn strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
 AC_FUNC_ALLOCA
diff --git a/include/configure.h.in b/include/configure.h.in
index a43053a..91a3a7d 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -292,6 +292,9 @@
 /* Define to 1 if you have the <paths.h> header file. */
 #undef HAVE_PATHS_H
 
+/* Define to 1 if you have the `prlimit' function. */
+#undef HAVE_PRLIMIT
+
 /* Define to 1 if you have the `pselect' function. */
 #undef HAVE_PSELECT
 
diff --git a/lib/label/label.c b/lib/label/label.c
index e786c89..dc4d32d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -873,6 +873,7 @@ static void _free_hints(struct dm_list *hints)
 
 static void _prepare_open_file_limit(struct cmd_context *cmd, unsigned int num_devs)
 {
+#ifdef HAVE_PRLIMIT
 	struct rlimit old, new;
 	unsigned int want = num_devs + BASE_FD_COUNT;
 	int rv;
@@ -909,6 +910,7 @@ static void _prepare_open_file_limit(struct cmd_context *cmd, unsigned int num_d
 			log_warn("WARNING: cannot set open file limit for scanning %u devices.", num_devs);
 		return;
 	}
+#endif
 }
 
 /*



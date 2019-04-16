From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Apr 2019 06:59:04 -0400
Subject: master - configure: check for pselect
Message-ID: <201904161059.x3GAx4H5016955@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=116bd314cb8bb169336b2a14ff5ced78d9de9047
Commit:        116bd314cb8bb169336b2a14ff5ced78d9de9047
Parent:        aa75b31db54782fb24b6b7e3c681a61b3579117c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 10 13:22:43 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 16 12:14:31 2019 +0200

configure: check for pselect

---
 configure              |    2 +-
 configure.ac           |    2 +-
 include/configure.h.in |    6 ++++++
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 53f5023..cced7bd 100755
--- a/configure
+++ b/configure
@@ -6634,7 +6634,7 @@ $as_echo "#define _REENTRANT 1" >>confdefs.h
 
 ################################################################################
 for ac_func in ftruncate gethostname getpagesize gettimeofday localtime_r \
-  memchr memset mkdir mkfifo munmap nl_langinfo realpath rmdir setenv \
+  memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
   setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
   strrchr strspn strstr strtol strtoul uname
 do :
diff --git a/configure.ac b/configure.ac
index 98a39f6..1e45c0e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -153,7 +153,7 @@ AC_DEFINE([_REENTRANT], 1, [Define to use re-entrant thread safe versions])
 ################################################################################
 dnl -- Check for functions
 AC_CHECK_FUNCS([ftruncate gethostname getpagesize gettimeofday localtime_r \
-  memchr memset mkdir mkfifo munmap nl_langinfo realpath rmdir setenv \
+  memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
   setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
   strrchr strspn strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
 AC_FUNC_ALLOCA
diff --git a/include/configure.h.in b/include/configure.h.in
index dde55fe..ce4c326 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -292,6 +292,12 @@
 /* Define to 1 if you have the <paths.h> header file. */
 #undef HAVE_PATHS_H
 
+/* Define to 1 if you have the `pselect' function. */
+#undef HAVE_PSELECT
+
+/* Define to 1 if you have the <pthread.h> header file. */
+#undef HAVE_PTHREAD_H
+
 /* Define to 1 if the system has the type `ptrdiff_t'. */
 #undef HAVE_PTRDIFF_T
 



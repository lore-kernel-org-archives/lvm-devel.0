From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Apr 2019 07:31:23 -0400
Subject: stable-2.02 - configure: check for pselect
Message-ID: <201904101131.x3ABVNk2014101@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63289b54c787fbc4f254b1d1144e147a12402d4f
Commit:        63289b54c787fbc4f254b1d1144e147a12402d4f
Parent:        0a726a7e268b31856615491809af73bda5d4d6f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 10 13:22:43 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 10 13:24:41 2019 +0200

configure: check for pselect

---
 configure              |    2 +-
 configure.ac           |    2 +-
 include/configure.h.in |    3 +++
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 908dc7c..4d2fb2f 100755
--- a/configure
+++ b/configure
@@ -6672,7 +6672,7 @@ fi
 
 ################################################################################
 for ac_func in ftruncate gethostname getpagesize gettimeofday localtime_r \
-  memchr memset mkdir mkfifo munmap nl_langinfo realpath rmdir setenv \
+  memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
   setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
   strrchr strspn strstr strtol strtoul uname
 do :
diff --git a/configure.ac b/configure.ac
index b9691ea..379d37f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -146,7 +146,7 @@ AX_GCC_BUILTIN([__builtin_clz])
 ################################################################################
 dnl -- Check for functions
 AC_CHECK_FUNCS([ftruncate gethostname getpagesize gettimeofday localtime_r \
-  memchr memset mkdir mkfifo munmap nl_langinfo realpath rmdir setenv \
+  memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
   setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
   strrchr strspn strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
 AC_FUNC_ALLOCA
diff --git a/include/configure.h.in b/include/configure.h.in
index 15fd150..812cacc 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -340,6 +340,9 @@
 /* Define to 1 if you have the <paths.h> header file. */
 #undef HAVE_PATHS_H
 
+/* Define to 1 if you have the `pselect' function. */
+#undef HAVE_PSELECT
+
 /* Define to 1 if you have the <pthread.h> header file. */
 #undef HAVE_PTHREAD_H
 



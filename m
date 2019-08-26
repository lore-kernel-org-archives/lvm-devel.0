From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Aug 2019 11:35:36 -0400
Subject: master - configure: continue build if prlimit is missing
Message-ID: <201908261535.x7QFZa26009659@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aefd177b047eb548e63ac94c9eb442604175d3bc
Commit:        aefd177b047eb548e63ac94c9eb442604175d3bc
Parent:        55f1d8a2697c6641215604ee32181d7ead7b8d85
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 26 17:34:45 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 26 17:34:45 2019 +0200

configure: continue build if prlimit is missing

---
 configure    |   13 ++++++++++++-
 configure.ac |    3 ++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 7bb038a..6dd7eda 100755
--- a/configure
+++ b/configure
@@ -6647,7 +6647,7 @@ $as_echo "#define _REENTRANT 1" >>confdefs.h
 
 ################################################################################
 for ac_func in ftruncate gethostname getpagesize gettimeofday localtime_r \
-  memchr memset mkdir mkfifo munmap nl_langinfo prlimit pselect realpath rmdir setenv \
+  memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
   setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
   strrchr strspn strstr strtol strtoul uname
 do :
@@ -6663,6 +6663,17 @@ else
 fi
 done
 
+for ac_func in prlimit
+do :
+  ac_fn_c_check_func "$LINENO" "prlimit" "ac_cv_func_prlimit"
+if test "x$ac_cv_func_prlimit" = xyes; then :
+  cat >>confdefs.h <<_ACEOF
+#define HAVE_PRLIMIT 1
+_ACEOF
+
+fi
+done
+
 # The Ultrix 4.2 mips builtin alloca declared by alloca.h only works
 # for constant arguments.  Useless!
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working alloca.h" >&5
diff --git a/configure.ac b/configure.ac
index e3af0c4..74ca201 100644
--- a/configure.ac
+++ b/configure.ac
@@ -153,9 +153,10 @@ AC_DEFINE([_REENTRANT], 1, [Define to use re-entrant thread safe versions])
 ################################################################################
 dnl -- Check for functions
 AC_CHECK_FUNCS([ftruncate gethostname getpagesize gettimeofday localtime_r \
-  memchr memset mkdir mkfifo munmap nl_langinfo prlimit pselect realpath rmdir setenv \
+  memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
   setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
   strrchr strspn strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
+AC_CHECK_FUNCS([prlimit])
 AC_FUNC_ALLOCA
 AC_FUNC_CLOSEDIR_VOID
 AC_FUNC_CHOWN



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 May 2014 14:25:42 +0000 (UTC)
Subject: master - configure: drop siginterrupt
Message-ID: <20140512142542.564D061391@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b787a24f024d2589583fc356f343bb981c169e2
Commit:        5b787a24f024d2589583fc356f343bb981c169e2
Parent:        e416d84e1093655786b09450154779ee7896f11d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 6 11:22:29 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 12 16:24:39 2014 +0200

configure: drop siginterrupt

Not used anymore
---
 configure               |   11 -----------
 configure.in            |    1 -
 lib/misc/configure.h.in |    3 ---
 lib/misc/lvm-wrappers.h |   15 ---------------
 4 files changed, 0 insertions(+), 30 deletions(-)

diff --git a/configure b/configure
index de93e77..44eab6f 100755
--- a/configure
+++ b/configure
@@ -5563,17 +5563,6 @@ else
 fi
 done
 
-for ac_func in siginterrupt
-do :
-  ac_fn_c_check_func "$LINENO" "siginterrupt" "ac_cv_func_siginterrupt"
-if test "x$ac_cv_func_siginterrupt" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_SIGINTERRUPT 1
-_ACEOF
-
-fi
-done
-
 # The Ultrix 4.2 mips builtin alloca declared by alloca.h only works
 # for constant arguments.  Useless!
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working alloca.h" >&5
diff --git a/configure.in b/configure.in
index e3ddde1..09ca1b5 100644
--- a/configure.in
+++ b/configure.in
@@ -134,7 +134,6 @@ AC_CHECK_FUNCS([ftruncate gethostname getpagesize \
   gettimeofday memset mkdir mkfifo rmdir munmap nl_langinfo setenv setlocale \
   strcasecmp strchr strcspn strspn strdup strncasecmp strerror strrchr \
   strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
-AC_CHECK_FUNCS(siginterrupt)
 AC_FUNC_ALLOCA
 AC_FUNC_CLOSEDIR_VOID
 AC_FUNC_CHOWN
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 507aae1..ead131c 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -288,9 +288,6 @@
 /* Define to 1 if you have the `setlocale' function. */
 #undef HAVE_SETLOCALE
 
-/* Define to 1 if you have the `siginterrupt' function. */
-#undef HAVE_SIGINTERRUPT
-
 /* Define to 1 if you have the <signal.h> header file. */
 #undef HAVE_SIGNAL_H
 
diff --git a/lib/misc/lvm-wrappers.h b/lib/misc/lvm-wrappers.h
index 9368e25..137cbdb 100644
--- a/lib/misc/lvm-wrappers.h
+++ b/lib/misc/lvm-wrappers.h
@@ -37,19 +37,4 @@ int read_urandom(void *buf, size_t len);
  */
 unsigned lvm_even_rand(unsigned *seed, unsigned max);
 
-#  ifndef HAVE_SIGINTERRUPT
-#    define siginterrupt(sig, flag) \
-	do { \
-		int ret; \
-		struct sigaction act; \
-		(void) sigaction(sig, NULL, &act); \
-		if (flag) \
-			act.sa_flags &= SA_RESTART; \
-		else \
-			act.sa_flags |= SA_RESTART; \
-		ret = sigaction(sig, &act, NULL); \
-		return ret; \
-	while (0)
-#  endif
-
 #endif



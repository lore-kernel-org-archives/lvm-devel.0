From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:19:14 +0200
Subject: [PATCH 2/4] configure: drop siginterrupt
In-Reply-To: <cover.1373296602.git.zkabelac@redhat.com>
References: <cover.1373296602.git.zkabelac@redhat.com>
Message-ID: <3f444d17245f56e8863fae8f6f67041649b4e9e6.1373296602.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Not used anymore

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure               | 11 -----------
 configure.in            |  1 -
 lib/misc/configure.h.in |  3 ---
 lib/misc/lvm-wrappers.h | 15 ---------------
 4 files changed, 30 deletions(-)

diff --git a/configure b/configure
index 12272d1..740fd1d 100755
--- a/configure
+++ b/configure
@@ -5499,17 +5499,6 @@ else
 fi
 done
 
-for ac_func in siginterrupt
-do :
-  ac_fn_c_check_func "$LINENO" "siginterrupt" "ac_cv_func_siginterrupt"
-if test "x$ac_cv_func_siginterrupt" = x""yes; then :
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
index 97ddc1d..631afdc 100644
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
index aae4f24..e03bf72 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -282,9 +282,6 @@
 /* Define to 1 if you have the `setlocale' function. */
 #undef HAVE_SETLOCALE
 
-/* Define to 1 if you have the `siginterrupt' function. */
-#undef HAVE_SIGINTERRUPT
-
 /* Define to 1 if you have the <signal.h> header file. */
 #undef HAVE_SIGNAL_H
 
diff --git a/lib/misc/lvm-wrappers.h b/lib/misc/lvm-wrappers.h
index e43f831..d9bf08b 100644
--- a/lib/misc/lvm-wrappers.h
+++ b/lib/misc/lvm-wrappers.h
@@ -32,19 +32,4 @@ int lvm_getpagesize(void);
  */
 int read_urandom(void *buf, size_t len);
 
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
-- 
1.8.3.1



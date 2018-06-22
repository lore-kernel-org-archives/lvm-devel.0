From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 17:38:51 -0400
Subject: master - utils: add clzll
Message-ID: <201806222138.w5MLcpI4018665@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c84a36b539d02a5f975a1e5e98c180621078498
Commit:        6c84a36b539d02a5f975a1e5e98c180621078498
Parent:        8215e3503d0799211d268c3e2a0f1b648d5f9584
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 19 19:35:48 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 23:37:02 2018 +0200

utils: add clzll

Check for __builtin_clzll and add wrapper when missing.
---
 configure              |   44 ++++++++++++++++++++++++++++++++++++++++++++
 configure.ac           |    1 +
 include/configure.h.in |    3 +++
 lib/misc/util.h        |   15 ++++++++++++++-
 4 files changed, 62 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index 7dee110..deaa8e9 100755
--- a/configure
+++ b/configure
@@ -6581,6 +6581,50 @@ fi
 
 
 
+
+
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking for __builtin_clzll" >&5
+$as_echo_n "checking for __builtin_clzll... " >&6; }
+if ${ax_cv_have___builtin_clzll+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+
+        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+int
+main ()
+{
+
+            __builtin_clzll(0)
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+  ax_cv_have___builtin_clzll=yes
+else
+  ax_cv_have___builtin_clzll=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_clzll" >&5
+$as_echo "$ax_cv_have___builtin_clzll" >&6; }
+
+    if test yes = $ax_cv_have___builtin_clzll; then :
+
+cat >>confdefs.h <<_ACEOF
+#define HAVE___BUILTIN_CLZLL 1
+_ACEOF
+
+fi
+
+
+
+
 ################################################################################
 for ac_func in ftruncate gethostname getpagesize gettimeofday localtime_r \
   memchr memset mkdir mkfifo munmap nl_langinfo realpath rmdir setenv \
diff --git a/configure.ac b/configure.ac
index c3197b7..699bbb6 100644
--- a/configure.ac
+++ b/configure.ac
@@ -140,6 +140,7 @@ AC_TYPE_UINT16_T
 AC_TYPE_UINT32_T
 AC_TYPE_UINT64_T
 AX_GCC_BUILTIN([__builtin_clz])
+AX_GCC_BUILTIN([__builtin_clzll])
 
 ################################################################################
 dnl -- Check for functions
diff --git a/include/configure.h.in b/include/configure.h.in
index b1b2db3..50e35f7 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -528,6 +528,9 @@
 /* Define to 1 if the system has the `__builtin_clz' built-in function */
 #undef HAVE___BUILTIN_CLZ
 
+/* Define to 1 if the system has the `__builtin_clzll' built-in function */
+#undef HAVE___BUILTIN_CLZLL
+
 /* Internalization package */
 #undef INTL_PACKAGE
 
diff --git a/lib/misc/util.h b/lib/misc/util.h
index 9231ea9..a42ecb3 100644
--- a/lib/misc/util.h
+++ b/lib/misc/util.h
@@ -43,7 +43,7 @@
 #ifdef HAVE___BUILTIN_CLZ
 #define clz(x) __builtin_clz((x))
 #else /* ifdef HAVE___BUILTIN_CLZ */
-unsigned _dm_clz(unsigned x)
+static unsigned _dm_clz(unsigned x)
 {
 	int n;
 
@@ -76,6 +76,19 @@ unsigned _dm_clz(unsigned x)
 #define clz(x) _dm_clz((x))
 #endif /* ifdef HAVE___BUILTIN_CLZ */
 
+#ifdef HAVE___BUILTIN_CLZLL
+#define clzll(x) __builtin_clzll((x))
+#else /* ifdef HAVE___BUILTIN_CLZ */
+static unsigned _dm_clzll(unsigned long long x)
+{
+	if (x <= 0xffffffff)
+		return 32 + clz((unsigned) (x & 0xffffffff));
+
+	return clz(x >> 32);
+}
+#define clzll(x) _dm_clzll((x))
+#endif /* ifdef HAVE___BUILTIN_CLZLL */
+
 #define KERNEL_VERSION(major, minor, release) (((major) << 16) + ((minor) << 8) + (release))
 
 /* Define some portable printing types */



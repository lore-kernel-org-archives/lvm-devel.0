From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Aug 2022 11:57:41 +0000 (GMT)
Subject: main - configure: check for mallinfo2
Message-ID: <20220830115741.28B113854148@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bda93ed4bcdc1bf7493298f6c90076cc3a033223
Commit:        bda93ed4bcdc1bf7493298f6c90076cc3a033223
Parent:        60ca2ce20fef54b3441dda051beebbc1847db50d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 30 13:28:24 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 30 13:54:19 2022 +0200

configure: check for mallinfo2

---
 configure              | 6 ++++++
 configure.ac           | 2 +-
 include/configure.h.in | 3 +++
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/configure b/configure
index 3586dd91c..aa3b83fcb 100755
--- a/configure
+++ b/configure
@@ -7696,6 +7696,12 @@ if test "x$ac_cv_func_ffs" = xyes
 then :
   printf "%s\n" "#define HAVE_FFS 1" >>confdefs.h
 
+fi
+ac_fn_c_check_func "$LINENO" "mallinfo2" "ac_cv_func_mallinfo2"
+if test "x$ac_cv_func_mallinfo2" = xyes
+then :
+  printf "%s\n" "#define HAVE_MALLINFO2 1" >>confdefs.h
+
 fi
 ac_fn_c_check_func "$LINENO" "prlimit" "ac_cv_func_prlimit"
 if test "x$ac_cv_func_prlimit" = xyes
diff --git a/configure.ac b/configure.ac
index ba02f1f9b..3148370ad 100644
--- a/configure.ac
+++ b/configure.ac
@@ -153,7 +153,7 @@ AC_CHECK_FUNCS([ftruncate gethostname getpagesize gettimeofday localtime_r \
   memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
   setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
   strrchr strspn strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
-AC_CHECK_FUNCS([ffs prlimit versionsort])
+AC_CHECK_FUNCS([ffs mallinfo2 prlimit versionsort])
 AC_FUNC_ALLOCA
 AC_FUNC_CLOSEDIR_VOID
 AC_FUNC_CHOWN
diff --git a/include/configure.h.in b/include/configure.h.in
index 83de33ab4..63c296550 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -267,6 +267,9 @@
 /* Define to 1 if you have the <machine/endian.h> header file. */
 #undef HAVE_MACHINE_ENDIAN_H
 
+/* Define to 1 if you have the `mallinfo2' function. */
+#undef HAVE_MALLINFO2
+
 /* Define to 1 if your system has a GNU libc compatible `malloc' function, and
    to 0 otherwise. */
 #undef HAVE_MALLOC


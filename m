From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  4 Dec 2013 14:01:03 +0000 (UTC)
Subject: master - configure: also LDFLAGS, not LDLAGS for proper restore
Message-ID: <20131204140103.50D5860E16@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28939dba09fcd36cd0e4e470e73b172f19dd45e8
Commit:        28939dba09fcd36cd0e4e470e73b172f19dd45e8
Parent:        1592bb216e47269b1a2839031b8e92d8c359461c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 4 14:58:40 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 4 15:00:56 2013 +0100

configure: also LDFLAGS, not LDLAGS for proper restore

---
 acinclude.m4 |    2 +-
 configure    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/acinclude.m4 b/acinclude.m4
index b9473db..601ae9d 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -49,7 +49,7 @@ AC_DEFUN([AC_TRY_LDFLAGS],
 	[AC_LINK_IFELSE([AC_LANG_PROGRAM()],
 			[AS_VAR_SET([ac_cv_flag_$2], [yes])],
 			[AS_VAR_SET([ac_cv_flag_$2], [no])])])
-    LDLAGS=$ac_save_LDFLAGS
+    LDFLAGS=$ac_save_LDFLAGS
     $2=AS_VAR_GET([ac_cv_flag_$2])
     if test "$2" = yes; then
         ifelse([$3], [], [:], [$3])
diff --git a/configure b/configure
index 2ecc7ba..ff7185d 100755
--- a/configure
+++ b/configure
@@ -6812,7 +6812,7 @@ rm -f core conftest.err conftest.$ac_objext \
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_FULL_RELRO" >&5
 $as_echo "$ac_cv_flag_HAVE_FULL_RELRO" >&6; }
-    LDLAGS=$ac_save_LDFLAGS
+    LDFLAGS=$ac_save_LDFLAGS
     HAVE_FULL_RELRO=$ac_cv_flag_HAVE_FULL_RELRO
     if test "HAVE_FULL_RELRO" = yes; then
         :



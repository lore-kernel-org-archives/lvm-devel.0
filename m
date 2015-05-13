From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 22:19:58 +0000 (UTC)
Subject: master - configure: preserve CXX/CFLAGS
Message-ID: <20150513221958.345AC6066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f207a6d353c895c6078f8345340228a2a790a659
Commit:        f207a6d353c895c6078f8345340228a2a790a659
Parent:        5e38b8439a48c5d3e7a9624336e1a4ae73049717
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 13 21:23:24 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 00:19:32 2015 +0200

configure: preserve CXX/CFLAGS

AC_PROG_CC
AC_PROG_CXX

Does not preserve CFLAGS CXXFLAGS
---
 configure    |    4 ++++
 configure.in |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index 9babc59..9485c2b 100755
--- a/configure
+++ b/configure
@@ -3184,6 +3184,8 @@ fi
   test -n "$AWK" && break
 done
 
+save_CFLAGS=$CFLAGS
+save_CXXFLAGS=$CXXFLAGS
 ac_ext=c
 ac_cpp='$CPP $CPPFLAGS'
 ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
@@ -4230,6 +4232,8 @@ ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
 ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
 ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
+CFLAGS=$save_CFLAGS
+CXXFLAGS=$save_CXXFLAGS
 
 
 ac_ext=c
diff --git a/configure.in b/configure.in
index c3222ed..5933763 100644
--- a/configure.in
+++ b/configure.in
@@ -69,8 +69,12 @@ esac
 dnl -- Checks for programs.
 AC_PROG_SED
 AC_PROG_AWK
+save_CFLAGS=$CFLAGS
+save_CXXFLAGS=$CXXFLAGS
 AC_PROG_CC
 AC_PROG_CXX
+CFLAGS=$save_CFLAGS
+CXXFLAGS=$save_CXXFLAGS
 
 dnl probably no longer needed in 2008, but...
 AC_PROG_GCC_TRADITIONAL



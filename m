From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:26 +0200
Subject: [PATCH 05/15] configure.in: Add check_lib_no_libs support macro
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <00b7aeb80e16c9e423170aba716b40bbab643207.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

AC_CHECK_LIB by default add the result to LIBS= for linking.
In some cases we want to check if a library is available,
using a proper macro, without adding the result to the global
build environment.
check_lib_no_libs provides this functionality.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 e9a1206... 40974db... M	configure.in
 configure.in |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index e9a1206..40974db 100644
--- a/configure.in
+++ b/configure.in
@@ -375,6 +375,20 @@ if  test x$CLVMD != xnone; then
 		[AC_MSG_RESULT([pkg-config initialized])])
 fi
 
+dnl -- helper macro to check libs without adding them to LIBS
+check_lib_no_libs() {
+	lib_no_libs_arg1=$1
+	shift
+	lib_no_libs_arg2=$1
+	shift
+	lib_no_libs_args=$@
+	AC_CHECK_LIB([$lib_no_libs_arg1],
+		     [$lib_no_libs_arg2],,
+		     [AC_MSG_ERROR([bailing out])],
+		     [$lib_no_libs_args])
+	LIBS=$ac_check_lib_save_LIBS
+}
+
 dnl -- Look for corosync libraries if required.
 if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
 	PKG_CHECK_MODULES(QUORUM, libquorum, [],
-- 
1.5.4.3



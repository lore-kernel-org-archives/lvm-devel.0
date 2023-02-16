From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:54 +0000 (GMT)
Subject: main - configure.ac: various minor updates
Message-ID: <20230216231054.2C7FF3858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9697acbd6b4283b430b5c6a9ced45676c54bc1d
Commit:        b9697acbd6b4283b430b5c6a9ced45676c54bc1d
Parent:        1cd71a5fe3f69d0a4c8c05babd4a7433682318b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 23:41:02 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:00:12 2023 +0100

configure.ac: various minor updates

---
 configure.ac | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/configure.ac b/configure.ac
index b728ad096..86f4941d8 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1238,11 +1238,7 @@ AC_ARG_ENABLE(cmdlib,
 	      CMDLIB=$enableval, CMDLIB="no")
 AC_MSG_RESULT([$CMDLIB])
 AC_SUBST([LVM2CMD_LIB])
-AS_IF([test "$CMDLIB" = "yes"], [
-	LVM2CMD_LIB="-llvm2cmd"
-], [
-	LVM2CMD_LIB=""
-])
+AS_IF([test "$CMDLIB" = "yes"], [LVM2CMD_LIB="-llvm2cmd"], [LVM2CMD_LIB=])
 
 ################################################################################
 dnl -- Enable D-Bus service
@@ -1262,7 +1258,7 @@ AS_IF([test "$BUILD_LVMDBUSD" = "yes"], [
 	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
 	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG
 	m4_define_default([_AM_PYTHON_INTERPRETER_LIST],[ python3 python2 python dnl
-	python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 dnl
+	python3.12 python3.11 python3.10 python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 dnl
 	python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 ])
 	AM_PATH_PYTHON([3])
 	PYTHON3=$PYTHON
@@ -1273,12 +1269,8 @@ AS_IF([test "$BUILD_LVMDBUSD" = "yes"], [
 	AS_IF([test -z "$PYTHON3_CONFIG"], [
 		AC_MSG_ERROR([python3 headers are required for --enable-python3_bindings or --enable-dbus-service but cannot be found])
 	])
-	PYTHON3_INCDIRS=`"$PYTHON3_CONFIG" --includes`
-	PYTHON3_LIBDIRS=`"$PYTHON3_CONFIG" --libs`
 	PYTHON3DIR=$pythondir
-	AS_IF([test "$PYTHON3_BINDINGS" = "yes"], [
-		PYTHON_BINDINGS="yes"
-	])
+	AS_IF([test "$PYTHON3_BINDINGS" = "yes"], [PYTHON_BINDINGS="yes"])
 
 	# To get this macro, install autoconf-archive package then run autoreconf
 	AX_PYTHON_MODULE([pyudev], [Required], python3)


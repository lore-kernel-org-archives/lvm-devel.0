From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Fri, 28 Aug 2009 12:59:48 +0200
Subject: [PATCH 1/1] configure.in: add proper support for --with-clvmd=all
In-Reply-To: <1251457188-5172-1-git-send-email-fdinitto@redhat.com>
References: <1251457188-5172-1-git-send-email-fdinitto@redhat.com>
Message-ID: <b3c8c914b29fd75bf998371048a7b298e0d44433.1251457046.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Implement autodetection when "all" is selected:

- update help text
- set default to all
- add helpers to wrap failures
- fix all library checks to use the bailout helpers
- fix all library checks to propagate more info
- add autodetection snippet

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 496ffe6... 651ba6a... M	configure.in
 configure.in |  137 ++++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 105 insertions(+), 32 deletions(-)

diff --git a/configure.in b/configure.in
index 496ffe6..651ba6a 100644
--- a/configure.in
+++ b/configure.in
@@ -330,12 +330,13 @@ AC_ARG_WITH(clvmd,
                            * cman,gulm             (RHEL4 or equivalent)
                            * cman                  (RHEL5 or equivalent)
                            * cman,corosync,openais (or selection of them)
+                           * all                   (autodetect)
                            * none                  (disable build)
                           [TYPE=none] ],
   [ CLVMD="$withval" ],
   [ CLVMD="none" ])
-if test x$CLVMD = xyes || test x$CLVMD = xall; then
-	CLVMD=cman
+if test x$CLVMD = xyes; then
+	CLVMD=all
 fi
 AC_MSG_RESULT($CLVMD)
 
@@ -375,6 +376,28 @@ if  test x$CLVMD != xnone; then
 		[AC_MSG_RESULT([pkg-config initialized])])
 fi
 
+dnl -- define a soft bailout if we are autodetecting
+soft_bailout() {
+	NOTFOUND=1
+}
+
+hard_bailout() {
+	AC_MSG_ERROR([bailing out])
+}
+
+dnl -- if clvmd=all then set soft_bailout (we don't want to error)
+dnl -- and set all builds to yes. We need to do this here
+dnl -- to skip the gulm + openais|corosync sanity check above.
+if test x$CLVMD = xall; then
+	bailout=soft_bailout
+	BUILDGULM=yes
+	BUILDCMAN=yes
+	BUILDCOROSYNC=yes
+	BUILDOPENAIS=yes
+else
+	bailout=hard_bailout
+fi
+
 dnl -- helper macro to check libs without adding them to LIBS
 check_lib_no_libs() {
 	lib_no_libs_arg1=$1
@@ -384,32 +407,44 @@ check_lib_no_libs() {
 	lib_no_libs_args=$@
 	AC_CHECK_LIB([$lib_no_libs_arg1],
 		     [$lib_no_libs_arg2],,
-		     [AC_MSG_ERROR([bailing out])],
+		     [$bailout],
 		     [$lib_no_libs_args])
 	LIBS=$ac_check_lib_save_LIBS
 }
 
 dnl -- Look for gulm libraries if required.
 if test x$BUILDGULM = xyes; then
-	PKG_CHECK_MODULES(CCS, libccs, [],
-		[AC_CHECK_HEADERS(ccs.h,,AC_MSG_ERROR(bailing out))
+	PKG_CHECK_MODULES(CCS, libccs, [HAVE_CCS=yes],
+		[NOTFOUND=0
+		AC_CHECK_HEADERS(ccs.h,,$bailout)
 		check_lib_no_libs ccs ccs_connect
-		AC_MSG_RESULT([no pkg for libccs library, using -lccs])
-		CCS_LIBS="-lccs"])
-	PKG_CHECK_MODULES(GULM, libgulm, [],
-		[AC_CHECK_HEADERS(libgulm.h,,AC_MSG_ERROR(bailing out))
+		if test $NOTFOUND = 0; then
+			AC_MSG_RESULT([no pkg for libccs, using -lccs])
+			CCS_LIBS="-lccs"
+			HAVE_CCS=yes
+		fi])
+	PKG_CHECK_MODULES(GULM, libgulm, [HAVE_GULM=yes],
+		[NOTFOUND=0
+		AC_CHECK_HEADERS(libgulm.h,,$bailout)
 		check_lib_no_libs gulm lg_core_login
-		AC_MSG_RESULT([no pkg for libgulm library, using -lgulm])
-		GULM_LIBS="-lgulm"])
+		if test $NOTFOUND = 0; then
+			AC_MSG_RESULT([no pkg for libgulm, using -lgulm])
+			GULM_LIBS="-lgulm"
+			HAVE_GULM=yes
+		fi])
 fi
 
 dnl -- Look for cman libraries if required.
 if test x$BUILDCMAN = xyes; then
-	PKG_CHECK_MODULES(CMAN, libcman, [],
-		[AC_CHECK_HEADERS(libcman.h,,AC_MSG_ERROR(bailing out))
+	PKG_CHECK_MODULES(CMAN, libcman, [HAVE_CMAN=yes],
+		[NOTFOUND=0
+		AC_CHECK_HEADERS(libcman.h,,$bailout)
 		check_lib_no_libs cman cman_init
-		AC_MSG_RESULT([no pkg for libcman library, using -lcman])
-		CMAN_LIBS="-lcman"])
+		if test $NOTFOUND = 0; then
+			AC_MSG_RESULT([no pkg for libcman, using -lcman])
+			CMAN_LIBS="-lcman"
+			HAVE_CMAN=yes
+		fi])
 	CHECKCONFDB=yes
 	CHECKDLM=yes
 fi
@@ -419,20 +454,20 @@ dnl -- only enough recent version of corosync ship pkg-config files.
 dnl -- We can safely rely on that to detect the correct bits.
 if test x$BUILDCOROSYNC = xyes || \
    test x$BUILDOPENAIS = xyes; then
-	PKG_CHECK_MODULES(COROSYNC, corosync)
+	PKG_CHECK_MODULES(COROSYNC, corosync, [HAVE_COROSYNC=yes], $bailout)
 	CHECKCONFDB=yes
 fi
 
 dnl -- Look for corosync libraries if required.
 if test x$BUILDCOROSYNC = xyes; then
-	PKG_CHECK_MODULES(QUORUM, libquorum)
+	PKG_CHECK_MODULES(QUORUM, libquorum, [HAVE_QUORUM=yes], $bailout)
 	CHECKCPG=yes
 	CHECKDLM=yes
 fi
 
 dnl -- Look for openais libraries if required.
 if test x$BUILDOPENAIS = xyes; then
-	PKG_CHECK_MODULES(SALCK, libSaLck)
+	PKG_CHECK_MODULES(SALCK, libSaLck, [HAVE_SALCK=yes], $bailout)
 	CHECKCPG=yes
 fi
 
@@ -443,37 +478,75 @@ dnl -- mandatory for corosync build.
 dnl -- optional for openais/cman build.
 
 if test x$CHECKCONFDB = xyes; then
-	PKG_CHECK_MODULES(CONFDB, libconfdb,,
-			  [HAVE_PKG_CONFDB=no])
-
-	if test x$BUILDCOROSYNC = xyes && \
-	   test x$HAVE_PKG_CONFDB = xno; then
-		AC_MSG_ERROR([bailing out... confdb library is required])
-	fi
+	PKG_CHECK_MODULES(CONFDB, libconfdb,
+			  [HAVE_CONFDB=yes],
+			  [HAVE_CONFDB=no])
 
 	AC_CHECK_HEADERS(corosync/confdb.h,
 		[HAVE_CONFDB_H=yes],
 		[HAVE_CONFDB_H=no])
 
-	if test x$HAVE_PKG_CONFDB = xno && \
+	if test x$HAVE_CONFDB != xyes && \
 	   test x$HAVE_CONFDB_H = xyes; then
-		AC_MSG_RESULT([no pkg for confdb library, using -lconfdb])
+		check_lib_no_libs confdb confdb_initialize
+		AC_MSG_RESULT([no pkg for confdb, using -lconfdb])
 		CONFDB_LIBS="-lconfdb"
+		HAVE_CONFDB=yes
+	fi
+
+	if test x$BUILDCOROSYNC = xyes && \
+	   test x$HAVE_CONFDB != xyes &&
+	   test x$CLVMD != xall; then
+		AC_MSG_ERROR([bailing out... confdb library is required])
 	fi
 fi
 
 dnl -- Check cpg library.
 if test x$CHECKCPG = xyes; then
-	PKG_CHECK_MODULES(CPG, libcpg)
+	PKG_CHECK_MODULES(CPG, libcpg, [HAVE_CPG=yes], $bailout)
 fi
 
 dnl -- Check dlm library.
 if test x$CHECKDLM = xyes; then
-	PKG_CHECK_MODULES(DLM, libdlm, [],
-		[AC_CHECK_HEADERS(libdlm.h,,AC_MSG_ERROR(bailing out))
+	PKG_CHECK_MODULES(DLM, libdlm, [HAVE_DLM=yes],
+		[NOTFOUND=0
+		AC_CHECK_HEADERS(libdlm.h,,$bailout)
 		check_lib_no_libs dlm dlm_lock -lpthread
-		AC_MSG_RESULT([no pkg for libdlm library, using -ldlm -lpthread])
-		DLM_LIBS="-ldlm -lpthread"])
+		if test $NOTFOUND = 0; then
+			AC_MSG_RESULT([no pkg for libdlm, using -ldlm])
+			DLM_LIBS="-ldlm -lpthread"
+			HAVE_DLM=yes
+		fi])
+fi
+
+dnl -- If we are autodetecting, we need to re-create
+dnl -- the depedencies checks and set a proper CLVMD.
+if test x$CLVMD = xall; then
+	if test x$HAVE_CCS = xyes && \
+	   test x$HAVE_GULM = xyes; then
+		AC_MSG_RESULT([Enabling clvmd gulm backend])
+		NEWCLVMD="$NEWCLVMD,gulm"
+	fi
+	if test x$HAVE_CMAN = xyes && \
+	   test x$HAVE_DLM = xyes; then
+		AC_MSG_RESULT([Enabling clvmd cman backend])
+		NEWCLVMD="$NEWCLVMD,cman"
+	fi
+	if test x$HAVE_COROSYNC = xyes && \
+	   test x$HAVE_QUORUM = xyes && \
+	   test x$HAVE_CPG = xyes && \
+	   test x$HAVE_DLM = xyes && \
+	   test x$HAVE_CONFDB = xyes; then
+		AC_MSG_RESULT([Enabling clvmd corosync backend])
+		NEWCLVMD="$NEWCLVMD,corosync"
+	fi
+	if test x$HAVE_COROSYNC = xyes && \
+	   test x$HAVE_CPG = xyes && \
+	   test x$HAVE_SALCK = xyes; then
+		AC_MSG_RESULT([Enabling clvmd openais backend])
+		NEWCLVMD="$NEWCLVMD,openais"
+	fi
+	CLVMD="$NEWCLVMD"
 fi
 
 ################################################################################
-- 
1.5.4.3



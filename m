From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jan 2012 21:21:56 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in da ...
Message-ID: <20120131212156.24689.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-31 21:21:55

Modified files:
	.              : WHATS_NEW configure configure.in 
	daemons/clvmd  : Makefile.in clvmd-corosync.c 
	lib/misc       : configure.h.in 

Log message:
	Automatically detect whether corosync clvmd needs to use confdb or cmap. (fabio)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2247&r2=1.2248
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.164&r2=1.165
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.179&r2=1.180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2012/01/28 20:12:26	1.2247
+++ LVM2/WHATS_NEW	2012/01/31 21:21:53	1.2248
@@ -1,5 +1,6 @@
 Version 2.02.90 - 
 ===================================
+  Automatically detect whether corosync clvmd needs to use confdb or cmap.
   Fix data% report for thin volume used as origin for non-thin snapshot.
 
 Version 2.02.89 - 26th January 2012
--- LVM2/configure	2012/01/23 17:48:18	1.164
+++ LVM2/configure	2012/01/31 21:21:53	1.165
@@ -694,6 +694,8 @@
 DLM_CFLAGS
 CPG_LIBS
 CPG_CFLAGS
+CMAP_LIBS
+CMAP_CFLAGS
 CONFDB_LIBS
 CONFDB_CFLAGS
 SALCK_LIBS
@@ -873,6 +875,8 @@
 SALCK_LIBS
 CONFDB_CFLAGS
 CONFDB_LIBS
+CMAP_CFLAGS
+CMAP_LIBS
 CPG_CFLAGS
 CPG_LIBS
 DLM_CFLAGS
@@ -1628,6 +1632,8 @@
   CONFDB_CFLAGS
               C compiler flags for CONFDB, overriding pkg-config
   CONFDB_LIBS linker flags for CONFDB, overriding pkg-config
+  CMAP_CFLAGS C compiler flags for CMAP, overriding pkg-config
+  CMAP_LIBS   linker flags for CMAP, overriding pkg-config
   CPG_CFLAGS  C compiler flags for CPG, overriding pkg-config
   CPG_LIBS    linker flags for CPG, overriding pkg-config
   DLM_CFLAGS  C compiler flags for DLM, overriding pkg-config
@@ -7514,6 +7520,7 @@
 	HAVE_COROSYNC=yes
 fi
 	CHECKCONFDB=yes
+	CHECKCMAP=yes
 fi
 
 if test x$BUILDCOROSYNC = xyes; then
@@ -7759,11 +7766,110 @@
 		CONFDB_LIBS="-lconfdb"
 		HAVE_CONFDB=yes
 	fi
+fi
+
+
+if test x$CHECKCMAP = xyes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for CMAP" >&5
+$as_echo_n "checking for CMAP... " >&6; }
+
+if test -n "$CMAP_CFLAGS"; then
+    pkg_cv_CMAP_CFLAGS="$CMAP_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libcmap\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libcmap") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_CMAP_CFLAGS=`$PKG_CONFIG --cflags "libcmap" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$CMAP_LIBS"; then
+    pkg_cv_CMAP_LIBS="$CMAP_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libcmap\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libcmap") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_CMAP_LIBS=`$PKG_CONFIG --libs "libcmap" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+
+
+
+if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
 
-	if test x$BUILDCOROSYNC = xyes && \
-	   test x$HAVE_CONFDB != xyes &&
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        CMAP_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libcmap" 2>&1`
+        else
+	        CMAP_PKG_ERRORS=`$PKG_CONFIG --print-errors "libcmap" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$CMAP_PKG_ERRORS" >&5
+
+	HAVE_CMAP=no
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	HAVE_CMAP=no
+else
+	CMAP_CFLAGS=$pkg_cv_CMAP_CFLAGS
+	CMAP_LIBS=$pkg_cv_CMAP_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_CMAP=yes
+fi
+
+	for ac_header in corosync/cmap.h
+do :
+  ac_fn_c_check_header_mongrel "$LINENO" "corosync/cmap.h" "ac_cv_header_corosync_cmap_h" "$ac_includes_default"
+if test "x$ac_cv_header_corosync_cmap_h" = x""yes; then :
+  cat >>confdefs.h <<_ACEOF
+#define HAVE_COROSYNC_CMAP_H 1
+_ACEOF
+ HAVE_CMAP_H=yes
+else
+  HAVE_CMAP_H=no
+fi
+
+done
+
+
+	if test x$HAVE_CMAP != xyes && \
+	   test x$HAVE_CMAP_H = xyes; then
+		check_lib_no_libs cmap cmap_initialize
+		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no pkg for cmap, using -lcmap" >&5
+$as_echo "no pkg for cmap, using -lcmap" >&6; }
+		CMAP_LIBS="-lcmap"
+		HAVE_CMAP=yes
+	fi
+fi
+
+if test x$BUILDCOROSYNC = xyes; then
+	if test x$HAVE_CMAP != xyes && \
+	   test x$HAVE_CONFDB != xyes && \
 	   test x$CLVMD != xall; then
-		as_fn_error $? "bailing out... confdb library is required" "$LINENO" 5
+		as_fn_error $? "bailing out... cmap (corosync >= 2.0) or confdb (corosync < 2.0) library is required" "$LINENO" 5
 	fi
 fi
 
@@ -7968,12 +8074,13 @@
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_QUORUM = xyes && \
 	   test x$HAVE_CPG = xyes && \
-	   test x$HAVE_DLM = xyes && \
-	   test x$HAVE_CONFDB = xyes; then
+	   test x$HAVE_DLM = xyes; then
+	   if test x$HAVE_CONFDB = xyes || test x$HAVE_CMAP = xyes; then
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: Enabling clvmd corosync cluster manager" >&5
 $as_echo "Enabling clvmd corosync cluster manager" >&6; }
 		CLVMD="$CLVMD,corosync"
 		CLVMD_CMANAGERS="$CLVMD_CMANAGERS corosync"
+	   fi
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_CPG = xyes && \
@@ -10230,6 +10337,8 @@
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_mon!
 itoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
--- LVM2/configure.in	2012/01/23 17:48:18	1.179
+++ LVM2/configure.in	2012/01/31 21:21:54	1.180
@@ -1,6 +1,6 @@
 ###############################################################################
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
@@ -549,6 +549,7 @@
    test x$BUILDOPENAIS = xyes; then
 	PKG_CHECK_MODULES(COROSYNC, corosync, [HAVE_COROSYNC=yes], $bailout)
 	CHECKCONFDB=yes
+	CHECKCMAP=yes
 fi
 
 dnl -- Look for corosync libraries if required.
@@ -567,7 +568,7 @@
 dnl -- Below are checks for libraries common to more than one build.
 
 dnl -- Check confdb library.
-dnl -- mandatory for corosync build.
+dnl -- mandatory for corosync < 2.0 build.
 dnl -- optional for openais/cman build.
 
 if test x$CHECKCONFDB = xyes; then
@@ -586,11 +587,34 @@
 		CONFDB_LIBS="-lconfdb"
 		HAVE_CONFDB=yes
 	fi
+fi
+
+dnl -- Check cmap library
+dnl -- mandatory for corosync >= 2.0 build.
 
-	if test x$BUILDCOROSYNC = xyes && \
-	   test x$HAVE_CONFDB != xyes &&
+if test x$CHECKCMAP = xyes; then
+	PKG_CHECK_MODULES(CMAP, libcmap,
+			  [HAVE_CMAP=yes],
+			  [HAVE_CMAP=no])
+
+	AC_CHECK_HEADERS(corosync/cmap.h,
+		[HAVE_CMAP_H=yes],
+		[HAVE_CMAP_H=no])
+
+	if test x$HAVE_CMAP != xyes && \ 
+	   test x$HAVE_CMAP_H = xyes; then
+		check_lib_no_libs cmap cmap_initialize
+		AC_MSG_RESULT([no pkg for cmap, using -lcmap])
+		CMAP_LIBS="-lcmap"
+		HAVE_CMAP=yes
+	fi
+fi
+
+if test x$BUILDCOROSYNC = xyes; then
+	if test x$HAVE_CMAP != xyes && \
+	   test x$HAVE_CONFDB != xyes && \
 	   test x$CLVMD != xall; then
-		AC_MSG_ERROR([bailing out... confdb library is required])
+		AC_MSG_ERROR([bailing out... cmap (corosync >= 2.0) or confdb (corosync < 2.0) library is required])
 	fi
 fi
 
@@ -629,11 +653,12 @@
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_QUORUM = xyes && \
 	   test x$HAVE_CPG = xyes && \
-	   test x$HAVE_DLM = xyes && \
-	   test x$HAVE_CONFDB = xyes; then
+	   test x$HAVE_DLM = xyes; then
+	   if test x$HAVE_CONFDB = xyes || test x$HAVE_CMAP = xyes; then
 		AC_MSG_RESULT([Enabling clvmd corosync cluster manager])
 		CLVMD="$CLVMD,corosync"
 		CLVMD_CMANAGERS="$CLVMD_CMANAGERS corosync"
+	   fi
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_CPG = xyes && \
@@ -1311,6 +1336,8 @@
 AC_SUBST(CLVMD_PATH)
 AC_SUBST(CMAN_CFLAGS)
 AC_SUBST(CMAN_LIBS)
+AC_SUBST(CMAP_CFLAGS)
+AC_SUBST(CMAP_LIBS)
 AC_SUBST(CMDLIB)
 AC_SUBST(CONFDB_CFLAGS)
 AC_SUBST(CONFDB_LIBS)
--- LVM2/daemons/clvmd/Makefile.in	2011/08/12 01:52:19	1.42
+++ LVM2/daemons/clvmd/Makefile.in	2012/01/31 21:21:54	1.43
@@ -17,6 +17,8 @@
 
 CMAN_LIBS = @CMAN_LIBS@
 CMAN_CFLAGS = @CMAN_CFLAGS@
+CMAP_LIBS = @CMAP_LIBS@
+CMAP_CFLAGS = @CMAP_CFLAGS@
 CONFDB_LIBS = @CONFDB_LIBS@
 CONFDB_CFLAGS = @CONFDB_CFLAGS@
 CPG_LIBS = @CPG_LIBS@
@@ -54,8 +56,8 @@
 
 ifneq (,$(findstring corosync,, "@CLVMD@,"))
 	SOURCES += clvmd-corosync.c
-	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) $(DLM_LIBS) $(QUORUM_LIBS)
-	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(DLM_CFLAGS) $(QUORUM_CFLAGS)
+	LMLIBS += $(CMAP_LIBS) $(CONFDB_LIBS) $(CPG_LIBS) $(DLM_LIBS) $(QUORUM_LIBS)
+	CFLAGS += $(CMAP_CFLAGS) $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(DLM_CFLAGS) $(QUORUM_CFLAGS)
 	DEFS += -DUSE_COROSYNC
 endif
 
--- LVM2/daemons/clvmd/clvmd-corosync.c	2011/09/25 19:37:00	1.16
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2012/01/31 21:21:54	1.17
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2009-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -30,7 +30,15 @@
 
 #include <corosync/cpg.h>
 #include <corosync/quorum.h>
-#include <corosync/confdb.h>
+
+#ifdef HAVE_COROSYNC_CONFDB_H
+#  include <corosync/confdb.h>
+#elif defined HAVE_COROSYNC_CMAP_H
+#  include <corosync/cmap.h>
+#else
+#  error "Either HAVE_COROSYNC_CONFDB_H or HAVE_COROSYNC_CMAP_H must be defined."
+#endif
+
 #include <libdlm.h>
 
 #include <syslog.h>
@@ -274,6 +282,10 @@
 {
 	cs_error_t err;
 
+#ifdef QUORUM_SET	/* corosync/quorum.h */
+	uint32_t quorum_type;
+#endif
+
 	node_hash = dm_hash_create(100);
 
 	err = cpg_initialize(&cpg_handle,
@@ -285,8 +297,21 @@
 		return cs_to_errno(err);
 	}
 
+#ifdef QUORUM_SET
+	err = quorum_initialize(&quorum_handle,
+				&quorum_callbacks,
+				&quorum_type);
+
+	if (quorum_type != QUORUM_SET) {
+		syslog(LOG_ERR, "Corosync quorum service is not configured");
+		DEBUGLOG("Corosync quorum service is not configured");
+		return EINVAL;
+	}
+#else
 	err = quorum_initialize(&quorum_handle,
 				&quorum_callbacks);
+#endif
+
 	if (err != CS_OK) {
 		syslog(LOG_ERR, "Cannot initialise Corosync quorum service: %d",
 		       err);
@@ -551,6 +576,7 @@
 	return cs_to_errno(err);
 }
 
+#ifdef HAVE_COROSYNC_CONFDB_H
 /*
  * We are not necessarily connected to a Red Hat Cluster system,
  * but if we are, this returns the cluster name from cluster.conf.
@@ -597,6 +623,38 @@
 	return 0;
 }
 
+#elif defined HAVE_COROSYNC_CMAP_H
+
+static int _get_cluster_name(char *buf, int buflen)
+{
+	cmap_handle_t cmap_handle = 0;
+	int result;
+	char *name = NULL;
+
+	/* This is a default in case everything else fails */
+	strncpy(buf, "Corosync", buflen);
+
+	/* Look for a cluster name in cmap */
+	result = cmap_initialize(&cmap_handle);
+	if (result != CS_OK)
+		return 0;
+
+	result = cmap_get_string(cmap_handle, "totem.cluster_name", &name);
+	if (result != CS_OK)
+		goto out;
+
+	memset(buf, 0, buflen);
+	strncpy(buf, name, buflen - 1);
+
+out:
+	if (name)
+		free(name);
+	cmap_finalize(cmap_handle);
+	return 0;
+}
+
+#endif
+
 static struct cluster_ops _cluster_corosync_ops = {
 	.name                     = "corosync",
 	.cluster_init_completed   = NULL,
--- LVM2/lib/misc/configure.h.in	2011/08/24 08:27:51	1.35
+++ LVM2/lib/misc/configure.h.in	2012/01/31 21:21:54	1.36
@@ -87,6 +87,9 @@
 /* Define to 1 if your system has a working `chown' function. */
 #undef HAVE_CHOWN
 
+/* Define to 1 if you have the <corosync/cmap.h> header file. */
+#undef HAVE_COROSYNC_CMAP_H
+
 /* Define to 1 if you have the <corosync/confdb.h> header file. */
 #undef HAVE_COROSYNC_CONFDB_H
 



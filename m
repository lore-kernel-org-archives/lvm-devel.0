From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 1 Sep 2009 19:11:46 -0000
Subject: LVM2 WHATS_NEW configure configure.in
Message-ID: <20090901191146.7020.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2009-09-01 19:11:46

Modified files:
	.              : WHATS_NEW configure configure.in 

Log message:
	Fix --with-clvmd=all to deal with the case where no cluster managers are available.
	
	Also simplify the check by removing an unnecessary variable and update
	configure messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1248&r2=1.1249
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/WHATS_NEW	2009/09/01 18:11:14	1.1248
+++ LVM2/WHATS_NEW	2009/09/01 19:11:45	1.1249
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Fix clvmd autodetection check and cleanup related configure messages.
   Fix Makefile distclean target.
   Make clvmd check corosync to see what cluster interface it should use.
   Rewrite clvmd configuration code to cope with all combinations of libs.
--- LVM2/configure	2009/08/28 20:51:40	1.102
+++ LVM2/configure	2009/09/01 19:11:45	1.103
@@ -1539,7 +1539,7 @@
   --with-mirrors=TYPE     Mirror support: internal/shared/none
                           TYPE=internal
   --with-clvmd=TYPE       Build cluster LVM Daemon.
-                          The following locking combinations are valid:
+                          The following cluster manager combinations are valid:
                            * cman,gulm             (RHEL4 or equivalent)
                            * cman                  (RHEL5 or equivalent)
                            * cman,corosync,openais (or selection of them)
@@ -11623,35 +11623,39 @@
 fi
 
 if test x$CLVMD = xall; then
+	CLVMD=none
 	if test x$HAVE_CCS = xyes && \
 	   test x$HAVE_GULM = xyes; then
-		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd gulm backend" >&5
-$as_echo "Enabling clvmd gulm backend" >&6; }
-		NEWCLVMD="$NEWCLVMD,gulm"
+		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd gulm cluster manager" >&5
+$as_echo "Enabling clvmd gulm cluster manager" >&6; }
+		CLVMD="$CLVMD,gulm"
 	fi
 	if test x$HAVE_CMAN = xyes && \
 	   test x$HAVE_DLM = xyes; then
-		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd cman backend" >&5
-$as_echo "Enabling clvmd cman backend" >&6; }
-		NEWCLVMD="$NEWCLVMD,cman"
+		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd cman cluster manager" >&5
+$as_echo "Enabling clvmd cman cluster manager" >&6; }
+		CLVMD="$CLVMD,cman"
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_QUORUM = xyes && \
 	   test x$HAVE_CPG = xyes && \
 	   test x$HAVE_DLM = xyes && \
 	   test x$HAVE_CONFDB = xyes; then
-		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd corosync backend" >&5
-$as_echo "Enabling clvmd corosync backend" >&6; }
-		NEWCLVMD="$NEWCLVMD,corosync"
+		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd corosync cluster manager" >&5
+$as_echo "Enabling clvmd corosync cluster manager" >&6; }
+		CLVMD="$CLVMD,corosync"
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_CPG = xyes && \
 	   test x$HAVE_SALCK = xyes; then
-		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd openais backend" >&5
-$as_echo "Enabling clvmd openais backend" >&6; }
-		NEWCLVMD="$NEWCLVMD,openais"
+		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd openais cluster manager" >&5
+$as_echo "Enabling clvmd openais cluster manager" >&6; }
+		CLVMD="$CLVMD,openais"
+	fi
+	if test x$CLVMD = xnone; then
+		{ $as_echo "$as_me:$LINENO: result: Disabling clvmd build. No cluster manager detected." >&5
+$as_echo "Disabling clvmd build. No cluster manager detected." >&6; }
 	fi
-	CLVMD="$NEWCLVMD"
 fi
 
 ################################################################################
--- LVM2/configure.in	2009/08/28 20:51:40	1.109
+++ LVM2/configure.in	2009/09/01 19:11:46	1.110
@@ -326,7 +326,7 @@
 AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
   [  --with-clvmd=TYPE       Build cluster LVM Daemon.
-                          The following locking combinations are valid:
+                          The following cluster manager combinations are valid:
                            * cman,gulm             (RHEL4 or equivalent)
                            * cman                  (RHEL5 or equivalent)
                            * cman,corosync,openais (or selection of them)
@@ -522,31 +522,34 @@
 dnl -- If we are autodetecting, we need to re-create
 dnl -- the depedencies checks and set a proper CLVMD.
 if test x$CLVMD = xall; then
+	CLVMD=none
 	if test x$HAVE_CCS = xyes && \
 	   test x$HAVE_GULM = xyes; then
-		AC_MSG_RESULT([Enabling clvmd gulm backend])
-		NEWCLVMD="$NEWCLVMD,gulm"
+		AC_MSG_RESULT([Enabling clvmd gulm cluster manager])
+		CLVMD="$CLVMD,gulm"
 	fi
 	if test x$HAVE_CMAN = xyes && \
 	   test x$HAVE_DLM = xyes; then
-		AC_MSG_RESULT([Enabling clvmd cman backend])
-		NEWCLVMD="$NEWCLVMD,cman"
+		AC_MSG_RESULT([Enabling clvmd cman cluster manager])
+		CLVMD="$CLVMD,cman"
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_QUORUM = xyes && \
 	   test x$HAVE_CPG = xyes && \
 	   test x$HAVE_DLM = xyes && \
 	   test x$HAVE_CONFDB = xyes; then
-		AC_MSG_RESULT([Enabling clvmd corosync backend])
-		NEWCLVMD="$NEWCLVMD,corosync"
+		AC_MSG_RESULT([Enabling clvmd corosync cluster manager])
+		CLVMD="$CLVMD,corosync"
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_CPG = xyes && \
 	   test x$HAVE_SALCK = xyes; then
-		AC_MSG_RESULT([Enabling clvmd openais backend])
-		NEWCLVMD="$NEWCLVMD,openais"
+		AC_MSG_RESULT([Enabling clvmd openais cluster manager])
+		CLVMD="$CLVMD,openais"
+	fi
+	if test x$CLVMD = xnone; then
+		AC_MSG_RESULT([Disabling clvmd build. No cluster manager detected.])
 	fi
-	CLVMD="$NEWCLVMD"
 fi
 
 ################################################################################



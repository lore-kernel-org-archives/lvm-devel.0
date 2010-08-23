From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 23 Aug 2010 11:37:03 -0000
Subject: LVM2 ./WHATS_NEW ./configure.in scripts/clvmd_ ...
Message-ID: <20100823113703.6426.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2010-08-23 11:37:02

Modified files:
	.              : WHATS_NEW configure.in 
	scripts        : clvmd_init_red_hat.in 

Log message:
	Based on auto-detection or user requested cluster managers for clvmd,
	set appropriate Required-Start and Required-Stop at configure time.
	
	Reorder the checks for user selected cluster managers to match auto
	detected ones, to be consistent in the output.
	
	Add special case for qdiskd that??s started after cman/lock_gulmd for
	RHEL-4/RHEL-5.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1722&r2=1.1723
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2010/08/23 11:34:40	1.1722
+++ LVM2/WHATS_NEW	2010/08/23 11:37:02	1.1723
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Automatically generate LSB Requires-Start for clvmd init script.
   Fix return code of pvmove --abort PV.
   Fix pvmove --abort to remove even for empty pvmove LV.
   Add configure --with-default-data-alignment.
--- LVM2/configure.in	2010/08/20 22:24:58	1.154
+++ LVM2/configure.in	2010/08/23 11:37:02	1.155
@@ -397,23 +397,37 @@
 fi
 
 dnl -- init pkgconfig if required
-if  test x$CLVMD != xnone && test x$PKGCONFIG_INIT != x1; then
+if test x$CLVMD != xnone && test x$PKGCONFIG_INIT != x1; then
 	pkg_config_init
 fi
 
+dnl -- Express clvmd init script Required-Start / Required-Stop
+CLVMD_CMANAGERS=""
+dnl -- On RHEL4/RHEL5, qdiskd is started from a separate init script.
+dnl -- Enable if we are build for either cman or gulm.
+CLVMD_NEEDS_QDISKD=no
 
 dnl -- define build types
 if [[ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]]; then
 	BUILDGULM=yes
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS lock_gulmd"
+	CLVMD_NEEDS_QDISKD=yes
+fi
+if [[ `expr x"$CLVMD" : '.*cman.*'` != 0 ]]; then
+	BUILDCMAN=yes
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS cman"
+	CLVMD_NEEDS_QDISKD=yes
 fi
 if [[ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
 	BUILDCOROSYNC=yes
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS corosync"
 fi
 if [[ `expr x"$CLVMD" : '.*openais.*'` != 0 ]]; then
 	BUILDOPENAIS=yes
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS openais"
 fi
-if [[ `expr x"$CLVMD" : '.*cman.*'` != 0 ]]; then
-	BUILDCMAN=yes
+if test x$CLVMD_NEEDS_QDISKD != xno; then
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
 fi
 
 dnl -- sanity check around user selection
@@ -568,18 +582,25 @@
 fi
 
 dnl -- If we are autodetecting, we need to re-create
-dnl -- the depedencies checks and set a proper CLVMD.
+dnl -- the depedencies checks and set a proper CLVMD,
+dnl -- together with init script Required-Start/Stop entries.
 if test x$CLVMD = xall; then
 	CLVMD=none
+	CLVMD_CMANAGERS=""
+	CLVMD_NEEDS_QDISKD=no
 	if test x$HAVE_CCS = xyes && \
 	   test x$HAVE_GULM = xyes; then
 		AC_MSG_RESULT([Enabling clvmd gulm cluster manager])
 		CLVMD="$CLVMD,gulm"
+		CLVMD_CMANAGERS="$CLVMD_CMANAGERS lock_gulmd"
+		CLVMD_NEEDS_QDISKD=yes
 	fi
 	if test x$HAVE_CMAN = xyes && \
 	   test x$HAVE_DLM = xyes; then
 		AC_MSG_RESULT([Enabling clvmd cman cluster manager])
 		CLVMD="$CLVMD,cman"
+		CLVMD_CMANAGERS="$CLVMD_CMANAGERS cman"
+		CLVMD_NEEDS_QDISKD=yes
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_QUORUM = xyes && \
@@ -588,12 +609,17 @@
 	   test x$HAVE_CONFDB = xyes; then
 		AC_MSG_RESULT([Enabling clvmd corosync cluster manager])
 		CLVMD="$CLVMD,corosync"
+		CLVMD_CMANAGERS="$CLVMD_CMANAGERS corosync"
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_CPG = xyes && \
 	   test x$HAVE_SALCK = xyes; then
 		AC_MSG_RESULT([Enabling clvmd openais cluster manager])
 		CLVMD="$CLVMD,openais"
+		CLVMD_CMANAGERS="$CLVMD_CMANAGERS openais"
+	fi
+	if test x$CLVMD_NEEDS_QDISKD != xno; then
+		CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
 	fi
 	if test x$CLVMD = xnone; then
 		AC_MSG_RESULT([Disabling clvmd build. No cluster manager detected.])
@@ -1238,6 +1264,7 @@
 AC_SUBST(CLDWHOLEARCHIVE)
 AC_SUBST(CLUSTER)
 AC_SUBST(CLVMD)
+AC_SUBST(CLVMD_CMANAGERS)
 AC_SUBST(CMAN_CFLAGS)
 AC_SUBST(CMAN_LIBS)
 AC_SUBST(CMDLIB)
--- LVM2/scripts/clvmd_init_red_hat.in	2010/08/12 09:15:00	1.10
+++ LVM2/scripts/clvmd_init_red_hat.in	2010/08/23 11:37:02	1.11
@@ -9,8 +9,8 @@
 #
 ### BEGIN INIT INFO
 # Provides:		clvmd
-# Required-Start:	$local_fs
-# Required-Stop:	$local_fs
+# Required-Start:	$local_fs at CLVMD_CMANAGERS@
+# Required-Stop:	$local_fs at CLVMD_CMANAGERS@
 # Short-Description:	This service is Clusterd LVM Daemon.
 # Description:		Cluster daemon for userland logical volume management tools.
 ### END INIT INFO



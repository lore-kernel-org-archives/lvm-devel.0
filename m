From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Aug 2010 13:44:32 -0000
Subject: LVM2 configure
Message-ID: <20100823134432.30924.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-23 13:44:31

Modified files:
	.              : configure 

Log message:
	Update configure after last change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.140&r2=1.141

--- LVM2/configure	2010/08/20 22:32:18	1.140
+++ LVM2/configure	2010/08/23 13:44:31	1.141
@@ -703,6 +703,7 @@
 COPTIMISE_FLAG
 CONFDIR
 CMDLIB
+CLVMD_CMANAGERS
 CLVMD
 CLUSTER
 CLDWHOLEARCHIVE
@@ -11632,22 +11633,33 @@
 	CLUSTER=internal
 fi
 
-if  test x$CLVMD != xnone && test x$PKGCONFIG_INIT != x1; then
+if test x$CLVMD != xnone && test x$PKGCONFIG_INIT != x1; then
 	pkg_config_init
 fi
 
+CLVMD_CMANAGERS=""
+CLVMD_NEEDS_QDISKD=no
 
 if [ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]; then
 	BUILDGULM=yes
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS lock_gulmd"
+	CLVMD_NEEDS_QDISKD=yes
+fi
+if [ `expr x"$CLVMD" : '.*cman.*'` != 0 ]; then
+	BUILDCMAN=yes
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS cman"
+	CLVMD_NEEDS_QDISKD=yes
 fi
 if [ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]; then
 	BUILDCOROSYNC=yes
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS corosync"
 fi
 if [ `expr x"$CLVMD" : '.*openais.*'` != 0 ]; then
 	BUILDOPENAIS=yes
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS openais"
 fi
-if [ `expr x"$CLVMD" : '.*cman.*'` != 0 ]; then
-	BUILDCMAN=yes
+if test x$CLVMD_NEEDS_QDISKD != xno; then
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
 fi
 
 if test x$BUILDGULM = xyes; then
@@ -13814,17 +13826,23 @@
 
 if test x$CLVMD = xall; then
 	CLVMD=none
+	CLVMD_CMANAGERS=""
+	CLVMD_NEEDS_QDISKD=no
 	if test x$HAVE_CCS = xyes && \
 	   test x$HAVE_GULM = xyes; then
 		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd gulm cluster manager" >&5
 $as_echo "Enabling clvmd gulm cluster manager" >&6; }
 		CLVMD="$CLVMD,gulm"
+		CLVMD_CMANAGERS="$CLVMD_CMANAGERS lock_gulmd"
+		CLVMD_NEEDS_QDISKD=yes
 	fi
 	if test x$HAVE_CMAN = xyes && \
 	   test x$HAVE_DLM = xyes; then
 		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd cman cluster manager" >&5
 $as_echo "Enabling clvmd cman cluster manager" >&6; }
 		CLVMD="$CLVMD,cman"
+		CLVMD_CMANAGERS="$CLVMD_CMANAGERS cman"
+		CLVMD_NEEDS_QDISKD=yes
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_QUORUM = xyes && \
@@ -13834,6 +13852,7 @@
 		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd corosync cluster manager" >&5
 $as_echo "Enabling clvmd corosync cluster manager" >&6; }
 		CLVMD="$CLVMD,corosync"
+		CLVMD_CMANAGERS="$CLVMD_CMANAGERS corosync"
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_CPG = xyes && \
@@ -13841,6 +13860,10 @@
 		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd openais cluster manager" >&5
 $as_echo "Enabling clvmd openais cluster manager" >&6; }
 		CLVMD="$CLVMD,openais"
+		CLVMD_CMANAGERS="$CLVMD_CMANAGERS openais"
+	fi
+	if test x$CLVMD_NEEDS_QDISKD != xno; then
+		CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
 	fi
 	if test x$CLVMD = xnone; then
 		{ $as_echo "$as_me:$LINENO: result: Disabling clvmd build. No cluster manager detected." >&5
@@ -18240,6 +18263,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 



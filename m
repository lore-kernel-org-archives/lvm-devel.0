From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Feb 2009 22:41:14 -0000
Subject: LVM2 ./WHATS_NEW ./configure.in daemons/clvmd/ ...
Message-ID: <20090225224114.17698.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-25 22:41:13

Modified files:
	.              : WHATS_NEW configure.in 
	daemons/clvmd  : Makefile.in 

Log message:
	Use pkgconfig to obtain corosync library details during configuration. (kabi)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1054&r2=1.1055
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2009/02/25 14:33:00	1.1054
+++ LVM2/WHATS_NEW	2009/02/25 22:41:12	1.1055
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Use pkgconfig to obtain corosync library details during configuration.
   Fix error returns in clvmd-corosync interface to DLM.
   Add --refresh to vgchange and vgmknodes man pages.
   Fixed bug where lvresize option -t was not properly passed to fsadm.
--- LVM2/configure.in	2009/02/22 22:11:58	1.95
+++ LVM2/configure.in	2009/02/25 22:41:12	1.96
@@ -338,6 +338,19 @@
 	CLUSTER=internal
 fi
 
+dnl -- Look for corosync libraries if required.
+if [[ "x$CLVMD" = xcorosync -o "x$CLVMD" = xall ]]; then
+	PKG_CHECK_MODULES(QUORUM, libquorum, [],
+		[AC_MSG_RESULT([no pkg for quorum library, using -lquorum]);
+		QUORUM_LIBS="-lquorum"])
+	PKG_CHECK_MODULES(CONFDB, libconfdb, [],
+		[AC_MSG_RESULT([no pkg for confdb library, using -lconfdb]);
+		CONFDB_LIBS="-lconfdb"])
+	PKG_CHECK_MODULES(CPG, libcpg, [],
+		[AC_MSG_RESULT([no pkg for libcpg library, using -lcpg]);
+		CPG_LIBS="-lcpg"])
+fi
+
 ################################################################################
 dnl -- Enable debugging
 AC_MSG_CHECKING(whether to enable debugging)
@@ -742,7 +755,12 @@
 AC_SUBST(CLUSTER)
 AC_SUBST(CLVMD)
 AC_SUBST(CMDLIB)
+AC_SUBST(CONFDB_CFLAGS)
+AC_SUBST(CONFDB_LIBS)
+AC_SUBST(CONFDIR)
 AC_SUBST(COPTIMISE_FLAG)
+AC_SUBST(CPG_CFLAGS)
+AC_SUBST(CPG_LIBS)
 AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
 AC_SUBST(DEVMAPPER)
@@ -768,7 +786,6 @@
 AC_SUBST(LOCALEDIR)
 AC_SUBST(LVM1)
 AC_SUBST(LVM1_FALLBACK)
-AC_SUBST(CONFDIR)
 AC_SUBST(LVM_VERSION)
 AC_SUBST(LVM_MAJOR)
 AC_SUBST(LVM_MINOR)
@@ -780,6 +797,8 @@
 AC_SUBST(OWNER)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
+AC_SUBST(QUORUM_CFLAGS)
+AC_SUBST(QUORUM_LIBS)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
--- LVM2/daemons/clvmd/Makefile.in	2009/02/11 10:13:20	1.27
+++ LVM2/daemons/clvmd/Makefile.in	2009/02/25 22:41:13	1.28
@@ -15,6 +15,13 @@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
+QUORUM_LIBS = @QUORUM_LIBS@
+QUORUM_CFLAGS = @QUORUM_CFLAGS@
+CONFDB_LIBS = @CONFDB_LIBS@
+CONFDB_CFLAGS = @CONFDB_CFLAGS@
+CPG_LIBS = @CPG_LIBS@
+CPG_CFLAGS = @CPG_CFLAGS@
+
 SOURCES = \
 	clvmd-command.c  \
 	clvmd.c          \
@@ -67,9 +74,10 @@
 endif
 
 ifeq ("$(COROSYNC)", "yes")
-        SOURCES += clvmd-corosync.c
-        LMLIBS += -lquorum -lconfdb -lcpg -ldlm
-        DEFS += -DUSE_COROSYNC
+	SOURCES += clvmd-corosync.c
+	LMLIBS += $(QUORUM_LIBS) $(CONFDB_LIBS) $(CPG_LIBS) -ldlm
+	CFLAGS += $(QUORUM_CFLAGS) $(CONFDB_CFLAGS) $(CPG_CFLAGS)
+	DEFS += -DUSE_COROSYNC
 endif
 
 



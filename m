From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Mar 2009 20:00:11 -0000
Subject: LVM2 libdm/Makefile.in scripts/Makefile.in too ...
Message-ID: <20090316200011.2249.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-16 20:00:11

Modified files:
	libdm          : Makefile.in 
	scripts        : Makefile.in 
	tools          : Makefile.in 

Log message:
	Fix some clean rules, fix previous distclean checkin.
	
	In libdm/Makefile.in, we need to cleanup the symlink properly.
	Adding to CLEAN_TARGETS seemed like the simplest way to do this
	in the current build framework.  We could redo dependencies for
	VERSIONED_SHLIB, but for now just add to CLEAN_TARGETS.
	
	For scripts/Makefile.in, we should be adding to DISTCLEAN_TARGETS.
	The generic rule in make.tmpl.in takes care of the cleanup.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Author: Takahiro Yasui <tyasui@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/libdm/Makefile.in	2008/11/14 20:59:56	1.43
+++ LVM2/libdm/Makefile.in	2009/03/16 20:00:10	1.44
@@ -98,6 +98,8 @@
 	rm -f libdevmapper.$(LIB_SUFFIX)
 	$(LN_S) $< libdevmapper.$(LIB_SUFFIX)
 
+CLEAN_TARGETS += libdevmapper.$(LIB_SUFFIX)
+
 .PHONY: distclean_lib distclean
 
 distclean_lib:
--- LVM2/scripts/Makefile.in	2009/03/16 18:28:05	1.5
+++ LVM2/scripts/Makefile.in	2009/03/16 20:00:10	1.6
@@ -25,5 +25,4 @@
 		$(sbindir)/fsadm
 endif
 
-distclean:
-	$(RM) Makefile clvmd_init_red_hat
+DISTCLEAN_TARGETS += clvmd_init_red_hat
--- LVM2/tools/Makefile.in	2009/03/06 16:17:28	1.92
+++ LVM2/tools/Makefile.in	2009/03/16 20:00:11	1.93
@@ -82,7 +82,7 @@
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
 		lvm.cflow lvm.xref lvm.tree lvm.rxref lvm.rtree \
-		lvmcmdlib.o lvm-static.o dmsetup.o
+		lvmcmdlib.o lvm-static.o dmsetup.o dmsetup
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.$(LIB_SUFFIX)



From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 May 2009 10:13:28 -0000
Subject: LVM2/tools Makefile.in
Message-ID: <20090511101328.14693.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-11 10:13:28

Modified files:
	tools          : Makefile.in 

Log message:
	Fix device-mapper static build targets.
	
	dmsetup.static is not built and cleaned properly
	if running only device-mapper install/build.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/tools/Makefile.in	2009/04/15 14:42:27	1.95
+++ LVM2/tools/Makefile.in	2009/05/11 10:13:28	1.96
@@ -66,12 +66,15 @@
 	.commands \
 	lvm
 
+TARGETS_DM = dmsetup
+
 INSTALL_LVM_TARGETS = install_tools_dynamic
 INSTALL_DMSETUP_TARGETS = install_dmsetup_dynamic
 INSTALL_CMDLIB_TARGETS = install_cmdlib_dynamic
 
 ifeq ("@STATIC_LINK@", "yes")
-  TARGETS += lvm.static dmsetup.static
+  TARGETS += lvm.static
+  TARGETS_DM += dmsetup.static
   INSTALL_LVM_TARGETS += install_tools_static
   INSTALL_DMSETUP_TARGETS += install_dmsetup_static
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
@@ -82,7 +85,7 @@
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
 		lvm.cflow lvm.xref lvm.tree lvm.rxref lvm.rtree \
-		lvmcmdlib.o lvm-static.o dmsetup.o dmsetup
+		lvmcmdlib.o lvm-static.o dmsetup.o $(TARGETS_DM)
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.$(LIB_SUFFIX)
@@ -99,7 +102,7 @@
 
 include $(top_srcdir)/make.tmpl
 
-device-mapper: dmsetup
+device-mapper: $(TARGETS_DM)
 
 dmsetup: dmsetup.o $(top_srcdir)/libdm/libdevmapper.$(LIB_SUFFIX)
 	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) \



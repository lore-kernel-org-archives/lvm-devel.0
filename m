From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 Apr 2009 14:42:28 -0000
Subject: LVM2/tools Makefile.in
Message-ID: <20090415144228.32255.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-15 14:42:28

Modified files:
	tools          : Makefile.in 

Log message:
	Fix dmsetup.static build.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/tools/Makefile.in	2009/04/08 14:08:05	1.94
+++ LVM2/tools/Makefile.in	2009/04/15 14:42:27	1.95
@@ -71,7 +71,7 @@
 INSTALL_CMDLIB_TARGETS = install_cmdlib_dynamic
 
 ifeq ("@STATIC_LINK@", "yes")
-  TARGETS += lvm.static
+  TARGETS += lvm.static dmsetup.static
   INSTALL_LVM_TARGETS += install_tools_static
   INSTALL_DMSETUP_TARGETS += install_dmsetup_static
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static



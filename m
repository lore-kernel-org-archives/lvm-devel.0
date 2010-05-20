From: agk@sourceware.org <agk@sourceware.org>
Date: 20 May 2010 22:54:59 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20100520225459.6200.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-20 22:54:59

Modified files:
	.              : make.tmpl.in 

Log message:
	Fix $(INSTALL_SCRIPT)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/make.tmpl.in	2010/05/20 14:45:14	1.101
+++ LVM2/make.tmpl.in	2010/05/20 22:54:58	1.102
@@ -103,7 +103,7 @@
 INSTALL_DIR = $(INSTALL) -m 0755 -d
 INSTALL_ROOT_DIR = $(INSTALL) -m 0700 -d
 INSTALL_ROOT_DATA = $(INSTALL) -m 0600
-INSTALL_SCRIPT = $(INSTALL) -p -m $(M_INSTALL_PROGRAM)
+INSTALL_SCRIPT = $(INSTALL) -p $(M_INSTALL_PROGRAM)
 
 .SUFFIXES: .c .d .o .so .a .po .pot .mo .dylib
 



From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Apr 2009 20:46:07 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20090420204607.17995.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-04-20 20:46:06

Modified files:
	test/api       : Makefile.in 

Log message:
	Add libdevmapper to test/api building.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/api/Makefile.in	2009/03/08 17:29:27	1.3
+++ LVM2/test/api/Makefile.in	2009/04/20 20:46:06	1.4
@@ -25,7 +25,7 @@
 
 TARGETS = test
 
-LVMLIBS = -llvm
+LVMLIBS = -llvm -ldevmapper
 
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing



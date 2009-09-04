From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 4 Sep 2009 13:49:03 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20090904134903.20005.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-04 13:49:02

Modified files:
	test/api       : Makefile.in 

Log message:
	Remove 'test' interative api unit tests from 'TARGET' line.
	
	The test/api directory TARGET line will be reserved for non-interactive
	unit tests.  Building the interactive test can still be done with "make test"
	from the test/api dir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/api/Makefile.in	2009/07/21 13:51:05	1.7
+++ LVM2/test/api/Makefile.in	2009/09/04 13:49:02	1.8
@@ -19,7 +19,7 @@
 	DEFS += -DDEBUG
 endif
 
-TARGETS = test vgtest
+TARGETS = vgtest
 test_SOURCES = test.c
 vgtest_SOURCES = vgtest.c
 INCLUDES += -I${top_srcdir}/include



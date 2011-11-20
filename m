From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Nov 2011 21:55:25 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20111120215525.32630.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-11-20 21:55:25

Modified files:
	test           : Makefile.in 

Log message:
	Fix a syntax error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/test/Makefile.in	2011/11/20 21:43:20	1.61
+++ LVM2/test/Makefile.in	2011/11/20 21:55:24	1.62
@@ -43,7 +43,7 @@
 all: check
 
 check: .tests-stamp
-	@echo Running API (liblvm2app) tests
+	@echo "Running API (liblvm2app) tests"
 	make -C api tests
 ifeq ("$(TESTING)", "yes")
 	@echo Running unit tests



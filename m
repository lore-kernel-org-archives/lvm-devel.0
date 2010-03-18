From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Mar 2010 09:28:44 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20100318092844.13741.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-03-18 09:28:43

Modified files:
	test           : Makefile.in 

Log message:
	Run both locking_type 1 and 3 tests (forgot to uncomment locking_type 1 before
	last checkin).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/test/Makefile.in	2010/03/18 09:19:33	1.27
+++ LVM2/test/Makefile.in	2010/03/18 09:28:42	1.28
@@ -43,7 +43,7 @@
 
 all: init.sh
 	@echo Testing with locking_type 1
-	#./bin/harness t-*.sh
+	./bin/harness t-*.sh
 	@echo Testing with locking_type 3
 	LVM_TEST_LOCKING=3 ./bin/harness t-*.sh
 



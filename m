From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Apr 2010 13:28:55 -0000
Subject: LVM2 ./Makefile.in test/Makefile.in
Message-ID: <20100413132855.25616.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-13 13:28:53

Modified files:
	.              : Makefile.in 
	test           : Makefile.in 

Log message:
	Add check_cluster and check_local targets in addition to just "check".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/Makefile.in	2010/04/09 21:34:25	1.51
+++ LVM2/Makefile.in	2010/04/13 13:28:52	1.52
@@ -75,8 +75,8 @@
 endif
 DISTCLEAN_TARGETS += cscope.out
 
-check: all
-	$(MAKE) -C test all
+check check_cluster check_local: all
+	$(MAKE) -C test $(@)
 
 LCOV_TRACES = libdm.info lib.info tools.info \
 	daemons/dmeventd.info daemons/clvmd.info
--- LVM2/test/Makefile.in	2010/04/13 06:45:53	1.37
+++ LVM2/test/Makefile.in	2010/04/13 13:28:53	1.38
@@ -46,12 +46,20 @@
 	$(MAKE) -C api vgtest
 endif
 
-all: init.sh
+all check: init.sh
 	@echo Testing with locking_type 1
 	./bin/harness $(RUN)
 	@echo Testing with locking_type 3
 	LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
 
+check_cluster: init.sh
+	@echo Testing with locking_type 3
+	LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
+
+check_local: init.sh
+	@echo Testing with locking_type 1
+	LVM_TEST_LOCKING=1 ./bin/harness $(RUN)
+
 bin/not: $(srcdir)/not.c .bin-dir-stamp
 	$(CC) -o bin/not $<
 



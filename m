From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Dec 2010 21:08:01 -0000
Subject: LVM2/test Makefile.in api/Makefile.in
Message-ID: <20101212210801.23709.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-12-12 21:08:00

Modified files:
	test           : Makefile.in 
	test/api       : Makefile.in 

Log message:
	Only build the required bits under api/ on make check.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/test/Makefile.in	2010/12/12 20:36:38	1.45
+++ LVM2/test/Makefile.in	2010/12/12 21:08:00	1.46
@@ -42,19 +42,19 @@
 endif
 
 all check: init.sh
-	make -C api
+	make -C api tests
 	@echo Testing with locking_type 1
 	VERBOSE=$(VERBOSE) ./bin/harness $(RUN_BASE)
 	@echo Testing with locking_type 3
 	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./bin/harness $(RUN_BASE)
 
 check_cluster: init.sh
-	make -C api
+	make -C api tests
 	@echo Testing with locking_type 3
 	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./bin/harness $(RUN_BASE)
 
 check_local: init.sh
-	make -C api
+	make -C api tests
 	@echo Testing with locking_type 1
 	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=1 ./bin/harness $(RUN_BASE)
 
--- LVM2/test/api/Makefile.in	2010/12/12 20:49:38	1.16
+++ LVM2/test/api/Makefile.in	2010/12/12 21:08:00	1.17
@@ -44,7 +44,9 @@
 wrapper_OBJECTS = $(wrapper_SOURCES:.c=.o)
 OBJECTS = $(test_OBJECTS)
 
-all: $(UNIT) test
+all: tests test
+
+tests: $(UNIT)
 
 test: $(test_OBJECTS) $(DEPLIBS)
 	$(CC) -o test $(test_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(READLINE_LIBS)



From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Oct 2010 14:36:27 -0000
Subject: LVM2/test Makefile.in harness.c
Message-ID: <20101014143627.12501.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-14 14:36:26

Modified files:
	test           : Makefile.in harness.c 

Log message:
	Add a VERBOSE option to make check (make check VERBOSE=1).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/test/Makefile.in	2010/10/12 16:17:25	1.43
+++ LVM2/test/Makefile.in	2010/10/14 14:36:26	1.44
@@ -27,6 +27,7 @@
 
 T ?= .
 S ?= @ # never match anything by default
+VERBOSE ?= 0
 RUN = $(shell find -regextype posix-egrep -name t-\*.sh -and -regex ".*($(T)).*" -and -not -regex ".*($(S)).*" | sort)
 
 # Shell quote;
@@ -49,17 +50,17 @@
 
 all check: init.sh
 	@echo Testing with locking_type 1
-	./bin/harness $(RUN)
+	VERBOSE=$(VERBOSE) ./bin/harness $(RUN)
 	@echo Testing with locking_type 3
-	LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
+	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
 
 check_cluster: init.sh
 	@echo Testing with locking_type 3
-	LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
+	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
 
 check_local: init.sh
 	@echo Testing with locking_type 1
-	LVM_TEST_LOCKING=1 ./bin/harness $(RUN)
+	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=1 ./bin/harness $(RUN)
 
 bin/not: $(srcdir)/not.c .bin-dir-stamp
 	$(CC) -o bin/not $<
--- LVM2/test/harness.c	2010/07/28 12:20:41	1.13
+++ LVM2/test/harness.c	2010/10/14 14:36:26	1.14
@@ -39,6 +39,7 @@
 int readbuf_sz = 0, readbuf_used = 0;
 
 int die = 0;
+int verbose = 0;
 
 #define PASSED 0
 #define SKIPPED 1
@@ -64,6 +65,8 @@
 	char buf[2048];
 	while (1) {
 		sz = read(fds[1], buf, 2048);
+		if (verbose)
+			write(1, buf, sz);
 		if (sz <= 0)
 			return;
 		if (readbuf_used + sz >= readbuf_sz) {
@@ -164,7 +167,10 @@
 	s.nwarned = s.nfailed = s.npassed = s.nskipped = 0;
 
 	char *config = getenv("LVM_TEST_CONFIG"),
-	     *config_debug;
+		*config_debug,
+		*be_verbose = getenv("VERBOSE");
+	if (be_verbose && atoi(be_verbose))
+		verbose = 1; // XXX
 	config = config ? config : "";
 	asprintf(&config_debug, "%s\n%s\n", config, "log { verbose=4 }");
 



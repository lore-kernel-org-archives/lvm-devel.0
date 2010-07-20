From: thornber@sourceware.org <thornber@sourceware.org>
Date: 20 Jul 2010 15:21:34 -0000
Subject: LVM2 ./Makefile.in ./configure.in unit-tests/r ...
Message-ID: <20100720152134.19409.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-20 15:21:33

Modified files:
	.              : Makefile.in configure.in 
Added files:
	unit-tests/regex: TESTS matcher_t.expected 

Log message:
	Wire the regex tests up to the reports

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/TESTS.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/matcher_t.expected.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/Makefile.in	2010/07/20 14:38:44	1.56
+++ LVM2/Makefile.in	2010/07/20 15:21:32	1.57
@@ -135,6 +135,7 @@
 .PHONEY: unit-test ruby-test test-programs
 
 test-programs:
+	$(MAKE) unit-tests/regex
 
 unit-test: test-programs
 	$(RUBY) report-generators/unit_test.rb $(shell find . -name TESTS)
--- LVM2/configure.in	2010/07/20 14:38:44	1.147
+++ LVM2/configure.in	2010/07/20 15:21:32	1.148
@@ -1333,6 +1333,7 @@
 test/api/Makefile
 tools/Makefile
 udev/Makefile
+unit-tests/regex/Makefile
 ])
 AC_OUTPUT
 
/cvs/lvm2/LVM2/unit-tests/regex/TESTS,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/regex/TESTS
+++ -	2010-07-20 15:21:33.989435000 +0000
@@ -0,0 +1 @@
+dfa matching:$TEST_TOOL ./matcher_t dev_patterns < devices.list > matcher_t.output && diff -u matcher_t.expected matcher_t.output
\ No newline at end of file
/cvs/lvm2/LVM2/unit-tests/regex/matcher_t.expected,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/regex/matcher_t.expected
+++ -	2010-07-20 15:21:34.143931000 +0000
@@ -0,0 +1,16 @@
+Matcher built with 23 dfa states
+/dev/loop/0 : loop/[0-9]+
+/dev/loop/1 : loop/[0-9]+
+/dev/loop/2 : loop/[0-9]+
+/dev/loop/3 : loop/[0-9]+
+/dev/loop/4 : loop/[0-9]+
+/dev/loop/5 : loop/[0-9]+
+/dev/loop/6 : loop/[0-9]+
+/dev/loop/7 : loop/[0-9]+
+/dev/hda1 : hd[a-d][0-5]+
+/dev/hda2 : hd[a-d][0-5]+
+/dev/hda3 : hd[a-d][0-5]+
+/dev/hda4 : hd[a-d][0-5]+
+/dev/hda5 : hd[a-d][0-5]+
+/dev/hdb1 : hd[a-d][0-5]+
+/dev/hdc1 : hd[a-d][0-5]+



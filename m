From: thornber@sourceware.org <thornber@sourceware.org>
Date: 9 Aug 2010 10:27:32 -0000
Subject: LVM2/unit-tests/regex TESTS matcher_t.expected ...
Message-ID: <20100809102732.18003.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-08-09 10:27:31

Modified files:
	unit-tests/regex: TESTS 
Added files:
	unit-tests/regex: matcher_t.expected3 nonprint_input 
	                  nonprint_regexes 

Log message:
	[REGEX] add a unit test for regexes containing chars with value over x80

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/matcher_t.expected3.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/nonprint_input.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/nonprint_regexes.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/TESTS.diff?cvsroot=lvm2&r1=1.2&r2=1.3

/cvs/lvm2/LVM2/unit-tests/regex/matcher_t.expected3,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/regex/matcher_t.expected3
+++ -	2010-08-09 10:27:31.742849000 +0000
@@ -0,0 +1,3 @@
+foo?bar : ?
+foo?b : foo?b
+? : ?
/cvs/lvm2/LVM2/unit-tests/regex/nonprint_input,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/regex/nonprint_input
+++ -	2010-08-09 10:27:31.834496000 +0000
@@ -0,0 +1,4 @@
+foo.bar
+foo?bar
+foo?b
+?
/cvs/lvm2/LVM2/unit-tests/regex/nonprint_regexes,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/regex/nonprint_regexes
+++ -	2010-08-09 10:27:31.920879000 +0000
@@ -0,0 +1,3 @@
+"foo?bar"
+"foo?b"
+"?"
--- LVM2/unit-tests/regex/TESTS	2010/07/21 11:52:46	1.2
+++ LVM2/unit-tests/regex/TESTS	2010/08/09 10:27:31	1.3
@@ -1,2 +1,3 @@
-dfa matching:$TEST_TOOL ./matcher_t dev_patterns < devices.list > matcher_t.output && diff -u matcher_t.expected matcher_t.output
-dfa matching:$TEST_TOOL ./matcher_t random_regexes < /dev/null > matcher_t.output && diff -u matcher_t.expected2 matcher_t.output
\ No newline at end of file
+dfa matching:$TEST_TOOL ./matcher_t --fingerprint dev_patterns < devices.list > matcher_t.output && diff -u matcher_t.expected matcher_t.output
+dfa matching:$TEST_TOOL ./matcher_t --fingerprint random_regexes < /dev/null > matcher_t.output && diff -u matcher_t.expected2 matcher_t.output
+dfa with non-print regex chars:$TEST_TOOL ./matcher_t nonprint_regexes < nonprint_input > matcher_t.output && diff -u matcher_t.expected3 matcher_t.output
\ No newline at end of file



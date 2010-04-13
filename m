From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Apr 2010 07:33:35 -0000
Subject: LVM2/test harness.c
Message-ID: <20100413073335.21140.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-13 07:33:34

Modified files:
	test           : harness.c 

Log message:
	Optionally disable the verbose repeat of a failed test (export
	LVM_TEST_NOVERBOSE=1).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/harness.c	2010/04/07 09:48:11	1.8
+++ LVM2/test/harness.c	2010/04/13 07:33:34	1.9
@@ -133,6 +133,7 @@
 
 int main(int argc, char **argv) {
 	int i;
+	int repeat = getenv("LVM_TEST_NOVERBOSE") ? 0 : 1;
 
 	if (argc >= MAX) {
 		fprintf(stderr, "Sorry, my head exploded. Please increase MAX.\n");
@@ -168,7 +169,7 @@
 		run(i, argv[i]);
 		if (die)
 			break;
-		if ( s.status[i] == FAILED ) {
+		if ( repeat && s.status[i] == FAILED ) {
 			backup = s;
 			setenv("LVM_TEST_CONFIG", config_debug, 1);
 			run(i, argv[i]);



From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 4 Nov 2008 14:37:53 -0000
Subject: LVM2/test harness.sh
Message-ID: <20081104143753.7394.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-04 14:37:52

Modified files:
	test           : harness.sh 

Log message:
	Also report the tests that have been skipped, at the end of harness.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/harness.sh	2008/10/06 16:55:29	1.4
+++ LVM2/test/harness.sh	2008/11/04 14:37:51	1.5
@@ -10,6 +10,7 @@
     if test $ret = 0; then
 	echo " passed."
     elif test $ret = 200; then
+        skipped="$skipped $t"
 	echo " skipped."
     else
 	echo " FAILED!"
@@ -25,6 +26,10 @@
 done
 
 if test -n "$failed"; then
+    echo "Tests skipped:"
+    for t in $skipped; do
+	printf "\t%s\n" $t
+    done
     echo "TESTS FAILED:"
     for t in $failed; do
 	printf "\t%s\n" $t



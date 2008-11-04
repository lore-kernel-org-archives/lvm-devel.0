From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 4 Nov 2008 14:38:53 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20081104143853.11918.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-04 14:38:53

Modified files:
	test           : test-utils.sh 

Log message:
	Fix typo.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/test-utils.sh	2008/10/14 19:48:01	1.4
+++ LVM2/test/test-utils.sh	2008/11/04 14:38:53	1.5
@@ -83,9 +83,10 @@
 				LOOP=$dev
 			done
 		done
-		test -n "LOOP" # confirm or fail
+		test -n "$LOOP" # confirm or fail
+		return 0
 	fi
-	exit 1 # should not be accesible
+	exit 1 # should not happen
 }
 
 prepare_devs() {



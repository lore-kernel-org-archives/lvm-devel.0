From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Mar 2010 09:27:40 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100318092740.13415.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-03-18 09:27:40

Modified files:
	test           : test-utils.sh 

Log message:
	Skip locking_type 3 tests instead of failing when system-wide clvmd is running.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/test/test-utils.sh	2010/03/18 09:19:33	1.23
+++ LVM2/test/test-utils.sh	2010/03/18 09:27:39	1.24
@@ -61,7 +61,7 @@
 
 	if pgrep clvmd ; then
 		echo "Cannot use fake cluster locking with real clvmd ($(pgrep clvmd)) running."
-		exit 1
+		exit 200
 	fi
 
 	# skip if we don't have our own clvmd...



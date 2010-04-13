From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Apr 2010 21:42:45 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh
Message-ID: <20100413214245.15474.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-13 21:42:45

Modified files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	Fix teardown in t-pvcreate-operation-md.sh nightly test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/t-pvcreate-operation-md.sh	2010/01/19 15:59:34	1.4
+++ LVM2/test/t-pvcreate-operation-md.sh	2010/04/13 21:42:44	1.5
@@ -41,7 +41,7 @@
 	sleep 2
 	rm -f $mddev
     fi
-    teardown_
+    teardown
 }
 
 # create 2 disk MD raid0 array (stripe_width=128K)



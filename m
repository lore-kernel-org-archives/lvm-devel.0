From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Jul 2009 12:42:27 -0000
Subject: LVM2/test t-000-basic.sh
Message-ID: <20090713124227.26232.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-07-13 12:42:27

Modified files:
	test           : t-000-basic.sh 

Log message:
	Get rid of the mdadm presence check in t-000-basic: no actual test uses
	it. When we need mdadm in the tests, we can easily do 'which mdadm || exit 200'
	to skip the test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-000-basic.sh	2009/02/22 22:11:59	1.6
+++ LVM2/test/t-000-basic.sh	2009/07/13 12:42:26	1.7
@@ -20,10 +20,6 @@
 # ensure they are the same
 diff -u actual expected
 
-# Need mdadm for some pvcreate tests
-# verify mdadm is installed and in path (needed for pvcreate tests) ... is it?
-which mdadm
-
 mknod $G_root_/dev/null c 1 3 ||
   error "Can't create nodes on filesystem"
 echo >$G_root_/dev/null || 



From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 Sep 2009 19:28:01 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh
Message-ID: <20090913192801.1983.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-09-13 19:28:00

Modified files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	Do not run mdadm tests if MD module is not loaded.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-pvcreate-operation-md.sh	2009/08/04 16:02:39	1.1
+++ LVM2/test/t-pvcreate-operation-md.sh	2009/09/13 19:28:00	1.2
@@ -14,6 +14,7 @@
 which perl || exit 200
 which awk || exit 200
 which cut || exit 200
+test -f /proc/mdstat || exit 200
 
 . ./test-utils.sh
 



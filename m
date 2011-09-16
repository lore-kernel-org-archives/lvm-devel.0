From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Sep 2011 11:52:33 -0000
Subject: LVM2/test t-lvcreate-pvtags.sh
Message-ID: <20110916115233.19273.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-16 11:52:33

Modified files:
	test           : t-lvcreate-pvtags.sh 

Log message:
	Remove vg at the test's end
	
	Speedup this test by removing mirrored vg when it's not longer needed.
	teardown() seems to be waiting here for too long.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/t-lvcreate-pvtags.sh	2011/02/28 19:44:21	1.9
+++ LVM2/test/t-lvcreate-pvtags.sh	2011/09/16 11:52:33	1.10
@@ -43,3 +43,5 @@
 
 # lvcreate mirror with a single PV arg
 not lvcreate -l1 -m1 --corelog $vg $dev1
+
+vgremove -ff $vg



From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 16:13:40 -0000
Subject: LVM2/test t-inconsistent-metadata.sh
Message-ID: <20110128161340.2112.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 16:13:39

Modified files:
	test           : t-inconsistent-metadata.sh 

Log message:
	Lower disk space usage of inconsistent mda test
	
	Smaller size of devices speedups this test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/t-inconsistent-metadata.sh	2011/01/05 00:16:20	1.5
+++ LVM2/test/t-inconsistent-metadata.sh	2011/01/28 16:13:39	1.6
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux prepare_vg 3
+aux prepare_vg 3 12
 
 lvcreate -m 1 -l 1 -n mirror $vg
 lvcreate -l 1 -n resized $vg



From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 17 May 2012 12:03:31 -0000
Subject: LVM2/test/shell activate-missing-segment.sh
Message-ID: <20120517120331.32304.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-05-17 12:03:30

Modified files:
	test/shell     : activate-missing-segment.sh 

Log message:
	Partial activation working, expect success in tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/activate-missing-segment.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/shell/activate-missing-segment.sh	2012/05/16 10:44:36	1.1
+++ LVM2/test/shell/activate-missing-segment.sh	2012/05/17 12:03:30	1.2
@@ -19,7 +19,6 @@
 . lib/test
 
 aux prepare_vg 2
-aux expect_failure
 
 lvcreate -l100%FREE -n span $vg
 vgchange -a n $vg



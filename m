From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Apr 2010 14:25:08 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100406142508.14958.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-06 14:25:08

Modified files:
	test           : test-utils.sh 

Log message:
	Display PVs created during tests

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/test/test-utils.sh	2010/03/31 22:18:17	1.27
+++ LVM2/test/test-utils.sh	2010/04/06 14:25:07	1.28
@@ -307,6 +307,7 @@
 prepare_vg() {
 	prepare_pvs "$@"
 	vgcreate -c n $vg $devs
+	pvs -v
 }
 
 prepare_lvmconf() {



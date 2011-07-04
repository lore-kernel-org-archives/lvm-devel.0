From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Jul 2011 16:27:28 -0000
Subject: LVM2/test t-vgreduce-usage.sh
Message-ID: <20110704162728.7856.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-04 16:27:27

Modified files:
	test           : t-vgreduce-usage.sh 

Log message:
	first attempt to fix test

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-usage.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-vgreduce-usage.sh	2011/01/05 00:16:20	1.7
+++ LVM2/test/t-vgreduce-usage.sh	2011/07/04 16:27:27	1.8
@@ -63,6 +63,7 @@
 # cleanup
 aux enable_dev $dev1
 vgremove -ff $vg1
+vgremove -ff $vg1
 
 #COMM "vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too"
 # (lvm$mdatype) setup: create mirror + linear lvs



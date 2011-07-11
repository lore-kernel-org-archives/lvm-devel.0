From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 11 Jul 2011 12:13:08 -0000
Subject: LVM2/test t-vgreduce-usage.sh
Message-ID: <20110711121308.31893.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-11 12:13:08

Modified files:
	test           : t-vgreduce-usage.sh 

Log message:
	Fix t-vgreduce-usage to stop relying on the persistent cache not seeing a
	device that has been brought back from the dead: this sometimes fails with
	clvmd (the cache is updated "too soon"). Instead, force a pvscan and rely on an
	up-to-date cache as usual.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-usage.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-vgreduce-usage.sh	2011/07/04 16:27:27	1.8
+++ LVM2/test/t-vgreduce-usage.sh	2011/07/11 12:13:07	1.9
@@ -62,8 +62,9 @@
 check pvlv_counts $vg1 2 3 0
 # cleanup
 aux enable_dev $dev1
+pvscan
 vgremove -ff $vg1
-vgremove -ff $vg1
+not vgs $vg1 # just double-check it's really gone
 
 #COMM "vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too"
 # (lvm$mdatype) setup: create mirror + linear lvs



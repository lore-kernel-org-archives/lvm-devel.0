From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Sep 2008 16:06:10 -0000
Subject: LVM2/test t-unlost-pv.sh
Message-ID: <20080929160610.21542.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-29 16:06:10

Added files:
	test           : t-unlost-pv.sh 

Log message:
	Add a test for reappearing lost PVs causing endless metadata correction
	updates. (A problem Milan fixed recently.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-unlost-pv.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-unlost-pv.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-unlost-pv.sh
+++ -	2008-09-29 16:06:10.518398000 +0000
@@ -0,0 +1,28 @@
+. ./test-utils.sh
+
+aux prepare_vg 3
+
+lvcreate -m 1 -l 1 -n mirror $vg
+lvchange -a n $vg/mirror
+
+check() {
+vgscan 2>&1 | tee vgscan.out
+grep "Inconsistent metadata found for VG $vg" vgscan.out
+vgscan 2>&1 | tee vgscan.out
+not grep "Inconsistent metadata found for VG $vg" vgscan.out
+}
+
+# try orphaning a missing PV
+disable_dev $dev1
+vgreduce --removemissing --force $vg
+enable_dev $dev1
+check
+
+exit 0 # FIXME, bug demonstration code follows
+# try to just change metadata; we expect the new version (with MISSING_PV set
+# on the reappeared volume) to be written out to the previously missing PV
+vgextend $vg $dev1
+disable_dev $dev1
+lvremove $vg/mirror
+enable_dev $dev1
+check



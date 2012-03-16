From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 12:56:30 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20120316125630.22462.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 12:56:29

Modified files:
	test/lib       : aux.sh 

Log message:
	Allow to use also special prefixed names for test
	
	Currently we could not test special prefixes in our test suite.
	As teardown will not find such device and basicaly busyloops here,
	as at cannot remove such names.
	
	This patch adds possibity to use:
	
	vgcreate  V_$vg1 $dev
	
	Note: you still need to use $PREFIX somewhere in the name.
	(And of course, it's really bad idea to use $PREFIX (=LVMTEST)
	for normally used LVs)
	
	The only purpose of this patch is to allow testing cluster with
	special vg names that begins with V_ , P_....

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/test/lib/aux.sh	2012/03/06 02:54:31	1.41
+++ LVM2/test/lib/aux.sh	2012/03/16 12:56:29	1.42
@@ -92,8 +92,8 @@
 		rm -rf $TESTDIR/dev/$PREFIX*
 
 		init_udev_transaction
-		while dmsetup table | grep -q ^$PREFIX; do
-			for s in `dmsetup info -c -o name --noheading | grep ^$PREFIX`; do
+		while dmsetup table | grep -q $PREFIX; do
+			for s in `dmsetup info -c -o name --noheading | grep $PREFIX`; do
 				umount -fl $DM_DEV_DIR/mapper/$s >& /dev/null || true
 				dmsetup remove -f $s >& /dev/null || true
 			done



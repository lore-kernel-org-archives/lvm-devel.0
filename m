From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Dec 2008 16:16:54 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20081210161654.23913.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-12-10 16:16:54

Modified files:
	test           : test-utils.sh 

Log message:
	operate on test subdirectory instead on main /dev

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/test-utils.sh	2008/12/05 05:03:23	1.7
+++ LVM2/test/test-utils.sh	2008/12/10 16:16:53	1.8
@@ -33,7 +33,7 @@
 	echo $PREFIX
 
 	test -n "$PREFIX" && {
-		rm -rf /dev/$PREFIX*
+		rm -rf $G_root_/dev/$PREFIX*
 		while dmsetup table | grep -q ^$PREFIX; do
 			for s in `dmsetup table | grep ^$PREFIX| cut -f1 -d:`; do
 				dmsetup resume $s 2>/dev/null > /dev/null || true
@@ -52,7 +52,7 @@
 make_ioerror() {
 	echo 0 10000000 error | dmsetup create ioerror
 	dmsetup resume ioerror
-	ln -s /dev/mapper/ioerror /dev/ioerror
+	ln -s $G_dev_/mapper/ioerror $G_dev_/ioerror
 }
 
 prepare_loop() {



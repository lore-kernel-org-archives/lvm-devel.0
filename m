From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Feb 2010 19:43:23 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100201194323.12195.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-01 19:43:23

Modified files:
	test           : test-utils.sh 

Log message:
	Remove unnecessary "dmsetup resume" after "dmsetup create".
	
	It is not necessary to resume after a create since the create will
	create the table and make it active.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/test/test-utils.sh	2010/01/19 16:44:57	1.18
+++ LVM2/test/test-utils.sh	2010/02/01 19:43:22	1.19
@@ -59,7 +59,6 @@
 
 make_ioerror() {
 	echo 0 10000000 error | dmsetup create ioerror
-	dmsetup resume ioerror
 	ln -s $G_dev_/mapper/ioerror $G_dev_/ioerror
 }
 
@@ -188,7 +187,6 @@
 		devs="$devs $dev"
 		echo 0 $size linear $LOOP $((($i-1)*$size)) > $name.table
 		dmsetup create $name $name.table
-		dmsetup resume $name
 	done
 
     # set up some default names



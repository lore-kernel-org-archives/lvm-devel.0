From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 12:33:19 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110629123319.25785.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 12:33:19

Modified files:
	test/lib       : aux.sh 

Log message:
	use dmsetup remove -f as a better way of simulating a device "disappearing"

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/test/lib/aux.sh	2011/06/28 00:38:26	1.13
+++ LVM2/test/lib/aux.sh	2011/06/29 12:33:18	1.14
@@ -260,11 +260,7 @@
 
 	init_udev_transaction
 	for dev in "$@"; do
-        # first we make the device inaccessible
-		echo 0 10000000 error | dmsetup load $dev
-		dmsetup resume $dev
-        # now let's try to get rid of it if it's unused
-        #dmsetup remove $dev
+        	dmsetup remove -f $dev
 	done
 	finish_udev_transaction
 



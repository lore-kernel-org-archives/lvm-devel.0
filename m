From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jul 2011 10:05:43 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110708100543.16319.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-07-08 10:05:43

Modified files:
	test/lib       : aux.sh 

Log message:
	Increase timeout for udev settle
	
	For some unknown reason (atm) udev settle takes longer time on recent rawhide.
	To pass the test - inrease the settle timeout.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/test/lib/aux.sh	2011/07/01 14:09:20	1.26
+++ LVM2/test/lib/aux.sh	2011/07/08 10:05:43	1.27
@@ -426,7 +426,7 @@
 	if test -n "$1" ; then
 		udevadm settle --exit-if-exists=$1
 	else
-		udevadm settle --timeout=5 
+		udevadm settle --timeout=15
 	fi
 }
 



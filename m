From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Aug 2010 13:23:03 -0000
Subject: LVM2/test t-lock-blocking.sh
Message-ID: <20100802132303.11088.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-02 13:23:02

Modified files:
	test           : t-lock-blocking.sh 

Log message:
	Minor speedup of lock test -
	Instead of waiting for flock process finish kill the flock process.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lock-blocking.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-lock-blocking.sh	2010/06/24 07:57:54	1.1
+++ LVM2/test/t-lock-blocking.sh	2010/08/02 13:23:01	1.2
@@ -33,4 +33,4 @@
 flock_pid=`jobs -p`
 not vgremove --config 'global { wait_for_locks = 0 }' $vg
 ps $flock_pid # still running
-wait $flock_pid
+kill $flock_pid



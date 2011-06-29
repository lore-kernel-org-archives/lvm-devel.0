From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 17:37:32 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110629173732.16767.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 17:37:30

Modified files:
	test/lib       : aux.sh 

Log message:
	print any loop devs that weren't torn down

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/test/lib/aux.sh	2011/06/29 17:33:39	1.16
+++ LVM2/test/lib/aux.sh	2011/06/29 17:37:30	1.17
@@ -89,6 +89,9 @@
 
 	# Delete any remaining dm/udev semaphores
 	dmsetup udevcomplete_all -y
+
+	# Display any loop devices that failed to get torn down
+	losetup -a
 }
 
 teardown() {



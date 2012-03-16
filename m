From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 19:11:30 -0000
Subject: LVM2/test/shell dmeventd-restart.sh
Message-ID: <20120316191130.21907.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 19:11:30

Modified files:
	test/shell     : dmeventd-restart.sh 

Log message:
	Skip dmeventd restart test
	
	If dmevendt is not in /sbin, do not try to run restarting test.
	FIXME: add some workaround for testing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/dmeventd-restart.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/dmeventd-restart.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/dmeventd-restart.sh	2012/03/16 19:11:29	1.3
@@ -14,6 +14,12 @@
 which mkfs.ext2 || skip
 
 aux prepare_dmeventd
+
+# Currently dmeventd doesn't support any other location
+# for dmeventd restart, so FIXME in dmeventd
+# and update this check
+test -x /sbin/dmeventd || skip
+
 aux prepare_vg 5
 
 lvcreate -m 3 --ig -L 1 -n 4way $vg



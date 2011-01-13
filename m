From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Jan 2011 14:57:18 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110113145718.12588.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-13 14:57:18

Modified files:
	test/lib       : aux.sh 

Log message:
	Enable monitoring for cluster tests

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/lib/aux.sh	2011/01/12 16:07:55	1.6
+++ LVM2/test/lib/aux.sh	2011/01/13 14:57:18	1.7
@@ -26,6 +26,8 @@
 	# skip if we singlenode is not compiled in
 	(clvmd --help 2>&1 | grep "Available cluster managers" | grep singlenode) || skip
 
+	lvmconf "activation/monitoring = 1"
+
 	clvmd -Isinglenode -d 1 &
 	LOCAL_CLVMD="$!"
 



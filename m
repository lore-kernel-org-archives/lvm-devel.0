From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Jan 2010 17:14:19 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100121171419.801.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-21 17:14:18

Modified files:
	.              : WHATS_NEW 

Log message:
	Log entry for the last lvmcmdline.c commit

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1396&r2=1.1397

--- LVM2/WHATS_NEW	2010/01/19 23:02:04	1.1396
+++ LVM2/WHATS_NEW	2010/01/21 17:14:18	1.1397
@@ -1,5 +1,6 @@
 Version 2.02.59 - 
 ===================================
+  Clear pointer and counters after their release in _fin_commands().
   Add t-topology-support.sh and t-snapshot-merge.sh tests.
   Fix clvmd to never scan suspended devices.
   Initial version of the cmirror init script (Red Hat).



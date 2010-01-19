From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 19 Jan 2010 23:02:05 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100119230205.17236.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-19 23:02:05

Modified files:
	.              : WHATS_NEW 

Log message:
	Add t-topology-support.sh and t-snapshot-merge.sh tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1395&r2=1.1396

--- LVM2/WHATS_NEW	2010/01/19 13:25:00	1.1395
+++ LVM2/WHATS_NEW	2010/01/19 23:02:04	1.1396
@@ -1,5 +1,6 @@
 Version 2.02.59 - 
 ===================================
+  Add t-topology-support.sh and t-snapshot-merge.sh tests.
   Fix clvmd to never scan suspended devices.
   Initial version of the cmirror init script (Red Hat).
   Initial version of the cmirrord man page.



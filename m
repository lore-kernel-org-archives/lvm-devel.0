From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Oct 2006 19:07:33 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20061024190733.28722.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-24 19:07:32

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.481&r2=1.482

--- LVM2/WHATS_NEW	2006/10/24 18:25:30	1.481
+++ LVM2/WHATS_NEW	2006/10/24 19:07:32	1.482
@@ -1,5 +1,6 @@
 Version 2.02.13 -
 ===================================
+  Fix a clvmd debug message.
   Add dev_flush() to set_lv().
   Add lvchange --resync.
   Perform high-level free space check before each allocation attempt.



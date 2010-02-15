From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2010 18:42:51 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100215184251.5301.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-02-15 18:42:51

Modified files:
	.              : WHATS_NEW 

Log message:
	* update for last 3 commits

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1430&r2=1.1431

--- LVM2/WHATS_NEW	2010/02/15 16:46:56	1.1430
+++ LVM2/WHATS_NEW	2010/02/15 18:42:51	1.1431
@@ -23,6 +23,8 @@
   Add missing metadata reverts in pvmove error path.
   Unlock shared lock in clvmd if activation calls failed.
   Fix return code of info call for query by uuid.
+  Fix constness and floating point gcc warnings.
+  Fix dm_report_field_uint64 function.
 
 Version 2.02.60 - 23rd January 2010
 ===================================



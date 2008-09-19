From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 06:44:54 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20080919064454.16690.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 06:44:54

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.960&r2=1.961

--- LVM2/WHATS_NEW	2008/09/19 06:41:57	1.960
+++ LVM2/WHATS_NEW	2008/09/19 06:44:54	1.961
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Allow lvremove to remove LVs from VGs with missing PVs.
   In VG with PVs missing, by default allow activation of LVs that are complete.
   Track PARTIAL_LV and MISSING_PV flags internally.
   Require --force with --removemissing in vgreduce to remove partial LVs.



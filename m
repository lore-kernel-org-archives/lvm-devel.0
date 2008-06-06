From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2008 17:24:28 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20080606172428.915.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-06 17:24:28

Modified files:
	.              : WHATS_NEW 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.886&r2=1.887

--- LVM2/WHATS_NEW	2008/06/06 13:04:44	1.886
+++ LVM2/WHATS_NEW	2008/06/06 17:24:28	1.887
@@ -1,14 +1,14 @@
 Version 2.02.38 - 
 =================================
-  Correct config file line numbers in messages when parsing comments.
   In script-processing mode, stop if any command fails.
   Warn if command exits with non-zero status code without a prior log_error.
-  Make clvmd-cman use a hash rather than an array for node updown info.
   Check lv_count in vg_validate.
   Add --prefixes to reporting tools for field name prefix output format.
 
-Version 2.02.37 - 
-=================================
+Version 2.02.37 - 6th June 2008
+===============================
+  Make clvmd-cman use a hash rather than an array for node updown info.
+  Correct config file line numbers in messages when parsing comments.
   Drop cached metadata when renaming a VG.
   Allow for vginfo changing during _vg_read.
   Decode numbers in clvmd debugging output.



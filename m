From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2008 15:03:00 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20080117150300.17934.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-17 15:02:59

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.764&r2=1.765

--- LVM2/VERSION	2007/12/05 22:48:06	1.160
+++ LVM2/VERSION	2008/01/17 15:02:59	1.161
@@ -1 +1 @@
-2.02.30-cvs (2007-12-05)
+2.02.30-cvs (2008-01-17)
--- LVM2/WHATS_NEW	2008/01/16 19:00:58	1.764
+++ LVM2/WHATS_NEW	2008/01/17 15:02:59	1.765
@@ -1,10 +1,10 @@
-Version 2.02.30 -
+Version 2.02.30 - 17th January 2008
 ===================================
-  Maintain lists of stacked LV segments using each LV.
+  Add lists of stacked LV segments using each LV to the internal metadata.
   Change vgsplit -l (for unimplemented --list) into --maxlogicalvolumes.
   Fix process_all_pvs to detect non-orphans with no MDAs correctly.
   Don't use block_on_error with mirror targets version 1.12 and above.
-  Update vgsplit to include vgcreate-style options when new VG is destination.
+  Update vgsplit to accept vgcreate options when new VG is destination.
   Update vgsplit to accept existing VG as destination.
   lvconvert waits for completion of initial sync by default.
   Refactor vgcreate for parameter validation and add tests.



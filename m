From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Sep 2010 16:25:04 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100924162504.22605.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-09-24 16:24:59

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.254&r2=1.255
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1735&r2=1.1736
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.414&r2=1.415

--- LVM2/VERSION	2010/09/22 01:36:13	1.254
+++ LVM2/VERSION	2010/09/24 16:24:57	1.255
@@ -1 +1 @@
-2.02.74(2)-cvs (2010-09-22)
+2.02.74(2)-cvs (2010-09-24)
--- LVM2/VERSION_DM	2010/09/22 01:36:13	1.63
+++ LVM2/VERSION_DM	2010/09/24 16:24:57	1.64
@@ -1 +1 @@
-1.02.55-cvs (2010-09-22)
+1.02.55-cvs (2010-09-24)
--- LVM2/WHATS_NEW	2010/09/23 12:02:33	1.1735
+++ LVM2/WHATS_NEW	2010/09/24 16:24:57	1.1736
@@ -1,14 +1,13 @@
-Version 2.02.74 - 
+Version 2.02.74 - 24th September 2010
 =====================================
-  Add escape sequence for ':' and '@' found in device names used as PVs.
-  Replace alloca with dm_malloc in _aligned_io.
+  Allow : and @ to be escaped with \ in device names of PVs.
+  Replace alloca with dm_malloc in _aligned_io to avoid stack corruption.
   Fix partial mode operations for lvm1 metadata format.
   Track recursive filter iteration to avoid refreshing while in use. (2.02.56)
   Revert to old glibc vsnprintf behaviour in emit_to_buffer() to catch overflow.
   Allocate buffer for metadata tags dynamically to remove 4k limit.
   Add random suffix to archive file names to prevent races when being created.
   Reinitialize archive and backup handling on toolcontext refresh.
-  Fix opprobriously slow I/O to cluster mirrors created with --nosync.
   Make poll_mirror_progress report PROGRESS_CHECK_FAILED if LV is not a mirror.
   Like mirrors, don't scan origins if ignore_suspended_devices() is set.
   Fix return type qualifier to avoid compiler warning. (2.02.69)
--- LVM2/WHATS_NEW_DM	2010/09/22 01:36:13	1.414
+++ LVM2/WHATS_NEW_DM	2010/09/24 16:24:57	1.415
@@ -1,5 +1,6 @@
-Version 1.02.55 - 
+Version 1.02.55 - 24th September 2010
 =====================================
+  Fix the way regions are marked complete to avoid slow --nosync cmirror I/O.
   Add DM_REPORT_FIELD_TYPE_ID_LEN to libdevmapper.h.
 
 Version 1.02.54 - 18th August 2010



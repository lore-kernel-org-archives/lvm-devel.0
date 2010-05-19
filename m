From: agk@sourceware.org <agk@sourceware.org>
Date: 19 May 2010 01:49:12 -0000
Subject: LVM2/lib/locking locking.h
Message-ID: <20100519014912.30632.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-19 01:49:09

Modified files:
	lib/locking    : locking.h 

Log message:
	Note that orphan lock is always obtained last

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/lib/locking/locking.h	2010/05/06 11:15:55	1.54
+++ LVM2/lib/locking/locking.h	2010/05/19 01:49:08	1.55
@@ -36,7 +36,8 @@
  *   Set LCK_CACHE flag when manipulating 'vol' metadata in the internal cache.
  *   (Like commit, revert or invalidate metadata.)
  *   If more than one lock needs to be held simultaneously, they must be
- *   acquired in alphabetical order of 'vol' (to avoid deadlocks).
+ *   acquired in alphabetical order of 'vol' (to avoid deadlocks), with
+ *   VG_ORPHANS last.
  *
  * LCK_LV:
  *   Lock/unlock an individual logical volume



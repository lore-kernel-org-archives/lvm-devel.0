From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Feb 2009 16:13:58 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c
Message-ID: <20090222161358.22749.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-22 16:13:57

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 

Log message:
	Fix interrupt unblocking after vgcreate, for example: drop_cached_metadata()
	previously left _vg_lock_count incremented.
	Other locks are always held during drop_cached_metadata() so there's no
	need to increment+decrement it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1046&r2=1.1047
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2009/02/20 23:19:28	1.1046
+++ LVM2/WHATS_NEW	2009/02/22 16:13:57	1.1047
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Exclude LCK_CACHE locks from _vg_lock_count, fixing interrupt unblocking.
   Provide da and mda locations in debug message when writing text format label.
   Mention the restriction on file descriptors at invocation on the lvm man page.
   Index cached vgmetadata by vgid not vgname to cope with duplicate vgnames.
--- LVM2/lib/locking/locking.c	2009/02/03 16:23:19	1.55
+++ LVM2/lib/locking/locking.c	2009/02/22 16:13:57	1.56
@@ -191,7 +191,8 @@
 
 static void _update_vg_lock_count(uint32_t flags)
 {
-	if ((flags & LCK_SCOPE_MASK) != LCK_VG)
+	if ((flags & LCK_SCOPE_MASK) != LCK_VG ||
+	    (flags & LCK_CACHE))
 		return;
 
 	if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)



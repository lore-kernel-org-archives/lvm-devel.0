From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2009 14:28:30 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20090708142830.19624.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-08 14:28:30

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Remove unneeded LOCK_KEEP from vg_read() interface.
	
	Remove unneeded LOCK_KEEP from vg_read() interface.
	Update comment to clarify cases where _vg_lock_and_read() may return
	with an error but the lock held.  Would be nice to make the vg_read()
	interface consistent with regards to lock held and error behavior.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.231&r2=1.232

--- LVM2/lib/metadata/metadata-exported.h	2009/07/01 17:00:50	1.78
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/08 14:28:30	1.79
@@ -113,7 +113,6 @@
 
 /* FIXME Deduce these next requirements internally instead of having caller specify. */
 #define LOCK_NONBLOCKING	0x00000100U	/* Fail if not available immediately. */
-#define LOCK_KEEP		0x00000200U	/* Do not unlock upon read failure. */
 
 /* A meta-flag, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE 	0x00100000U
--- LVM2/lib/metadata/metadata.c	2009/07/06 19:04:25	1.231
+++ LVM2/lib/metadata/metadata.c	2009/07/08 14:28:30	1.232
@@ -2793,7 +2793,6 @@
 			goto_bad;
 		}
 	}
-	
 
 	failure |= _vg_bad_status_bits(vg, status_flags);
 	if (failure)
@@ -2803,7 +2802,7 @@
 
 bad:
 	if (failure != (FAILED_NOTFOUND | READ_CHECK_EXISTENCE) &&
-	    !(misc_flags & LOCK_KEEP) && !already_locked)
+	    !already_locked)
 		unlock_vg(cmd, lock_name);
 
 	return _vg_make_handle(cmd, vg, failure);
@@ -2821,7 +2820,11 @@
  *    FAILED_RESIZEABLE
  *  - locking failed: FAILED_LOCKING
  *
- * On failures, all locks are released, unless LOCK_KEEP has been supplied.
+ * On failures, all locks are released, unless one of the following applies:
+ *  - failure == (FAILED_NOTFOUND | READ_CHECK_EXISTENCE)
+ *  - vgname_is_locked(lock_name) is true
+ * FIXME: remove the above 2 conditions if possible and make an error always
+ * release the lock.
  *
  * Volume groups are opened read-only unless flags contains READ_FOR_UPDATE.
  *



From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Sep 2008 18:05:12 -0000
Subject: LVM2 lib/cache/lvmcache.c ./WHATS_NEW
Message-ID: <20080916180512.27596.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-16 18:05:11

Modified files:
	lib/cache      : lvmcache.c 
	.              : WHATS_NEW 

Log message:
	Avoid repeatedly wiping cache while VG_GLOBAL is held in vgscan & pvscan.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.951&r2=1.952

--- LVM2/lib/cache/lvmcache.c	2008/06/27 15:18:31	1.59
+++ LVM2/lib/cache/lvmcache.c	2008/09/16 18:05:11	1.60
@@ -97,9 +97,10 @@
 	int was_locked = (info->status & CACHE_LOCKED) ? 1 : 0;
 
 	/*
-	 * Cache becomes invalid whenever lock state changes
+	 * Cache becomes invalid whenever lock state changes unless
+	 * exclusive VG_GLOBAL is held (i.e. while scanning).
 	 */
-	if (was_locked != locked) {
+	if (!vgname_is_locked(VG_GLOBAL) && (was_locked != locked)) {
 		info->status |= CACHE_INVALID;
 		*cached_vgmetadata_valid = 0;
 	}
@@ -166,7 +167,7 @@
 
 		/* Indicate that PVs could now be missing from the cache */
 		init_full_scan_done(0);
-	} else
+	} else if (!vgname_is_locked(VG_GLOBAL))
 		_drop_metadata(vgname);
 }
 
--- LVM2/WHATS_NEW	2008/09/12 15:26:44	1.951
+++ LVM2/WHATS_NEW	2008/09/16 18:05:11	1.952
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Avoid repeatedly wiping cache while VG_GLOBAL is held in vgscan & pvscan.
   Fix pvresize to not allow resize if PV has two metadata areas.
   Fix setting of volume limit count if converting to lvm1 format.
   Fix vgconvert logical volume id metadata validation.



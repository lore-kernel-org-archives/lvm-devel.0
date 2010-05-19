From: agk@sourceware.org <agk@sourceware.org>
Date: 19 May 2010 00:52:58 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/lock ...
Message-ID: <20100519005258.25946.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-19 00:52:56

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/locking    : cluster_locking.c file_locking.c locking.c 

Log message:
	Use is_orphan_vg in place of hard-coded prefix tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1562&r2=1.1563
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/WHATS_NEW	2010/05/17 20:18:13	1.1562
+++ LVM2/WHATS_NEW	2010/05/19 00:52:55	1.1563
@@ -1,5 +1,6 @@
 Version 2.02.66 - 
 ===============================
+  Use is_orphan_vg in place of hard-coded prefix tests.
 
 Version 2.02.65 - 17th May 2010
 ===============================
--- LVM2/lib/cache/lvmcache.c	2010/05/13 13:04:05	1.86
+++ LVM2/lib/cache/lvmcache.c	2010/05/19 00:52:55	1.87
@@ -224,11 +224,11 @@
 
 /*
  * Ensure vgname2 comes after vgname1 alphabetically.
- * Special VG names beginning with '#' don't count.
+ * Orphans don't count.
  */
 static int _vgname_order_correct(const char *vgname1, const char *vgname2)
 {
-	if ((*vgname1 == '#') || (*vgname2 == '#'))
+	if (is_orphan_vg(vgname1) || is_orphan_vg(vgname2))
 		return 1;
 
 	if (strcmp(vgname1, vgname2) < 0)
--- LVM2/lib/locking/cluster_locking.c	2010/04/13 14:36:25	1.42
+++ LVM2/lib/locking/cluster_locking.c	2010/05/19 00:52:55	1.43
@@ -406,7 +406,7 @@
 		}
 
 		/* If the VG name is empty then lock the unused PVs */
-		if (*resource == '#' || (flags & LCK_CACHE))
+		if (is_orphan_vg(resource) || (flags & LCK_CACHE))
 			dm_snprintf(lockname, sizeof(lockname), "P_%s",
 				    resource);
 		else
--- LVM2/lib/locking/file_locking.c	2010/01/05 16:06:43	1.44
+++ LVM2/lib/locking/file_locking.c	2010/05/19 00:52:55	1.45
@@ -265,7 +265,7 @@
 		if (flags & LCK_CACHE)
 			break;
 
-		if (*resource == '#')
+		if (is_orphan_vg(resource))
 			dm_snprintf(lockfile, sizeof(lockfile),
 				     "%s/P_%s", _lock_dir, resource + 1);
 		else
--- LVM2/lib/locking/locking.c	2010/05/06 11:15:55	1.80
+++ LVM2/lib/locking/locking.c	2010/05/19 00:52:55	1.81
@@ -369,7 +369,7 @@
 		return 0;
 	}
 
-	if (*resource == '#' && (flags & LCK_CACHE)) {
+	if (is_orphan_vg(resource) && (flags & LCK_CACHE)) {
 		log_error(INTERNAL_ERROR "P_%s referenced", resource);
 		return 0;
 	}
@@ -423,7 +423,7 @@
 		if (!_blocking_supported)
 			flags |= LCK_NONBLOCK;
 
-		if (vol[0] != '#' &&
+		if (!is_orphan_vg(vol) && 
 		    ((flags & LCK_TYPE_MASK) != LCK_UNLOCK) &&
 		    (!(flags & LCK_CACHE)) &&
 		    !lvmcache_verify_lock_order(vol))



From: agk@sourceware.org <agk@sourceware.org>
Date: 19 May 2010 02:08:52 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/lock ...
Message-ID: <20100519020852.9836.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-19 02:08:51

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/locking    : locking.c 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Validate orphan and VG_GLOBAL lock order too.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1564&r2=1.1565
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.340&r2=1.341

--- LVM2/WHATS_NEW	2010/05/19 01:16:40	1.1564
+++ LVM2/WHATS_NEW	2010/05/19 02:08:50	1.1565
@@ -1,5 +1,6 @@
 Version 2.02.66 - 
 ===============================
+  Validate orphan and VG_GLOBAL lock order too.
   Accept orphan VG names as parameters to lock_vol() and related functions.
   Use is_orphan_vg in place of hard-coded prefix tests.
 
--- LVM2/lib/cache/lvmcache.c	2010/05/19 01:16:40	1.88
+++ LVM2/lib/cache/lvmcache.c	2010/05/19 02:08:50	1.89
@@ -224,11 +224,21 @@
 
 /*
  * Ensure vgname2 comes after vgname1 alphabetically.
- * Orphans don't count.
+ * Orphan locks come last.
+ * VG_GLOBAL comes first.
  */
 static int _vgname_order_correct(const char *vgname1, const char *vgname2)
 {
-	if (is_orphan_vg(vgname1) || is_orphan_vg(vgname2))
+	if (is_global_vg(vgname1))
+		return 1;
+
+	if (is_global_vg(vgname2))
+		return 0;
+
+	if (is_orphan_vg(vgname1))
+		return 0;
+
+	if (is_orphan_vg(vgname2))
 		return 1;
 
 	if (strcmp(vgname1, vgname2) < 0)
--- LVM2/lib/locking/locking.c	2010/05/19 01:16:41	1.82
+++ LVM2/lib/locking/locking.c	2010/05/19 02:08:51	1.83
@@ -424,7 +424,7 @@
 		if (is_orphan_vg(vol))
 			vol = VG_ORPHANS;
 		/* VG locks alphabetical, ORPHAN lock last */
-		else if (((flags & LCK_TYPE_MASK) != LCK_UNLOCK) &&
+		if (((flags & LCK_TYPE_MASK) != LCK_UNLOCK) &&
 			 !(flags & LCK_CACHE) &&
 			 !lvmcache_verify_lock_order(vol))
 			return 0;
--- LVM2/lib/metadata/metadata-exported.h	2010/05/14 15:19:43	1.144
+++ LVM2/lib/metadata/metadata-exported.h	2010/05/19 02:08:51	1.145
@@ -423,6 +423,7 @@
 int move_pvs_used_by_lv(struct volume_group *vg_from,
 			struct volume_group *vg_to,
 			const char *lv_name);
+int is_global_vg(const char *vg_name);
 int is_orphan_vg(const char *vg_name);
 int is_orphan(const struct physical_volume *pv);
 int is_missing_pv(const struct physical_volume *pv);
--- LVM2/lib/metadata/metadata.c	2010/05/19 01:16:41	1.340
+++ LVM2/lib/metadata/metadata.c	2010/05/19 02:08:51	1.341
@@ -3326,6 +3326,11 @@
 	return 1;
 }
 
+int is_global_vg(const char *vg_name)
+{
+	return (vg_name && !strcmp(vg_name, VG_GLOBAL)) ? 1 : 0;
+}
+
 /**
  * is_orphan_vg - Determine whether a vg_name is an orphan
  * @vg_name: pointer to the vg_name



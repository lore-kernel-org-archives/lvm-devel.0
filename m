From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Feb 2009 12:41:52 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c
Message-ID: <20090206124152.28686.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-02-06 12:41:52

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 

Log message:
	Fix pvs segfault when pv mda attributes requested for not available PV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1035&r2=1.1036
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/WHATS_NEW	2009/02/04 12:47:05	1.1035
+++ LVM2/WHATS_NEW	2009/02/06 12:41:51	1.1036
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Fix pvs segfault when pv mda attributes requested for not available PV.
   Add support for ext4 resize in fsadm
   Move locking_type reading inside init_locking().
   Rename get_vgs() to get_vgnames() and clarify related error messages.
--- LVM2/lib/report/report.c	2009/01/10 17:09:40	1.94
+++ LVM2/lib/report/report.c	2009/02/06 12:41:51	1.95
@@ -868,15 +868,14 @@
 	const char *pvid = (const char *)(&((struct id *) data)->uuid);
 	struct metadata_area *mda;
 
-	info = info_from_pvid(pvid, 0);
-
-	dm_list_iterate_items(mda, &info->mdas) {
-		if (!mda->ops->mda_free_sectors)
-			continue;
-		mda_free = mda->ops->mda_free_sectors(mda);
-		if (mda_free < freespace)
-			freespace = mda_free;
-	}
+	if ((info = info_from_pvid(pvid, 0)))
+		dm_list_iterate_items(mda, &info->mdas) {
+			if (!mda->ops->mda_free_sectors)
+				continue;
+			mda_free = mda->ops->mda_free_sectors(mda);
+			if (mda_free < freespace)
+				freespace = mda_free;
+		}
 
 	if (freespace == UINT64_MAX)
 		freespace = UINT64_C(0);
@@ -908,13 +907,12 @@
 			   const void *data, void *private)
 {
 	struct lvmcache_info *info;
-	uint64_t min_mda_size;
+	uint64_t min_mda_size = 0;
 	const char *pvid = (const char *)(&((struct id *) data)->uuid);
 
-	info = info_from_pvid(pvid, 0);
-
 	/* PVs could have 2 mdas of different sizes (rounding effect) */
-	min_mda_size = _find_min_mda_size(&info->mdas);
+	if ((info = info_from_pvid(pvid, 0)))
+		min_mda_size = _find_min_mda_size(&info->mdas);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }



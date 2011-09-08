From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Sep 2011 20:55:40 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv.c lib/metadat ...
Message-ID: <20110908205540.1705.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-08 20:55:39

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv.c metadata-exported.h 
	man            : lvs.8.in 

Log message:
	Add 7th lv_attr char to show the related kernel target.
	Add thin volume types to lv_attr.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2100&r2=1.2101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.209&r2=1.210
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2011/09/07 13:42:00	1.2100
+++ LVM2/WHATS_NEW	2011/09/08 20:55:39	1.2101
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add 7th lv_attr char to show the related kernel target.
   Terminate pv_attr field correctly. (2.02.86)
   Fix 'not not' typo in pvcreate man page.
   Improve man page style for fsadm, lvreduce, lvremove, lvrename, lvresize.
--- LVM2/lib/metadata/lv.c	2011/04/12 12:24:29	1.24
+++ LVM2/lib/metadata/lv.c	2011/09/08 20:55:39	1.25
@@ -298,7 +298,7 @@
 	struct lvinfo info;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 7))) {
+	if (!(repstr = dm_pool_zalloc(mem, 8))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -311,15 +311,22 @@
 		repstr[0] = 'p';
 	else if (lv->status & CONVERTING)
 		repstr[0] = 'c';
-	else if (lv->status & VIRTUAL)
-		repstr[0] = 'v';
-	/* Origin takes precedence over Mirror */
-	else if (lv_is_origin(lv)) {
+	/* Origin takes precedence over mirror and thin volume */
+	else if (lv_is_origin(lv))
 		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
-	}
-	else if (lv->status & MIRRORED) {
+	else if (lv->status & MIRRORED)
 		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'M' : 'm';
-	}else if (lv->status & MIRROR_IMAGE)
+	else if (lv_is_thin_volume(lv))
+		repstr[0] = 'V';
+	else if (lv->status & VIRTUAL)
+		repstr[0] = 'v';
+	else if (lv_is_thin_pool(lv))
+		repstr[0] = 't';
+	else if (lv_is_thin_pool_data(lv))
+		repstr[0] = 'T';
+	else if (lv_is_thin_pool_metadata(lv) || (lv->status & RAID_META))
+		repstr[0] = 'e';
+	else if (lv->status & MIRROR_IMAGE)
 		repstr[0] = (_lv_mimage_in_sync(lv)) ? 'i' : 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
@@ -370,6 +377,22 @@
 		repstr[4] = '-';
 		repstr[5] = '-';
 	}
+
+	if (lv_is_thin_type(lv))
+		repstr[6] = 't';
+	else if (lv_is_mirror_type(lv))
+		repstr[6] = 'm';
+	else if (lv_is_raid_type(lv))
+		repstr[6] = 'r';
+	else if (lv_is_cow(lv) || lv_is_origin(lv))
+		repstr[6] = 's';
+	else if (lv_has_unknown_segments(lv))
+		repstr[6] = 'u';
+	else if (lv_is_virtual(lv))
+		repstr[6] = 'v';
+	else
+		repstr[6] = '-';
+
 out:
 	return repstr;
 }
--- LVM2/lib/metadata/metadata-exported.h	2011/09/08 16:41:18	1.209
+++ LVM2/lib/metadata/metadata-exported.h	2011/09/08 20:55:39	1.210
@@ -141,6 +141,12 @@
 #define lv_is_mirrored(lv)	((lv)->status & MIRRORED ? 1 : 0)
 #define lv_is_rlog(lv)		((lv)->status & REPLICATOR_LOG ? 1 : 0)
 
+#define lv_is_thin_type(lv)	((lv)->status & (THIN_POOL | THIN_VOLUME | THIN_POOL_DATA | THIN_POOL_METADATA) ? 1 : 0)
+#define lv_is_mirror_type(lv)	((lv)->status & (MIRROR_LOG | MIRROR_IMAGE | MIRRORED | PVMOVE) ? 1 : 0)
+#define lv_is_raid_type(lv)	((lv)->status & (RAID | RAID_IMAGE | RAID_META))
+
+#define lv_is_virtual(lv)	((lv)->status & VIRTUAL)
+
 /* Ordered list - see lv_manip.c */
 typedef enum {
 	AREA_UNASSIGNED,
--- LVM2/man/lvs.8.in	2010/06/23 12:32:08	1.13
+++ LVM2/man/lvs.8.in	2011/09/08 20:55:39	1.14
@@ -70,7 +70,9 @@
 .IP 1 3
 Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin,
 (O)rigin with merging snapshot, (s)napshot, merging (S)napshot, (p)vmove,
-(v)irtual, mirror (i)mage, mirror (I)mage out-of-sync, under (c)onversion
+(v)irtual, mirror (i)mage, mirror (I)mage out-of-sync, mirror (l)og device,
+under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data, thin pool 
+m(e)tadata
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only
 .IP 3 3
@@ -84,6 +86,14 @@
 mapped (d)evice present without tables, mapped device present with (i)nactive table
 .IP 6 3
 device (o)pen
+.IP 7 3
+Target type: (m)irror, (r)aid, (s)napshot, (t)hin, (u)nknown, (v)irtual.  
+This groups logical volumes related to the same kernel target together.  So,
+for example, mirror images, mirror logs as well as mirrors themselves appear as
+(m) if they use the original device-mapper mirror kernel driver; whereas the raid
+equivalents using the md raid kernel driver all appear as (r).
+Snapshots using the original device-mapper driver appear as (s); whereas
+snapshots of thin volumes using the new thin provisioning driver appear as (t).
 .RE
 .TP
 .I \-\-segments



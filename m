From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Aug 2011 18:15:15 -0000
Subject: LVM2/lib thin/thin.c metadata/segtype.h
Message-ID: <20110826181515.19381.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-26 18:15:15

Modified files:
	lib/thin       : thin.c 
	lib/metadata   : segtype.h 

Log message:
	seg_is_thin includes both thin_pool and thin_volume

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/lib/thin/thin.c	2011/08/26 17:40:53	1.4
+++ LVM2/lib/thin/thin.c	2011/08/26 18:15:14	1.5
@@ -208,7 +208,7 @@
 		uint32_t flags;
 	} reg_segtypes[] = {
 		{ &_thin_pool_ops, "thin_pool", SEG_THIN_POOL },
-		{ &_thin_ops, "thin", SEG_THIN }
+		{ &_thin_ops, "thin", SEG_THIN_VOLUME }
 	};
 
 	struct segment_type *segtype;
--- LVM2/lib/metadata/segtype.h	2011/08/25 10:00:09	1.39
+++ LVM2/lib/metadata/segtype.h	2011/08/26 18:15:15	1.40
@@ -39,8 +39,8 @@
 #define SEG_REPLICATOR		0x00000100U
 #define SEG_REPLICATOR_DEV	0x00000200U
 #define SEG_RAID		0x00000400U
-#define SEG_THIN		0x00000800U
-#define SEG_THIN_POOL		0x00001000U
+#define SEG_THIN_POOL		0x00000800U
+#define SEG_THIN_VOLUME		0x00001000U
 #define SEG_UNKNOWN		0x80000000U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
@@ -50,8 +50,9 @@
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
 #define seg_is_raid(seg)	((seg)->segtype->flags & SEG_RAID ? 1 : 0)
-#define seg_is_thin(seg)	((seg)->segtype->flags & SEG_THIN ? 1 : 0)
+#define seg_is_thin(seg)	((seg)->segtype->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
 #define seg_is_thin_pool(seg)	((seg)->segtype->flags & SEG_THIN_POOL ? 1 : 0)
+#define seg_is_thin_volume(seg)	((seg)->segtype->flags & SEG_THIN_VOLUME ? 1 : 0)
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)



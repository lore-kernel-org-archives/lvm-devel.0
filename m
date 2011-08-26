From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Aug 2011 18:17:05 -0000
Subject: LVM2/lib/metadata segtype.h
Message-ID: <20110826181705.19629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-26 18:17:05

Modified files:
	lib/metadata   : segtype.h 

Log message:
	same for segtype_is_thin

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/lib/metadata/segtype.h	2011/08/26 18:15:15	1.40
+++ LVM2/lib/metadata/segtype.h	2011/08/26 18:17:05	1.41
@@ -61,8 +61,9 @@
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
-#define segtype_is_thin(segtype)	((segtype)->flags & SEG_THIN ? 1 : 0)
+#define segtype_is_thin(segtype)	((segtype)->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
 #define segtype_is_thin_pool(segtype)	((segtype)->flags & SEG_THIN_POOL ? 1 : 0)
+#define segtype_is_thin_volume(segtype)	((segtype)->flags & SEG_THIN_VOLUME ? 1 : 0)
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 
 struct segment_type {



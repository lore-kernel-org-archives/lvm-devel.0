From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 21 Mar 2017 19:30:38 -0400
Subject: master - metadata: cleanup flags definition to be consistent
Message-ID: <201703212330.v2LNUcLk010314@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7126fb13e7d4f9fbdf10663a5d04b52a3f5dba0c
Commit:        7126fb13e7d4f9fbdf10663a5d04b52a3f5dba0c
Parent:        1810162b510e25d4f07d07f83ba17a8ebc230c9c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Mar 22 00:29:49 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Mar 22 00:29:49 2017 +0100

metadata: cleanup flags definition to be consistent

Use shift bitops throughout segtype.h.
---
 lib/metadata/segtype.h |   76 ++++++++++++++++++++++++------------------------
 1 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index a6093e8..2be9eac 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -28,50 +28,50 @@ struct dm_config_node;
 struct dev_manager;
 
 /* Feature flags */
-#define SEG_CAN_SPLIT		0x0000000000000001ULL
-#define SEG_AREAS_STRIPED	0x0000000000000002ULL
-#define SEG_AREAS_MIRRORED	0x0000000000000004ULL
-#define SEG_SNAPSHOT		0x0000000000000008ULL
-#define SEG_FORMAT1_SUPPORT	0x0000000000000010ULL
-#define SEG_VIRTUAL		0x0000000000000020ULL
-#define SEG_CANNOT_BE_ZEROED	0x0000000000000040ULL
-#define SEG_MONITORED		0x0000000000000080ULL
-#define SEG_REPLICATOR		0x0000000000000100ULL
-#define SEG_REPLICATOR_DEV	0x0000000000000200ULL
-#define SEG_RAID		0x0000000000000400ULL
-#define SEG_THIN_POOL		0x0000000000000800ULL
-#define SEG_THIN_VOLUME		0x0000000000001000ULL
-#define SEG_CACHE		0x0000000000002000ULL
-#define SEG_CACHE_POOL		0x0000000000004000ULL
-#define SEG_MIRROR		0x0000000000008000ULL
-#define SEG_ONLY_EXCLUSIVE	0x0000000000010000ULL /* In cluster only exlusive activation */
-#define SEG_CAN_ERROR_WHEN_FULL	0x0000000000020000ULL
-
-#define SEG_RAID0		0x0000000000040000ULL
-#define SEG_RAID0_META		0x0000000000080000ULL
-#define SEG_RAID1		0x0000000000100000ULL
-#define SEG_RAID10_NEAR		0x0000000000200000ULL
+#define SEG_CAN_SPLIT		(1ULL <<  0)
+#define SEG_AREAS_STRIPED	(1ULL <<  1)
+#define SEG_AREAS_MIRRORED	(1ULL <<  2)
+#define SEG_SNAPSHOT		(1ULL <<  3)
+#define SEG_FORMAT1_SUPPORT	(1ULL <<  4)
+#define SEG_VIRTUAL		(1ULL <<  5)
+#define SEG_CANNOT_BE_ZEROED	(1ULL <<  6)
+#define SEG_MONITORED		(1ULL <<  7)
+#define SEG_REPLICATOR		(1ULL <<  8)
+#define SEG_REPLICATOR_DEV	(1ULL <<  9)
+#define SEG_RAID		(1ULL << 10)
+#define SEG_THIN_POOL		(1ULL << 11)
+#define SEG_THIN_VOLUME		(1ULL << 12)
+#define SEG_CACHE		(1ULL << 13)
+#define SEG_CACHE_POOL		(1ULL << 14)
+#define SEG_MIRROR		(1ULL << 15)
+#define SEG_ONLY_EXCLUSIVE	(1ULL << 16) /* In cluster only exlusive activation */
+#define SEG_CAN_ERROR_WHEN_FULL	(1ULL << 17)
+
+#define SEG_RAID0		(1ULL << 18)
+#define SEG_RAID0_META		(1ULL << 19)
+#define SEG_RAID1		(1ULL << 20)
+#define SEG_RAID10_NEAR		(1ULL << 21)
 #define SEG_RAID10		SEG_RAID10_NEAR
-#define SEG_RAID4		0x0000000000400000ULL
-#define SEG_RAID5_N		0x0000000000800000ULL
-#define SEG_RAID5_LA		0x0000000001000000ULL
-#define SEG_RAID5_LS		0x0000000002000000ULL
-#define SEG_RAID5_RA		0x0000000004000000ULL
-#define SEG_RAID5_RS		0x0000000008000000ULL
+#define SEG_RAID4		(1ULL << 22)
+#define SEG_RAID5_N		(1ULL << 23)
+#define SEG_RAID5_LA		(1ULL << 24)
+#define SEG_RAID5_LS		(1ULL << 25)
+#define SEG_RAID5_RA		(1ULL << 26)
+#define SEG_RAID5_RS		(1ULL << 27)
 #define SEG_RAID5		SEG_RAID5_LS
-#define SEG_RAID6_NC		0x0000000010000000ULL
-#define SEG_RAID6_NR		0x0000000020000000ULL
-#define SEG_RAID6_ZR		0x0000000040000000ULL
-#define SEG_RAID6_LA_6		0x0000000080000000ULL
-#define SEG_RAID6_LS_6		0x0000000100000000ULL
-#define SEG_RAID6_RA_6		0x0000000200000000ULL
-#define SEG_RAID6_RS_6		0x0000000400000000ULL
-#define SEG_RAID6_N_6		0x0000000800000000ULL
+#define SEG_RAID6_NC		(1ULL << 28)
+#define SEG_RAID6_NR		(1ULL << 29)
+#define SEG_RAID6_ZR		(1ULL << 30)
+#define SEG_RAID6_LA_6		(1ULL << 31)
+#define SEG_RAID6_LS_6		(1ULL << 32)
+#define SEG_RAID6_RA_6		(1ULL << 33)
+#define SEG_RAID6_RS_6		(1ULL << 34)
+#define SEG_RAID6_N_6		(1ULL << 35)
 #define SEG_RAID6		SEG_RAID6_ZR
 
-#define SEG_STRIPED_TARGET	0x0000008000000000ULL
+#define SEG_STRIPED_TARGET	(1ULL << 39)
 
-#define SEG_UNKNOWN		0x8000000000000000ULL
+#define SEG_UNKNOWN		(1ULL << 63)
 
 #define SEG_TYPE_NAME_LINEAR		"linear"
 #define SEG_TYPE_NAME_STRIPED		"striped"



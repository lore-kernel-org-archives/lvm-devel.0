From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Sep 2015 18:05:08 +0000 (UTC)
Subject: master - segtypes: Extend flags to 64 bits.
Message-ID: <20150922180508.657D960253@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ce150280ed703aad27f8d5c37db02dfa63da382
Commit:        0ce150280ed703aad27f8d5c37db02dfa63da382
Parent:        3a8a37187d65e2c84f98d39e06bdee7000e34875
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Sep 22 18:03:33 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 22 18:03:33 2015 +0100

segtypes: Extend flags to 64 bits.

---
 lib/metadata/segtype.h |   74 +++++++++++++++++++++++++----------------------
 lib/raid/raid.c        |    6 ++--
 2 files changed, 42 insertions(+), 38 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index a80d5ed..7a5195c 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -28,26 +28,43 @@ struct dm_config_node;
 struct dev_manager;
 
 /* Feature flags */
-#define SEG_CAN_SPLIT		0x00000001U
-#define SEG_AREAS_STRIPED	0x00000002U
-#define SEG_AREAS_MIRRORED	0x00000004U
-#define SEG_SNAPSHOT		0x00000008U
-#define SEG_FORMAT1_SUPPORT	0x00000010U
-#define SEG_VIRTUAL		0x00000020U
-#define SEG_CANNOT_BE_ZEROED	0x00000040U
-#define SEG_MONITORED		0x00000080U
-#define SEG_REPLICATOR		0x00000100U
-#define SEG_REPLICATOR_DEV	0x00000200U
-#define SEG_RAID		0x00000400U
-#define SEG_THIN_POOL		0x00000800U
-#define SEG_THIN_VOLUME		0x00001000U
-#define SEG_CACHE		0x00002000U
-#define SEG_CACHE_POOL		0x00004000U
-#define SEG_MIRROR		0x00008000U
-#define SEG_ONLY_EXCLUSIVE	0x00010000U /* In cluster only exlusive activation */
-#define SEG_CAN_ERROR_WHEN_FULL	0x00020000U
-#define SEG_UNKNOWN		0x80000000U
-
+#define SEG_CAN_SPLIT		0x0000000000000001U
+#define SEG_AREAS_STRIPED	0x0000000000000002U
+#define SEG_AREAS_MIRRORED	0x0000000000000004U
+#define SEG_SNAPSHOT		0x0000000000000008U
+#define SEG_FORMAT1_SUPPORT	0x0000000000000010U
+#define SEG_VIRTUAL		0x0000000000000020U
+#define SEG_CANNOT_BE_ZEROED	0x0000000000000040U
+#define SEG_MONITORED		0x0000000000000080U
+#define SEG_REPLICATOR		0x0000000000000100U
+#define SEG_REPLICATOR_DEV	0x0000000000000200U
+#define SEG_RAID		0x0000000000000400U
+#define SEG_THIN_POOL		0x0000000000000800U
+#define SEG_THIN_VOLUME		0x0000000000001000U
+#define SEG_CACHE		0x0000000000002000U
+#define SEG_CACHE_POOL		0x0000000000004000U
+#define SEG_MIRROR		0x0000000000008000U
+#define SEG_ONLY_EXCLUSIVE	0x0000000000010000U /* In cluster only exlusive activation */
+#define SEG_CAN_ERROR_WHEN_FULL	0x0000000000020000U
+#define SEG_UNKNOWN		0x8000000000000000U
+
+#define SEG_TYPE_NAME_LINEAR		"linear"
+#define SEG_TYPE_NAME_STRIPED		"striped"
+#define SEG_TYPE_NAME_MIRROR		"mirror"
+#define SEG_TYPE_NAME_RAID1		"raid1"
+#define SEG_TYPE_NAME_RAID10		"raid10"
+#define SEG_TYPE_NAME_RAID4		"raid4"
+#define SEG_TYPE_NAME_RAID5		"raid5"
+#define SEG_TYPE_NAME_RAID5_LA		"raid5_la"
+#define SEG_TYPE_NAME_RAID5_LS		"raid5_ls"
+#define SEG_TYPE_NAME_RAID5_RA		"raid5_ra"
+#define SEG_TYPE_NAME_RAID5_RS		"raid5_rs"
+#define SEG_TYPE_NAME_RAID6		"raid6"
+#define SEG_TYPE_NAME_RAID6_NC		"raid6_nc"
+#define SEG_TYPE_NAME_RAID6_NR		"raid6_nr"
+#define SEG_TYPE_NAME_RAID6_ZR		"raid6_zr"
+
+#define segtype_is_linear(segtype)	(!strcmp(segtype->name, SEG_TYPE_NAME_LINEAR))
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
 #define segtype_is_cache_pool(segtype)	((segtype)->flags & SEG_CACHE_POOL ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
@@ -86,7 +103,7 @@ struct dev_manager;
 struct segment_type {
 	struct dm_list list;		/* Internal */
 
-	uint32_t flags;
+	uint64_t flags;
 	uint32_t parity_devs;           /* Parity drives required by segtype */
 
 	struct segtype_handler *ops;
@@ -157,19 +174,6 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
-#define SEG_TYPE_NAME_RAID1	"raid1"
-#define SEG_TYPE_NAME_RAID10	"raid10"
-#define SEG_TYPE_NAME_RAID4	"raid4"
-#define SEG_TYPE_NAME_RAID5	"raid5"
-#define SEG_TYPE_NAME_RAID5_LA	"raid5_la"
-#define SEG_TYPE_NAME_RAID5_LS	"raid5_ls"
-#define SEG_TYPE_NAME_RAID5_RA	"raid5_ra"
-#define SEG_TYPE_NAME_RAID5_RS	"raid5_rs"
-#define SEG_TYPE_NAME_RAID6	"raid6"
-#define SEG_TYPE_NAME_RAID6_NC	"raid6_nc"
-#define SEG_TYPE_NAME_RAID6_NR	"raid6_nr"
-#define SEG_TYPE_NAME_RAID6_ZR	"raid6_zr"
-
 #ifdef REPLICATOR_INTERNAL
 int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index ae70cdd..290a590 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -434,7 +434,7 @@ static struct segtype_handler _raid_ops = {
 static const struct raid_type {
 	const char name[12];
 	unsigned parity;
-	int extra_flags;
+	uint64_t extra_flags;
 } _raid_types[] = {
 	{ SEG_TYPE_NAME_RAID1,    0, SEG_AREAS_MIRRORED },
 	{ SEG_TYPE_NAME_RAID10,   0, SEG_AREAS_MIRRORED },
@@ -452,7 +452,7 @@ static const struct raid_type {
 
 static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
 					       const struct raid_type *rt,
-					       int monitored)
+					       uint64_t monitored)
 {
 	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
@@ -482,7 +482,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 {
 	struct segment_type *segtype;
 	unsigned i;
-	int monitored = 0;
+	uint64_t monitored = 0;
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD



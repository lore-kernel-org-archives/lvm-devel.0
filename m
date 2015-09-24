From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Sep 2015 19:18:09 +0000 (UTC)
Subject: master - raid: Add a segtype flag for each raid type.
Message-ID: <20150924191809.D197760311@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3036620b488800027d1ec37b5cbe65f6f180e9c7
Commit:        3036620b488800027d1ec37b5cbe65f6f180e9c7
Parent:        d40830a2b13595943ca51d4bfd6249527a0972cf
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Sep 24 20:17:57 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Sep 24 20:17:57 2015 +0100

raid: Add a segtype flag for each raid type.

---
 lib/metadata/segtype.h |   22 +++++++++++++++++++++-
 lib/raid/raid.c        |   24 ++++++++++++------------
 2 files changed, 33 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index fd833cd..09034e9 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -46,6 +46,26 @@ struct dev_manager;
 #define SEG_MIRROR		0x0000000000008000ULL
 #define SEG_ONLY_EXCLUSIVE	0x0000000000010000ULL /* In cluster only exlusive activation */
 #define SEG_CAN_ERROR_WHEN_FULL	0x0000000000020000ULL
+
+#define SEG_RAID1		0x0000000000100000ULL
+#define SEG_RAID10		0x0000000000200000ULL
+#define SEG_RAID4		0x0000000000400000ULL
+#define SEG_RAID5_N		0x0000000000800000ULL
+#define SEG_RAID5_LA		0x0000000001000000ULL
+#define SEG_RAID5_LS		0x0000000002000000ULL
+#define SEG_RAID5_RA		0x0000000004000000ULL
+#define SEG_RAID5_RS		0x0000000008000000ULL
+#define SEG_RAID5		SEG_RAID5_LS
+#define SEG_RAID6_NC		0x0000000010000000ULL
+#define SEG_RAID6_NR		0x0000000020000000ULL
+#define SEG_RAID6_ZR		0x0000000040000000ULL
+#define SEG_RAID6_LA_6		0x0000000080000000ULL
+#define SEG_RAID6_LS_6		0x0000000100000000ULL
+#define SEG_RAID6_RA_6		0x0000000200000000ULL
+#define SEG_RAID6_RS_6		0x0000000400000000ULL
+#define SEG_RAID6_N_6		0x0000000800000000ULL
+#define SEG_RAID6		SEG_RAID6_ZR
+
 #define SEG_UNKNOWN		0x8000000000000000ULL
 
 #define SEG_TYPE_NAME_LINEAR		"linear"
@@ -141,7 +161,7 @@ struct segment_type {
 	struct dm_list list;		/* Internal */
 
 	uint64_t flags;
-	uint32_t parity_devs;           /* Parity drives required by segtype */
+	uint32_t parity_devs;		/* Parity drives required by segtype */
 
 	struct segtype_handler *ops;
 	const char *name;
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index df22b54..8c6bb72 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -437,18 +437,18 @@ static const struct raid_type {
 	unsigned parity;
 	uint64_t extra_flags;
 } _raid_types[] = {
-	{ SEG_TYPE_NAME_RAID1,    0, SEG_AREAS_MIRRORED },
-	{ SEG_TYPE_NAME_RAID10,   0, SEG_AREAS_MIRRORED },
-	{ SEG_TYPE_NAME_RAID4,    1 },
-	{ SEG_TYPE_NAME_RAID5,    1 },
-	{ SEG_TYPE_NAME_RAID5_LA, 1 },
-	{ SEG_TYPE_NAME_RAID5_LS, 1 },
-	{ SEG_TYPE_NAME_RAID5_RA, 1 },
-	{ SEG_TYPE_NAME_RAID5_RS, 1 },
-	{ SEG_TYPE_NAME_RAID6,    2 },
-	{ SEG_TYPE_NAME_RAID6_NC, 2 },
-	{ SEG_TYPE_NAME_RAID6_NR, 2 },
-	{ SEG_TYPE_NAME_RAID6_ZR, 2 }
+	{ SEG_TYPE_NAME_RAID1,    0, SEG_RAID1 | SEG_AREAS_MIRRORED },
+	{ SEG_TYPE_NAME_RAID10,   0, SEG_RAID10 | SEG_AREAS_MIRRORED },
+	{ SEG_TYPE_NAME_RAID4,    1, SEG_RAID4 },
+	{ SEG_TYPE_NAME_RAID5,    1, SEG_RAID5 },
+	{ SEG_TYPE_NAME_RAID5_LA, 1, SEG_RAID5_LA },
+	{ SEG_TYPE_NAME_RAID5_LS, 1, SEG_RAID5_LS },
+	{ SEG_TYPE_NAME_RAID5_RA, 1, SEG_RAID5_RA },
+	{ SEG_TYPE_NAME_RAID5_RS, 1, SEG_RAID5_RS },
+	{ SEG_TYPE_NAME_RAID6,    2, SEG_RAID6 },
+	{ SEG_TYPE_NAME_RAID6_NC, 2, SEG_RAID6_NC },
+	{ SEG_TYPE_NAME_RAID6_NR, 2, SEG_RAID6_NR },
+	{ SEG_TYPE_NAME_RAID6_ZR, 2, SEG_RAID6_ZR }
 };
 
 static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,



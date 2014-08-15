From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 15 Aug 2014 11:28:55 +0000 (UTC)
Subject: master - refactor: add defines for raid segtypes
Message-ID: <20140815112855.E044060703@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec0d2f7aa4da4e433e26bc252626eae6febbe4d6
Commit:        ec0d2f7aa4da4e433e26bc252626eae6febbe4d6
Parent:        bf78e55ef311b0bea7993c5405d637e46a1b8394
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 15 13:03:21 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 15 13:28:43 2014 +0200

refactor: add defines for raid segtypes

This will be reused later on in upcoming code...
---
 lib/metadata/segtype.h |   13 +++++++++++++
 lib/raid/raid.c        |   24 ++++++++++++------------
 2 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 891c378..080cf4e 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -150,6 +150,19 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
+#define SEG_TYPE_NAME_RAID1	"raid1"
+#define SEG_TYPE_NAME_RAID10	"raid10"
+#define SEG_TYPE_NAME_RAID4	"raid4"
+#define SEG_TYPE_NAME_RAID5	"raid5"
+#define SEG_TYPE_NAME_RAID5_LA	"raid5_la"
+#define SEG_TYPE_NAME_RAID5_LS	"raid5_ls"
+#define SEG_TYPE_NAME_RAID5_RA	"raid5_ra"
+#define SEG_TYPE_NAME_RAID5_RS	"raid5_rs"
+#define SEG_TYPE_NAME_RAID6	"raid6"
+#define SEG_TYPE_NAME_RAID6_NC	"raid6_nc"
+#define SEG_TYPE_NAME_RAID6_NR	"raid6_nr"
+#define SEG_TYPE_NAME_RAID6_ZR	"raid6_zr"
+
 #ifdef REPLICATOR_INTERNAL
 int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index c3f5c3f..5aad447 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -443,18 +443,18 @@ static const struct raid_type {
 	unsigned parity;
 	int extra_flags;
 } _raid_types[] = {
-	{ "raid1",    0, SEG_AREAS_MIRRORED },
-	{ "raid10",   0, SEG_AREAS_MIRRORED },
-	{ "raid4",    1 },
-	{ "raid5",    1 },
-	{ "raid5_la", 1 },
-	{ "raid5_ls", 1 },
-	{ "raid5_ra", 1 },
-	{ "raid5_rs", 1 },
-	{ "raid6",    2 },
-	{ "raid6_nc", 2 },
-	{ "raid6_nr", 2 },
-	{ "raid6_zr", 2 }
+	{ SEG_TYPE_NAME_RAID1,    0, SEG_AREAS_MIRRORED },
+	{ SEG_TYPE_NAME_RAID10,   0, SEG_AREAS_MIRRORED },
+	{ SEG_TYPE_NAME_RAID4,    1 },
+	{ SEG_TYPE_NAME_RAID5,    1 },
+	{ SEG_TYPE_NAME_RAID5_LA, 1 },
+	{ SEG_TYPE_NAME_RAID5_LS, 1 },
+	{ SEG_TYPE_NAME_RAID5_RA, 1 },
+	{ SEG_TYPE_NAME_RAID5_RS, 1 },
+	{ SEG_TYPE_NAME_RAID6,    2 },
+	{ SEG_TYPE_NAME_RAID6_NC, 2 },
+	{ SEG_TYPE_NAME_RAID6_NR, 2 },
+	{ SEG_TYPE_NAME_RAID6_ZR, 2 }
 };
 
 static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,



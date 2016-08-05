From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  5 Aug 2016 13:00:54 +0000 (UTC)
Subject: master - segtypes: Further segtype macros.
Message-ID: <20160805130054.684ED6055C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b66fa91c46f88029eb730f07524d2c09a4ded559
Commit:        b66fa91c46f88029eb730f07524d2c09a4ded559
Parent:        b1b0b134ecd55fad004d56301c52b32234db3c9a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 5 14:00:08 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 5 14:00:40 2016 +0100

segtypes: Further segtype macros.

---
 lib/metadata/lv_manip.c |    2 ++
 lib/metadata/segtype.c  |    2 +-
 lib/metadata/segtype.h  |   14 ++++++++++++++
 3 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a465c4c..d74c571 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -119,6 +119,7 @@ enum {
 	LV_TYPE_RAID10,
 	LV_TYPE_RAID4,
 	LV_TYPE_RAID5,
+	LV_TYPE_RAID5_N,
 	LV_TYPE_RAID5_LA,
 	LV_TYPE_RAID5_RA,
 	LV_TYPE_RAID5_LS,
@@ -169,6 +170,7 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_RAID10] =				SEG_TYPE_NAME_RAID10,
 	[LV_TYPE_RAID4] =				SEG_TYPE_NAME_RAID4,
 	[LV_TYPE_RAID5] =				SEG_TYPE_NAME_RAID5,
+	[LV_TYPE_RAID5_N] =				SEG_TYPE_NAME_RAID5_N,
 	[LV_TYPE_RAID5_LA] =				SEG_TYPE_NAME_RAID5_LA,
 	[LV_TYPE_RAID5_RA] =				SEG_TYPE_NAME_RAID5_RA,
 	[LV_TYPE_RAID5_LS] =				SEG_TYPE_NAME_RAID5_LS,
diff --git a/lib/metadata/segtype.c b/lib/metadata/segtype.c
index 35823d9..b66ab02 100644
--- a/lib/metadata/segtype.c
+++ b/lib/metadata/segtype.c
@@ -47,7 +47,7 @@ struct segment_type *get_segtype_from_flag(struct cmd_context *cmd, uint64_t fla
 		if (flag & segtype->flags)
 			return segtype;
 
-	log_error(INTERNAL_ERROR "Unrecognised segment type flag 0x%" PRIx64, flag);
+	log_error(INTERNAL_ERROR "Unrecognised segment type flag 0x%016" PRIx64, flag);
 
 	return NULL;
 }
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 0da2d94..2fafa19 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -90,6 +90,7 @@ struct dev_manager;
 #define SEG_TYPE_NAME_RAID10		"raid10"
 #define SEG_TYPE_NAME_RAID4		"raid4"
 #define SEG_TYPE_NAME_RAID5		"raid5"
+#define SEG_TYPE_NAME_RAID5_N		"raid5_n"
 #define SEG_TYPE_NAME_RAID5_LA		"raid5_la"
 #define SEG_TYPE_NAME_RAID5_LS		"raid5_ls"
 #define SEG_TYPE_NAME_RAID5_RA		"raid5_ra"
@@ -98,6 +99,11 @@ struct dev_manager;
 #define SEG_TYPE_NAME_RAID6_NC		"raid6_nc"
 #define SEG_TYPE_NAME_RAID6_NR		"raid6_nr"
 #define SEG_TYPE_NAME_RAID6_ZR		"raid6_zr"
+#define SEG_TYPE_NAME_RAID6_LA_6	"raid6_la_6"
+#define SEG_TYPE_NAME_RAID6_LS_6	"raid6_ls_6"
+#define SEG_TYPE_NAME_RAID6_RA_6	"raid6_ra_6"
+#define SEG_TYPE_NAME_RAID6_RS_6	"raid6_rs_6"
+#define SEG_TYPE_NAME_RAID6_N_6		"raid6_n_6"
 
 #define segtype_is_linear(segtype)	(!strcmp(segtype->name, SEG_TYPE_NAME_LINEAR))
 #define segtype_is_striped_target(segtype)	((segtype)->flags & SEG_STRIPED_TARGET ? 1 : 0)
@@ -114,6 +120,7 @@ struct dev_manager;
 #define segtype_is_raid4(segtype)	((segtype)->flags & SEG_RAID4 ? 1 : 0)
 #define segtype_is_any_raid5(segtype)	((segtype)->flags & \
 					 (SEG_RAID5_LS|SEG_RAID5_LA|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_N) ? 1 : 0)
+#define segtype_is_raid5_n(segtype)	((segtype)->flags & SEG_RAID5_N ? 1 : 0)
 #define segtype_is_raid5_la(segtype)	((segtype)->flags & SEG_RAID5_LA ? 1 : 0)
 #define segtype_is_raid5_ra(segtype)	((segtype)->flags & SEG_RAID5_RA ? 1 : 0)
 #define segtype_is_raid5_ls(segtype)	((segtype)->flags & SEG_RAID5_LS ? 1 : 0)
@@ -123,8 +130,11 @@ struct dev_manager;
 					  SEG_RAID6_LA_6|SEG_RAID6_LS_6|SEG_RAID6_RA_6|SEG_RAID6_RS_6|SEG_RAID6_N_6) ? 1 : 0)
 #define segtype_is_raid6_nc(segtype)	((segtype)->flags & SEG_RAID6_NC ? 1 : 0)
 #define segtype_is_raid6_nr(segtype)	((segtype)->flags & SEG_RAID6_NR ? 1 : 0)
+#define segtype_is_raid6_n_6(segtype)	((segtype)->flags & SEG_RAID6_N_6 ? 1 : 0)
 #define segtype_is_raid6_zr(segtype)	((segtype)->flags & SEG_RAID6_ZR ? 1 : 0)
+#define segtype_is_any_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
 #define segtype_is_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
+#define segtype_is_raid10_near(segtype)	segtype_is_raid10(segtype)
 #define segtype_is_raid_with_meta(segtype)	(segtype_is_raid(segtype) && !segtype_is_raid0(segtype))
 #define segtype_is_snapshot(segtype)	((segtype)->flags & SEG_SNAPSHOT ? 1 : 0)
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
@@ -154,6 +164,7 @@ struct dev_manager;
 #define seg_is_raid1(seg)	segtype_is_raid1((seg)->segtype)
 #define seg_is_raid4(seg)	segtype_is_raid4((seg)->segtype)
 #define seg_is_any_raid5(seg)	segtype_is_any_raid5((seg)->segtype)
+#define seg_is_raid5_n(seg)	segtype_is_raid5_n((seg)->segtype)
 #define seg_is_raid5_la(seg)	segtype_is_raid5_la((seg)->segtype)
 #define seg_is_raid5_ra(seg)	segtype_is_raid5_ra((seg)->segtype)
 #define seg_is_raid5_ls(seg)	segtype_is_raid5_ls((seg)->segtype)
@@ -162,7 +173,10 @@ struct dev_manager;
 #define seg_is_raid6_zr(seg)	segtype_is_raid6_zr((seg)->segtype)
 #define seg_is_raid6_nr(seg)	segtype_is_raid6_nr((seg)->segtype)
 #define seg_is_raid6_nc(seg)	segtype_is_raid6_nc((seg)->segtype)
+#define seg_is_raid6_n_6(seg)	segtype_is_raid6_n_6((seg)->segtype)
+#define seg_is_any_raid10(seg)	segtype_is_any_raid10((seg)->segtype)
 #define seg_is_raid10(seg)	segtype_is_raid10((seg)->segtype)
+#define seg_is_raid10_near(seg)	segtype_is_raid10_near((seg)->segtype)
 #define seg_is_raid_with_meta(seg)	segtype_is_raid_with_meta((seg)->segtype)
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)



From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Sep 2015 19:44:20 +0000 (UTC)
Subject: master - segtypes: Use flags in raid segtype macros.
Message-ID: <20150924194420.636A560EEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eab099b22190cfaf68f013e785dd13c43277fea1
Commit:        eab099b22190cfaf68f013e785dd13c43277fea1
Parent:        3036620b488800027d1ec37b5cbe65f6f180e9c7
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Sep 24 20:26:33 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Sep 24 20:43:18 2015 +0100

segtypes: Use flags in raid segtype macros.

---
 lib/metadata/segtype.h |   33 +++++++++++++++++----------------
 1 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 09034e9..72c64f9 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -101,20 +101,22 @@ struct dev_manager;
 #define segtype_is_mirror(segtype)	((segtype)->flags & SEG_MIRROR ? 1 : 0)
 #define segtype_is_pool(segtype)	((segtype)->flags & (SEG_CACHE_POOL | SEG_THIN_POOL)  ? 1 : 0)
 #define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
-#define segtype_is_raid1(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID1))
-#define segtype_is_raid4(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID4))
-#define segtype_is_raid5(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID5))
-#define segtype_is_any_raid5(segtype)	(!strncmp((segtype)->name, SEG_TYPE_NAME_RAID5, strlen(SEG_TYPE_NAME_RAID5)))
-#define segtype_is_raid5_la(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID5_LA))
-#define segtype_is_raid5_ra(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID5_RA))
-#define segtype_is_raid5_ls(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID5_LS))
-#define segtype_is_raid5_rs(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID5_RS))
-#define segtype_is_any_raid6(segtype)	(!strncmp((segtype)->name, SEG_TYPE_NAME_RAID6, strlen(SEG_TYPE_NAME_RAID6)))
-#define segtype_is_raid6_zr(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID6_ZR))
-#define segtype_is_raid6_nr(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID6_NR))
-#define segtype_is_raid6_nc(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID6_NC))
-#define segtype_is_raid10(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID10))
-#define segtype_is_snapshot(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_SNAPSHOT))
+#define segtype_is_raid1(segtype)	((segtype)->flags & SEG_RAID1 ? 1 : 0)
+#define segtype_is_raid4(segtype)	((segtype)->flags & SEG_RAID4 ? 1 : 0)
+#define segtype_is_any_raid5(segtype)	((segtype)->flags & \
+					 (SEG_RAID5_LS|SEG_RAID5_LA|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_N) ? 1 : 0)
+#define segtype_is_raid5_la(segtype)	((segtype)->flags & SEG_RAID5_LA ? 1 : 0)
+#define segtype_is_raid5_ra(segtype)	((segtype)->flags & SEG_RAID5_RA ? 1 : 0)
+#define segtype_is_raid5_ls(segtype)	((segtype)->flags & SEG_RAID5_LS ? 1 : 0)
+#define segtype_is_raid5_rs(segtype)	((segtype)->flags & SEG_RAID5_RS ? 1 : 0)
+#define segtype_is_any_raid6(segtype)	((segtype)->flags & \
+					 (SEG_RAID6_ZR|SEG_RAID6_NC|SEG_RAID6_NR| \
+					  SEG_RAID6_LA_6|SEG_RAID6_LS_6|SEG_RAID6_RA_6|SEG_RAID6_RS_6|SEG_RAID6_N_6) ? 1 : 0)
+#define segtype_is_raid6_nc(segtype)	((segtype)->flags & SEG_RAID6_NC ? 1 : 0)
+#define segtype_is_raid6_nr(segtype)	((segtype)->flags & SEG_RAID6_NR ? 1 : 0)
+#define segtype_is_raid6_zr(segtype)	((segtype)->flags & SEG_RAID6_ZR ? 1 : 0)
+#define segtype_is_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
+#define segtype_is_snapshot(segtype)	((segtype)->flags & SEG_SNAPSHOT ? 1 : 0)
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_thin(segtype)	((segtype)->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
 #define segtype_is_thin_pool(segtype)	((segtype)->flags & SEG_THIN_POOL ? 1 : 0)
@@ -131,7 +133,6 @@ struct dev_manager;
 #define seg_is_raid(seg)	segtype_is_raid((seg)->segtype)
 #define seg_is_raid1(seg)	segtype_is_raid1((seg)->segtype)
 #define seg_is_raid4(seg)	segtype_is_raid4((seg)->segtype)
-#define seg_is_raid5(seg)	segtype_is_raid5((seg)->segtype)
 #define seg_is_any_raid5(seg)	segtype_is_any_raid5((seg)->segtype)
 #define seg_is_raid5_la(seg)	segtype_is_raid5_la((seg)->segtype)
 #define seg_is_raid5_ra(seg)	segtype_is_raid5_ra((seg)->segtype)
@@ -144,7 +145,7 @@ struct dev_manager;
 #define seg_is_raid10(seg)	segtype_is_raid10((seg)->segtype)
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
-#define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
+#define seg_is_snapshot(seg)	segtype_is_snapshot((seg)->segtype)
 #define seg_is_striped(seg)	segtype_is_striped((seg)->segtype)
 #define seg_is_thin(seg)	segtype_is_thin((seg)->segtype)
 #define seg_is_thin_pool(seg)	segtype_is_thin_pool((seg)->segtype)



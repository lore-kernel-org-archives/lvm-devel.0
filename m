From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat, 31 Jan 2015 14:10:43 +0000 (UTC)
Subject: dev-lvmguy-raid-takeover-reshape-resize - start adding transitions to _adjust_final_segtype()
Message-ID: <20150131141043.87F92610B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=645f4fad66ce5d649776a1ec98171616b5bec40e
Commit:        645f4fad66ce5d649776a1ec98171616b5bec40e
Parent:        9bded3b386833360dff3a5bd9bba4de4297f1914
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Jan 31 15:09:12 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Jan 31 15:09:12 2015 +0100

start adding transitions to _adjust_final_segtype()

---
 lib/metadata/raid_manip.c |   43 +++++++++++++++++++++++++++++++++++++++++--
 tools/lvconvert.c         |    4 +++-
 2 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4781d97..79997d9 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2507,18 +2507,57 @@ static const struct segment_type *_adjust_final_segtype(struct logical_volume *l
 {
 	unsigned cn, pn;
 	struct possible_takeover pt[] = {
+		{ .current_name = SEG_TYPE_NAME_STRIPED,
+		  .possible_names = { SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_RAID5_N, SEG_TYPE_NAME_RAID6_N_6, NULL } },
 		{ .current_name = SEG_TYPE_NAME_RAID0,
 		  .possible_names = { SEG_TYPE_NAME_RAID5_N, SEG_TYPE_NAME_RAID6_N_6, NULL } },
 		{ .current_name = SEG_TYPE_NAME_RAID1,
 		  .possible_names = { SEG_TYPE_NAME_RAID5_N, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID4,
+		  .possible_names = { SEG_TYPE_NAME_RAID5_0, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID4_N,
+		  .possible_names = { SEG_TYPE_NAME_RAID5_N, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID5,
+		  .possible_names = { SEG_TYPE_NAME_RAID6_LS_6, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID5_0,
+		  .possible_names = { SEG_TYPE_NAME_RAID6_0_6, NULL } },
 		{ .current_name = SEG_TYPE_NAME_RAID5_N,
 		  .possible_names = { SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_RAID1,
 				      SEG_TYPE_NAME_STRIPED, SEG_TYPE_NAME_RAID6_N_6, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID5_LS,
+		  .possible_names = { SEG_TYPE_NAME_RAID6_LS_6, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID5_LA,
+		  .possible_names = { SEG_TYPE_NAME_RAID6_LA_6, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID5_RS,
+		  .possible_names = { SEG_TYPE_NAME_RAID6_RS_6, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID5_RA,
+		  .possible_names = { SEG_TYPE_NAME_RAID6_RA_6, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID6_ZR,
+		  .possible_names = { SEG_TYPE_NAME_RAID6_N_6, SEG_TYPE_NAME_RAID5_N,
+				      SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_STRIPED, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID6_NC,
+		  .possible_names = { SEG_TYPE_NAME_RAID6_N_6, SEG_TYPE_NAME_RAID5_N,
+				      SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_STRIPED, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID6_NR,
+		  .possible_names = { SEG_TYPE_NAME_RAID6_N_6, SEG_TYPE_NAME_RAID5_N,
+				      SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_STRIPED, NULL } },
 		{ .current_name = SEG_TYPE_NAME_RAID6_N_6,
-		  .possible_names = { SEG_TYPE_NAME_RAID5_N, SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_STRIPED, NULL } },
+		  .possible_names = { SEG_TYPE_NAME_RAID5_N, SEG_TYPE_NAME_RAID0,
+				      SEG_TYPE_NAME_STRIPED, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID6_LS_6,
+		  .possible_names = { SEG_TYPE_NAME_RAID5_LS, SEG_TYPE_NAME_RAID5_N,
+				      SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_STRIPED, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID6_LA_6,
+		  .possible_names = { SEG_TYPE_NAME_RAID5_LA, SEG_TYPE_NAME_RAID5_N,
+				      SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_STRIPED, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID6_RS_6,
+		  .possible_names = { SEG_TYPE_NAME_RAID5_RS, SEG_TYPE_NAME_RAID5_N,
+				      SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_STRIPED, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID6_RA_6,
+		  .possible_names = { SEG_TYPE_NAME_RAID5_RA, SEG_TYPE_NAME_RAID5_N,
+				      SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_STRIPED, NULL } },
 	};
 
-
 	for (cn = 0; cn < ARRAY_SIZE(pt); cn++) {
 		if (!strcmp(segtype->name, pt[cn].current_name)) {
 			for (pn = 0; pt[cn].possible_names[pn]; pn++)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c72b73e..c969341 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -16,6 +16,8 @@
 #include "polldaemon.h"
 #include "lv_alloc.h"
 
+#define printf(a ...)
+
 struct lvconvert_params {
 	int cache;
 	int force;
@@ -1900,7 +1902,6 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	struct lv_segment *seg = first_seg(lv);
 	dm_percent_t sync_percent;
 
-#define printf(a ...)
 printf("stripes_ARG=%u stripes_long_ARG=%u\n", arg_count(lv->vg->cmd, stripes_ARG), arg_count(lv->vg->cmd, stripes_long_ARG));
 	if (!arg_count(cmd, type_ARG))
 		lp->segtype = seg->segtype;
@@ -1935,6 +1936,7 @@ printf("stripes_ARG=%u stripes_long_ARG=%u\n", arg_count(lv->vg->cmd, stripes_AR
 			image_count -= lp->mirrors;
 		else
 			image_count = lp->mirrors + 1;
+printf("image_count=%u", image_count);
 
 		track = arg_count(cmd, trackchanges_ARG);
 		if (image_count < 1 || (track && lp->mirrors != 1)) {



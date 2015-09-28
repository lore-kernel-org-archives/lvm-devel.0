From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 28 Sep 2015 13:28:52 +0000 (UTC)
Subject: master - raid: Use loop for text uint32_t parameter import.
Message-ID: <20150928132852.A99BF60CFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d815e5f5a17963a09b103177770e9af80c90e0f
Commit:        9d815e5f5a17963a09b103177770e9af80c90e0f
Parent:        7097663dddad0716059783219e9e3d4748db8188
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Sep 28 14:21:00 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 28 14:28:03 2015 +0100

raid: Use loop for text uint32_t parameter import.

Plus some other tidying up of the same file.
---
 lib/raid/raid.c |   77 ++++++++++++++++++++-----------------------------------
 1 files changed, 28 insertions(+), 49 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 8c6bb72..f75e1f7 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -55,7 +55,7 @@ static int _raid_text_import_areas(struct lv_segment *seg,
 				   const struct dm_config_value *cv)
 {
 	unsigned int s;
-	struct logical_volume *lv1;
+	struct logical_volume *lv;
 	const char *seg_name = dm_config_parent_name(sn);
 
 	if (!seg->area_count) {
@@ -75,23 +75,23 @@ static int _raid_text_import_areas(struct lv_segment *seg,
 		}
 
 		/* Metadata device comes first */
-		if (!(lv1 = find_lv(seg->lv->vg, cv->v.str))) {
+		if (!(lv = find_lv(seg->lv->vg, cv->v.str))) {
 			log_error("Couldn't find volume '%s' for segment '%s'.",
 				  cv->v.str ? : "NULL", seg_name);
 			return 0;
 		}
-		if (!set_lv_segment_area_lv(seg, s, lv1, 0, RAID_META))
-				return_0;
+		if (!set_lv_segment_area_lv(seg, s, lv, 0, RAID_META))
+			return_0;
 
 		/* Data device comes second */
 		cv = cv->next;
-		if (!(lv1 = find_lv(seg->lv->vg, cv->v.str))) {
+		if (!(lv = find_lv(seg->lv->vg, cv->v.str))) {
 			log_error("Couldn't find volume '%s' for segment '%s'.",
 				  cv->v.str ? : "NULL", seg_name);
 			return 0;
 		}
-		if (!set_lv_segment_area_lv(seg, s, lv1, 0, RAID_IMAGE))
-				return_0;
+		if (!set_lv_segment_area_lv(seg, s, lv, 0, RAID_IMAGE))
+			return_0;
 	}
 
 	/*
@@ -111,49 +111,28 @@ static int _raid_text_import(struct lv_segment *seg,
 			     struct dm_hash_table *pv_hash)
 {
 	const struct dm_config_value *cv;
+	const struct {
+		const char *name;
+		uint32_t *var;
+	} raid_attr_import[] = {
+		{ "region_size",	&seg->region_size },
+		{ "stripe_size",	&seg->stripe_size },
+		{ "writebehind",	&seg->writebehind },
+		{ "min_recovery_rate",	&seg->min_recovery_rate },
+		{ "max_recovery_rate",	&seg->max_recovery_rate },
+	}, *aip = raid_attr_import;
+	int i;
 
-	if (dm_config_has_node(sn, "region_size")) {
-		if (!dm_config_get_uint32(sn, "region_size", &seg->region_size)) {
-			log_error("Couldn't read 'region_size' for "
-				  "segment %s of logical volume %s.",
-				  dm_config_parent_name(sn), seg->lv->name);
-			return 0;
-		}
-	}
-	if (dm_config_has_node(sn, "stripe_size")) {
-		if (!dm_config_get_uint32(sn, "stripe_size", &seg->stripe_size)) {
-			log_error("Couldn't read 'stripe_size' for "
-				  "segment %s of logical volume %s.",
-				  dm_config_parent_name(sn), seg->lv->name);
-			return 0;
-		}
-	}
-	if (dm_config_has_node(sn, "writebehind")) {
-		if (!dm_config_get_uint32(sn, "writebehind", &seg->writebehind)) {
-			log_error("Couldn't read 'writebehind' for "
-				  "segment %s of logical volume %s.",
-				  dm_config_parent_name(sn), seg->lv->name);
-			return 0;
-		}
-	}
-	if (dm_config_has_node(sn, "min_recovery_rate")) {
-		if (!dm_config_get_uint32(sn, "min_recovery_rate",
-					  &seg->min_recovery_rate)) {
-			log_error("Couldn't read 'min_recovery_rate' for "
-				  "segment %s of logical volume %s.",
-				  dm_config_parent_name(sn), seg->lv->name);
-			return 0;
-		}
-	}
-	if (dm_config_has_node(sn, "max_recovery_rate")) {
-		if (!dm_config_get_uint32(sn, "max_recovery_rate",
-					  &seg->max_recovery_rate)) {
-			log_error("Couldn't read 'max_recovery_rate' for "
-				  "segment %s of logical volume %s.",
-				  dm_config_parent_name(sn), seg->lv->name);
-			return 0;
+	for (i = 0; i < DM_ARRAY_SIZE(raid_attr_import); i++, aip++) {
+		if (dm_config_has_node(sn, aip->name)) {
+			if (!dm_config_get_uint32(sn, aip->name, aip->var)) {
+				log_error("Couldn't read '%s' for segment %s of logical volume %s.",
+					  aip->name, dm_config_parent_name(sn), seg->lv->name);
+				return 0;
+			}
 		}
 	}
+
 	if (!dm_config_get_list(sn, "raids", &cv)) {
 		log_error("Couldn't find RAID array for "
 			  "segment %s of logical volume %s.",
@@ -162,7 +141,7 @@ static int _raid_text_import(struct lv_segment *seg,
 	}
 
 	if (!_raid_text_import_areas(seg, sn, cv)) {
-		log_error("Failed to import RAID images");
+		log_error("Failed to import RAID component pairs.");
 		return 0;
 	}
 



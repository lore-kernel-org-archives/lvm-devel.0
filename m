From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 13 Oct 2013 22:31:00 +0000 (UTC)
Subject: master - snapshot: rework parsing of snapshot metadata
Message-ID: <20131013223100.26A9060CFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=851bba258cc6989db78d547b9983c523caae9026
Commit:        851bba258cc6989db78d547b9983c523caae9026
Parent:        1146691afc740257d03c7ca53bfa07918a4bc715
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 9 14:50:51 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 00:26:58 2013 +0200

snapshot: rework parsing of snapshot metadata

Add better parsing code for snapshot metadata, which describe
properly errors found for snapshot segment.
---
 WHATS_NEW               |    1 +
 lib/snapshot/snapshot.c |   59 +++++++++++++++++++++++------------------------
 2 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6539f19..887a256 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Improve parsing of snapshot lv segment.
   Add workaround for deactivation problem of opened virtual snapshot.
   Disable unsupported merge for virtual snapshot.
   Move code to remove virtual snapshot from tools to lib for lvm2app.
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 506d618..91e778f 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -23,6 +23,10 @@
 #include "str_list.h"
 #include "defaults.h"
 
+#define SEG_LOG_ERROR(t, p...) \
+	log_error(t " segment %s of logical volume %s.", ## p, \
+		  dm_config_parent_name(sn), seg->lv->name), 0;
+
 static const char *_snap_name(const struct lv_segment *seg)
 {
 	return seg->segtype->name;
@@ -41,50 +45,45 @@ static int _snap_text_import(struct lv_segment *seg, const struct dm_config_node
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	uint32_t chunk_size;
-	const char *org_name, *cow_name;
 	struct logical_volume *org, *cow;
-	int old_suppress, merge = 0;
+	const char *org_name = NULL, *cow_name = NULL;
+	int merge = 0;
 
 	if (!dm_config_get_uint32(sn, "chunk_size", &chunk_size)) {
 		log_error("Couldn't read chunk size for snapshot.");
 		return 0;
 	}
 
-	old_suppress = log_suppress(1);
-
-	if ((cow_name = dm_config_find_str(sn, "merging_store", NULL))) {
-		if (dm_config_find_str(sn, "cow_store", NULL)) {
-			log_suppress(old_suppress);
-			log_error("Both snapshot cow and merging storage were specified.");
-			return 0;
-		}
+	if (dm_config_has_node(sn, "merging_store")) {
+		if (!(cow_name = dm_config_find_str(sn, "merging_store", NULL)))
+			return SEG_LOG_ERROR("Merging store must be a string in");
 		merge = 1;
 	}
-	else if (!(cow_name = dm_config_find_str(sn, "cow_store", NULL))) {
-		log_suppress(old_suppress);
-		log_error("Snapshot cow storage not specified.");
-		return 0;
-	}
 
-	if (!(org_name = dm_config_find_str(sn, "origin", NULL))) {
-		log_suppress(old_suppress);
-		log_error("Snapshot origin not specified.");
-		return 0;
+	if (dm_config_has_node(sn, "cow_store")) {
+		if (cow_name)
+			return SEG_LOG_ERROR("Both snapshot cow and merging storage were specified in");
+
+		if (!(cow_name = dm_config_find_str(sn, "cow_store", NULL)))
+			return SEG_LOG_ERROR("Cow store must be a string in");
 	}
 
-	log_suppress(old_suppress);
+	if (!cow_name)
+		return SEG_LOG_ERROR("Snapshot cow storage not specified in");
 
-	if (!(cow = find_lv(seg->lv->vg, cow_name))) {
-		log_error("Unknown logical volume specified for "
-			  "snapshot cow store.");
-		return 0;
-	}
+	if (!dm_config_has_node(sn, "origin"))
+		return SEG_LOG_ERROR("Snapshot origin not specified in");
 
-	if (!(org = find_lv(seg->lv->vg, org_name))) {
-		log_error("Unknown logical volume specified for "
-			  "snapshot origin.");
-		return 0;
-	}
+	if (!(org_name = dm_config_find_str(sn, "origin", NULL)))
+		return SEG_LOG_ERROR("Snapshot origin must be a string in");
+
+	if (!(cow = find_lv(seg->lv->vg, cow_name)))
+		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
+				     "snapshot cow store in", cow_name);
+
+	if (!(org = find_lv(seg->lv->vg, org_name)))
+		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
+			  "snapshot origin in", org_name);
 
 	init_snapshot_seg(seg, org, cow, chunk_size, merge);
 



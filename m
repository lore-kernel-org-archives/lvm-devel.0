From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 14 Feb 2017 09:25:37 +0000 (UTC)
Subject: master - libdm: move code for _stats_resize_group
Message-ID: <20170214092537.C679560ED1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3350eb67cc66dcd2c6ee6456a3524bc723aa4e38
Commit:        3350eb67cc66dcd2c6ee6456a3524bc723aa4e38
Parent:        6118b0fb93502e1ba06e5a4a696a264c0e4af0ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 14 09:53:13 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 14 10:24:56 2017 +0100

libdm: move code for _stats_resize_group

Code is only needed when "fiemap.h" so keep it under single #ifdef.
---
 libdm/libdm-stats.c |   62 +++++++++++++++++++++++++-------------------------
 1 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 587c748..3f6730e 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3868,37 +3868,6 @@ static int _extent_start_compare(const void *p1, const void *p2)
 	return 1;
 }
 
-/*
- * Resize the group bitmap corresponding to group_id so that it can
- * contain at least num_regions members.
- */
-static int _stats_resize_group(struct dm_stats_group *group, int num_regions)
-{
-	int last_bit = dm_bit_get_last(group->regions);
-	dm_bitset_t new, old;
-
-	if (last_bit >= num_regions) {
-		log_error("Cannot resize group bitmap to %d with bit %d set.",
-			  num_regions, last_bit);
-		return 0;
-	}
-
-	log_very_verbose("Resizing group bitmap from %d to %d (last_bit: %d).",
-			 group->regions[0], num_regions, last_bit);
-
-	new = dm_bitset_create(NULL, num_regions);
-	if (!new) {
-		log_error("Could not allocate memory for new group bitmap.");
-		return 0;
-	}
-
-	old = group->regions;
-	dm_bit_copy(new, old);
-	group->regions = new;
-	dm_bitset_destroy(old);
-	return 1;
-}
-
 static int _stats_create_group(struct dm_stats *dms, dm_bitset_t regions,
 			       const char *alias, uint64_t *group_id)
 {
@@ -4203,6 +4172,37 @@ int dm_stats_get_group_descriptor(const struct dm_stats *dms,
 
 #ifdef HAVE_LINUX_FIEMAP_H
 /*
+ * Resize the group bitmap corresponding to group_id so that it can
+ * contain at least num_regions members.
+ */
+static int _stats_resize_group(struct dm_stats_group *group, int num_regions)
+{
+	int last_bit = dm_bit_get_last(group->regions);
+	dm_bitset_t new, old;
+
+	if (last_bit >= num_regions) {
+		log_error("Cannot resize group bitmap to %d with bit %d set.",
+			  num_regions, last_bit);
+		return 0;
+	}
+
+	log_very_verbose("Resizing group bitmap from %d to %d (last_bit: %d).",
+			 group->regions[0], num_regions, last_bit);
+
+	new = dm_bitset_create(NULL, num_regions);
+	if (!new) {
+		log_error("Could not allocate memory for new group bitmap.");
+		return 0;
+	}
+
+	old = group->regions;
+	dm_bit_copy(new, old);
+	group->regions = new;
+	dm_bitset_destroy(old);
+	return 1;
+}
+
+/*
  * Group a table of region_ids corresponding to the extents of a file.
  */
 static int _stats_group_file_regions(struct dm_stats *dms, uint64_t *region_ids,



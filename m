From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:04:29 -0400
Subject: master - libdm: make _stats_resize_group() num_regions argument uint64_t
Message-ID: <201703300904.v2U94TgP019973@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=833b02106d448dcec7a3e9ff23a8ec2cdc5bb3ab
Commit:        833b02106d448dcec7a3e9ff23a8ec2cdc5bb3ab
Parent:        722542fabb30915653a222a6dca8f34338db4e80
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 20:42:36 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 10:02:39 2017 +0100

libdm: make _stats_resize_group() num_regions argument uint64_t

---
 libdm/libdm-stats.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 5a454fd..2e6022d 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4181,21 +4181,23 @@ int dm_stats_get_group_descriptor(const struct dm_stats *dms,
  * Resize the group bitmap corresponding to group_id so that it can
  * contain at least num_regions members.
  */
-static int _stats_resize_group(struct dm_stats_group *group, int num_regions)
+static int _stats_resize_group(struct dm_stats_group *group,
+			       uint64_t num_regions)
 {
-	int last_bit = dm_bit_get_last(group->regions);
+	uint64_t last_bit = dm_bit_get_last(group->regions);
 	dm_bitset_t new, old;
 
 	if (last_bit >= num_regions) {
-		log_error("Cannot resize group bitmap to %d with bit %d set.",
-			  num_regions, last_bit);
+		log_error("Cannot resize group bitmap to " FMTu64
+			  " with bit " FMTu64 " set.", num_regions, last_bit);
 		return 0;
 	}
 
-	log_very_verbose("Resizing group bitmap from %d to %d (last_bit: %d).",
+	log_very_verbose("Resizing group bitmap from " FMTu64
+			 " to " FMTu64 " (last_bit: " FMTu64 ").",
 			 group->regions[0], num_regions, last_bit);
 
-	new = dm_bitset_create(NULL, num_regions);
+	new = dm_bitset_create(NULL, (unsigned) num_regions);
 	if (!new) {
 		log_error("Could not allocate memory for new group bitmap.");
 		return 0;



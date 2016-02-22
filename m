From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Feb 2016 13:28:32 +0000 (UTC)
Subject: master - cleanup: use char arrays.
Message-ID: <20160222132832.2A1A660F3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3178cfc81823589cde16668b90a04a35fe0b758b
Commit:        3178cfc81823589cde16668b90a04a35fe0b758b
Parent:        2d6ef123a673d0982e9d3900ab4953ce146e4fc6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 22 14:11:02 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 22 14:27:44 2016 +0100

cleanup: use char arrays.

---
 libdm/libdm-stats.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 1eeca06..82d3fa5 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -453,7 +453,7 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 				       struct dm_stats_region *region,
 				       const char *histogram)
 {
-	static const char *_valid_chars = "0123456789,";
+	static const char _valid_chars[] = "0123456789,";
 	uint64_t scale = region->timescale, this_val = 0;
 	struct dm_pool *mem = dms->hist_mem;
 	struct dm_histogram_bin cur;
@@ -740,8 +740,8 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 				  struct dm_histogram **histogram,
 				  struct dm_stats_region *region)
 {
+	static const char _valid_chars[] = "0123456789:";
 	struct dm_histogram *bounds = region->bounds;
-	static const char *_valid_chars = "0123456789:";
 	struct dm_histogram hist = {
 		.nr_bins = region->bounds->nr_bins
 	};
@@ -2000,7 +2000,7 @@ static struct dm_histogram *_alloc_dm_histogram(int nr_bins)
  */
 struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str)
 {
-	static const char *_valid_chars = "0123456789,muns";
+	static const char _valid_chars[] = "0123456789,muns";
 	uint64_t this_val = 0, mult = 1;
 	const char *c, *v, *val_start;
 	struct dm_histogram_bin *cur;



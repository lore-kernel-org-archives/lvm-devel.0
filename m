From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Feb 2016 13:28:25 +0000 (UTC)
Subject: master - libdm: grow with initialized struct content
Message-ID: <20160222132825.CC71961025@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=275c9f7e7789124ba67533522e7b3a347f5a6f8f
Commit:        275c9f7e7789124ba67533522e7b3a347f5a6f8f
Parent:        30a73d1604aeb318709a01f4cc238e2d872be8de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 22 11:14:30 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 22 14:17:32 2016 +0100

libdm: grow with initialized struct content

Coverity noticed struct hist has been copied uninitalized into mempool.
---
 WHATS_NEW_DM        |    1 +
 libdm/libdm-stats.c |   10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dd47c6b..3dbbfae 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.118 -
 =====================================
+  Always initialized hist struct in _stats_parse_histogram().
 
 Version 1.02.117 - 21st February 2016
 =====================================
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 0c1fe7a..d32e4ea 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -740,9 +740,11 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 				  struct dm_histogram **histogram,
 				  struct dm_stats_region *region)
 {
-	struct dm_histogram hist, *bounds = region->bounds;
+	struct dm_histogram *bounds = region->bounds;
 	static const char *_valid_chars = "0123456789:";
-	int nr_bins = region->bounds->nr_bins;
+	struct dm_histogram hist = {
+		.nr_bins = region->bounds->nr_bins
+	};
 	const char *c, *v, *val_start;
 	struct dm_histogram_bin cur;
 	uint64_t sum = 0, this_val;
@@ -754,8 +756,6 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 	if (!dm_pool_begin_object(mem, sizeof(cur)))
 		return_0;
 
-	hist.nr_bins = nr_bins;
-
 	if (!dm_pool_grow_object(mem, &hist, sizeof(hist)))
 		goto_bad;
 
@@ -800,7 +800,7 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 		}
 	} while (*c && (*c != '\n'));
 
-	log_debug("Added region histogram data with %d entries.", nr_bins);
+	log_debug("Added region histogram data with %d entries.", hist.nr_bins);
 
 	*histogram = dm_pool_end_object(mem);
 	(*histogram)->sum = sum;



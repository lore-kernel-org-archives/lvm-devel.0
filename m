From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  7 Sep 2015 18:36:24 +0000 (UTC)
Subject: master - libdm: clean up _build_histogram_arg()
Message-ID: <20150907183624.59544607A0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f990473e46b97e4642744798429c02f7ddc0763
Commit:        5f990473e46b97e4642744798429c02f7ddc0763
Parent:        4bc7a86f3aefbb1b805f94a17891c501b7de40b0
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 7 18:27:22 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 7 19:30:03 2015 +0100

libdm: clean up _build_histogram_arg()

Split up _build_histogram_arg() into separate functions to allocate
and fill the histogram arg string and remove nested local variable
declarations from the parent function.
---
 libdm/libdm-stats.c |   85 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 55 insertions(+), 30 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index d20949a..4e5210d 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -194,8 +194,6 @@ static int _stats_region_present(const struct dm_stats_region *region)
 static void _stats_histograms_destroy(struct dm_pool *mem,
 				      struct dm_stats_region *region)
 {
-	uint64_t n;
-
 	/* Unpopulated handle. */
 	if (!region->counters)
 		return;
@@ -326,11 +324,54 @@ int dm_stats_driver_supports_histogram(void)
 	return _stats_check_precise_timestamps(NULL);
 }
 
+static int _fill_hist_arg(char *hist_arg, size_t hist_len, uint64_t scale,
+			  struct dm_histogram *bounds)
+{
+	int i, l, len = 0, nr_bins;
+	char *arg = hist_arg;
+	uint64_t value;
+
+	nr_bins = bounds->nr_bins;
+
+	for (i = 0; i < nr_bins; i++) {
+		value = bounds->bins[i].upper / scale;
+		if ((l = dm_snprintf(arg, hist_len - len, FMTu64"%s", value,
+				     (i == (nr_bins - 1)) ? "" : ",")) < 0)
+			return_0;
+		len += l;
+		arg += l;
+	}
+	return 1;
+}
+
+static void *_get_hist_arg(struct dm_histogram *bounds, uint64_t scale,
+			   size_t *len)
+{
+	struct dm_histogram_bin *entry, *bins;
+	size_t hist_len = 1; /* terminating '\0' */
+	double value;
+
+	entry = bins = bounds->bins;
+
+	entry += bounds->nr_bins - 1;
+	while(entry >= bins) {
+		value = (double) (entry--)->upper;
+		/* Use lround to avoid size_t -> double cast warning. */
+		hist_len += 1 + (size_t) lround(log10(value / scale));
+		if (entry != bins)
+			hist_len++; /* ',' */
+	}
+
+	*len = hist_len;
+
+	return dm_zalloc(hist_len);
+}
+
 static char *_build_histogram_arg(struct dm_histogram *bounds, int *precise)
 {
 	struct dm_histogram_bin *entry, *bins;
-	size_t hist_len = 1, len = 0;
-	char *hist_arg, *arg = NULL;
+	size_t hist_len;
+	char *hist_arg;
 	uint64_t scale;
 
 	entry = bins = bounds->bins;
@@ -341,53 +382,37 @@ static char *_build_histogram_arg(struct dm_histogram *bounds, int *precise)
 		return NULL;
 	}
 
+	/* Validate entries and set *precise if precision < 1ms. */
 	entry += bounds->nr_bins - 1;
-	while(entry >= bins) {
-		double value;
+	while (entry >= bins) {
 		if (entry != bins) {
 			if (entry->upper < (entry - 1)->upper) {
 				log_error("Histogram boundaries must be in "
 					  "order of increasing magnitude.");
 				return 0;
 			}
-			hist_len++; /* ',' */
 		}
 
 		/*
 		 * Only enable precise_timestamps automatically if any
 		 * value in the histogram bounds uses precision < 1ms.
 		 */
-		if (!*precise && (entry->upper % NSEC_PER_MSEC))
+		if (((entry--)->upper % NSEC_PER_MSEC) && !*precise)
 			*precise = 1;
-
-		value = (double) (entry--)->upper;
-		/* Use lround to avoid size_t -> double cast warning. */
-		hist_len += 1 + (size_t) lround(log10(value));
 	}
 
-	if (!(hist_arg = dm_zalloc(hist_len))) {
+	scale = (*precise) ? 1 : NSEC_PER_MSEC;
+
+	/* Calculate hist_len and allocate a character buffer. */
+	if (!(hist_arg = _get_hist_arg(bounds, scale, &hist_len))) {
 		log_error("Could not allocate memory for histogram argument.");
 		return 0;
 	}
 
-	arg = hist_arg;
-
-	if (*precise)
-		scale = 1;
-	else
-		scale = (*precise) ? 1 : NSEC_PER_MSEC;
+	/* Fill hist_arg with boundary strings. */
+	if (!_fill_hist_arg(hist_arg, hist_len, scale, bounds))
+		goto_bad;
 
-	for (entry = bins; entry < (bins + bounds->nr_bins); entry++) {
-		uint64_t value;
-		ssize_t l = 0;
-		int last = !(entry < (bins + bounds->nr_bins - 1));
-		value = entry->upper / scale;
-		if ((l = dm_snprintf(arg, hist_len - len, FMTu64"%s", value,
-				     (last) ? "" : ",")) < 0)
-			goto_bad;
-		len += (size_t) l;
-		arg += (size_t) l;
-	}
 	return hist_arg;
 
 bad:



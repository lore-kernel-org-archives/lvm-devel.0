From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:08:27 +0000 (UTC)
Subject: master - libdm: allow formatting histogram strings with no whitespace
Message-ID: <20150903210827.7DEF4603F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f09e4f7b10db5051b40fe50b5d6a99a171ce04ca
Commit:        f09e4f7b10db5051b40fe50b5d6a99a171ce04ca
Parent:        0a73a5012aece3d0f7fd03a270cfe5067c1fafc8
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Sep 3 21:48:15 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Sep 3 22:04:10 2015 +0100

libdm: allow formatting histogram strings with no whitespace

Allow dm_histogram_to_string() to format histogram strings with
no whitespace by passing a width value less than zero.
---
 libdm/libdevmapper.h |   10 ++++++++--
 libdm/libdm-stats.c  |   48 ++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 46 insertions(+), 12 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index c81a9e5..098fa85 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2826,8 +2826,8 @@ uint64_t dm_histogram_get_sum(const struct dm_histogram *dmh);
 /*
  * Histogram formatting flags.
  */
-#define DM_HISTOGRAM_VALUES  0x1
-#define DM_HISTOGRAM_SUFFIX  0x2
+#define DM_HISTOGRAM_SUFFIX  0x1
+#define DM_HISTOGRAM_VALUES  0x2
 #define DM_HISTOGRAM_PERCENT 0X4
 #define DM_HISTOGRAM_BOUNDS_LOWER 0x10
 #define DM_HISTOGRAM_BOUNDS_UPPER 0x20
@@ -2840,6 +2840,12 @@ uint64_t dm_histogram_get_sum(const struct dm_histogram *dmh);
  * The bin argument selects the bin to format. If this argument is less
  * than zero all bins will be included in the resulting string.
  *
+ * width specifies a minimum width for the field in characters; if it is
+ * zero the width will be determined automatically based on the options
+ * selected for formatting. A value less than zero disables field width
+ * control: bin boundaries and values will be output with a minimum
+ * amount of whitespace.
+ *
  * flags is a collection of flag arguments that control the string format:
  *
  * DM_HISTOGRAM_VALUES  - Include bin values in the string.
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index d611635..90f2e1d 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2116,7 +2116,7 @@ static int _make_bounds_string(char *buf, size_t size, uint64_t lower,
 {
 	const char *l_suff = NULL;
 	const char *u_suff = NULL;
-	const char *sep = (flags & DM_HISTOGRAM_VALUES) ? ": " : "";
+	const char *sep = "";
 	char bound_buf[32];
 	int bounds = flags & DM_HISTOGRAM_BOUNDS_MASK;
 
@@ -2131,6 +2131,9 @@ static int _make_bounds_string(char *buf, size_t size, uint64_t lower,
 	} else
 		l_suff = u_suff = "";
 
+	if (flags & DM_HISTOGRAM_VALUES)
+		sep = ":";
+
 	if (bounds > DM_HISTOGRAM_BOUNDS_LOWER) {
 		/* Handle infinite uppermost bound. */
 		if (upper == UINT64_MAX) {
@@ -2162,9 +2165,11 @@ out:
 	return 0;
 }
 
+#define BOUND_WIDTH_NOSUFFIX 10 /* 999999999 nsecs */
 #define BOUND_WIDTH 6 /* bounds string up to 9999xs */
 #define COUNT_WIDTH 6 /* count string: up to 9999 */
-#define PERCENT_WIDTH 8 /* percent string : 0.00-100.00% */
+#define PERCENT_WIDTH 6 /* percent string : 0.00-100.00% */
+#define DM_HISTOGRAM_VALUES_MASK 0x06
 
 const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 				   int width, int flags)
@@ -2186,12 +2191,15 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 	} else
 		start = last = bin;
 
-	if (flags & DM_HISTOGRAM_PERCENT)
+	if (width < 0 || !values)
+		width = minwidth = 0; /* no padding */
+	else if (flags & DM_HISTOGRAM_PERCENT)
 		width = minwidth = (width) ? : PERCENT_WIDTH;
 	else if (flags & DM_HISTOGRAM_VALUES)
 		width = minwidth = (width) ? : COUNT_WIDTH;
-	else
-		width = 0; /* bounds only */
+
+	if (values && !width)
+		sep = ":";
 
 	/* Set bounds string to the empty string. */
 	bounds_buf[0] = '\0';
@@ -2200,18 +2208,38 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 
 	for (bin = start; bin <= last; bin++) {
 		if (bounds) {
+			int bounds_width;
+
+			/* Default bounds width depends on time suffixes. */
+			bounds_width = (!(flags & DM_HISTOGRAM_SUFFIX))
+					? BOUND_WIDTH_NOSUFFIX
+					: BOUND_WIDTH ;
+
+			bounds_width = (!width) ? width : bounds_width;
+
 			lower = dm_histogram_get_bin_lower(dmh, bin);
 			upper = dm_histogram_get_bin_upper(dmh, bin);
-			_make_bounds_string(bounds_buf, sizeof(bounds_buf),
-					    lower, upper, flags,
-					    (width) ? BOUND_WIDTH : 0);
-			sep = ", "; /* Comma separates "bounds: value" pairs */
-			width -= (int) (strlen(bounds_buf) - BOUND_WIDTH);
+
+			len = sizeof(bounds_buf);
+			len = _make_bounds_string(bounds_buf, len,
+						  lower, upper, flags,
+						  bounds_width);
+			/*
+			 * Comma separates "bounds: value" pairs unless
+			 * --noheadings is used.
+			 */
+			sep = (width || !values) ? "," : ":";
+
+			/* Adjust width by real bounds length if set. */
+			width -= (width) ? (len - (bounds_width + 1)) : 0;
+
+			/* -ve width indicates specified width was overrun. */
 			width = (width > 0) ? width : 0;
 		}
 
 		if (bin == last)
 			sep = "";
+
 		if (flags & DM_HISTOGRAM_PERCENT) {
 			dm_percent_t pr;
 			float value;



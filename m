From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:29:14 +0000 (UTC)
Subject: master - cleanup: use code in place
Message-ID: <20151109092914.C5CA960300@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=846adadbcc0356e2642ac211de3235f2bfb105a6
Commit:        846adadbcc0356e2642ac211de3235f2bfb105a6
Parent:        22e19cb354d813e4be9a461c16bf27205c86d71e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:33:56 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:52 2015 +0100

cleanup: use code in place

Pass const strings to printf(),
and use  struct names directly instead of creating unused vars on stack.
---
 libdm/libdm-stats.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 505b062..1811e8a 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1228,20 +1228,19 @@ static struct dm_task *_stats_print_region(struct dm_stats *dms,
 				    unsigned num_lines, unsigned clear)
 {
 	/* @stats_print[_clear] <region_id> [<start_line> <num_lines>] */
-	const char *clear_str = "_clear", *lines_fmt = "%u %u";
-	const char *msg_fmt = "@stats_print%s " FMTu64 " %s";
 	const char *err_fmt = "Could not prepare @stats_print %s.";
 	struct dm_task *dmt = NULL;
 	char msg[1024], lines[64];
 
 	if (start_line || num_lines)
 		if (!dm_snprintf(lines, sizeof(lines),
-				 lines_fmt, start_line, num_lines)) {
+				 "%u %u", start_line, num_lines)) {
 			log_error(err_fmt, "row specification");
 			return NULL;
 		}
 
-	if (!dm_snprintf(msg, sizeof(msg), msg_fmt, (clear) ? clear_str : "",
+	if (!dm_snprintf(msg, sizeof(msg), "@stats_print%s " FMTu64 " %s",
+			 (clear) ? "_clear" : "",
 			 region_id, (start_line || num_lines) ? lines : "")) {
 		log_error(err_fmt, "message");
 		return NULL;
@@ -1981,10 +1980,9 @@ dm_percent_t dm_histogram_get_bin_percent(const struct dm_histogram *dmh,
  */
 static struct dm_histogram *_alloc_dm_histogram(int nr_bins)
 {
-	struct dm_histogram *dmh = NULL;
-	struct dm_histogram_bin *cur = NULL;
 	/* Allocate space for dm_histogram + nr_entries. */
-	size_t size = sizeof(*dmh) + (unsigned) nr_bins * sizeof(*cur);
+	size_t size = sizeof(struct dm_histogram) +
+		(unsigned) nr_bins * sizeof(struct dm_histogram_bin);
 	return dm_zalloc(size);
 }
 



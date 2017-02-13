From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 09:14:58 +0000 (UTC)
Subject: master - cleanup: use matching signed number comparation
Message-ID: <20170213091458.115F260576@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3579aafc55bb7fb156f89bba38515846b0c26ee
Commit:        a3579aafc55bb7fb156f89bba38515846b0c26ee
Parent:        7cbee8f31ae64c023b294524008885e3a054e394
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 18:18:54 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 10:06:19 2017 +0100

cleanup: use matching signed number comparation

---
 lib/metadata/metadata.c |    2 +-
 libdm/libdm-report.c    |    2 +-
 libdm/libdm-stats.c     |    6 +++---
 tools/reporter.c        |    2 +-
 tools/toollib.c         |    2 +-
 tools/vgextend.c        |    2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0731108..b11d306 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -6383,7 +6383,7 @@ int vg_strip_outdated_historical_lvs(struct volume_group *vg) {
 		 * Removal time in the future? Not likely,
 		 * but skip this item in any case.
 		*/
-		if ((current_time) < glvl->glv->historical->timestamp_removed)
+		if (current_time < (time_t) glvl->glv->historical->timestamp_removed)
 			continue;
 
 		if ((current_time - glvl->glv->historical->timestamp_removed) > threshold) {
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index f9e261d..7caba98 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4209,7 +4209,7 @@ static void _recalculate_fields(struct dm_report *rh)
 {
 	struct row *row;
 	struct dm_report_field *field;
-	size_t len;
+	int len;
 
 	dm_list_iterate_items(row, &rh->rows) {
 		dm_list_iterate_items(field, &row->fields) {
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index b74a470..587c748 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3294,7 +3294,7 @@ static void _sum_histogram_bins(const struct dm_stats *dms,
 	struct dm_stats_region *region;
 	struct dm_histogram_bin *bins;
 	struct dm_histogram *dmh_cur;
-	uint64_t bin;
+	int bin;
 
 	region = &dms->regions[region_id];
 	dmh_cur = region->counters[area_id].histogram;
@@ -4003,7 +4003,7 @@ merge:
 static void _stats_copy_histogram_bounds(struct dm_histogram *to,
 					 struct dm_histogram *from)
 {
-	uint64_t i;
+	int i;
 
 	to->nr_bins = from->nr_bins;
 
@@ -4019,7 +4019,7 @@ static void _stats_copy_histogram_bounds(struct dm_histogram *to,
 static int _stats_check_histogram_bounds(struct dm_histogram *h1,
 					 struct dm_histogram *h2)
 {
-	uint64_t i;
+	int i;
 
 	if (!h1 || !h2)
 		return 0;
diff --git a/tools/reporter.c b/tools/reporter.c
index e70fa29..00606ed 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -707,7 +707,7 @@ int report_for_selection(struct cmd_context *cmd,
 
 static void _check_pv_list(struct cmd_context *cmd, struct report_args *args, struct single_report_args *single_args)
 {
-	unsigned i;
+	int i;
 	int rescan_done = 0;
 
 	if (!args->argv)
diff --git a/tools/toollib.c b/tools/toollib.c
index 235e535..5f3deb7 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4499,7 +4499,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	int consistent = 0;
 	int must_use_all = (cmd->command->flags & MUST_USE_ALL_ARGS);
 	int found;
-	int i;
+	unsigned i;
 
 	set_pv_notify(cmd);
 
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 344dff0..e16316f 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -49,7 +49,7 @@ static int _vgextend_restoremissing(struct cmd_context *cmd __attribute__((unuse
 	struct vgextend_params *vp = (struct vgextend_params *) handle->custom_handle;
 	struct pvcreate_params *pp = &vp->pp;
 	int fixed = 0;
-	int i;
+	unsigned i;
 
 	if (!archive(vg))
 		return_0;



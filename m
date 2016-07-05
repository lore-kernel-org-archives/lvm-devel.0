From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:27 +0000 (UTC)
Subject: master - libdm: cache dm name in stats handle
Message-ID: <20160705185427.C306360D29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69f808ac8d25e3c7ef39bd2de66fed1efd290bbe
Commit:        69f808ac8d25e3c7ef39bd2de66fed1efd290bbe
Parent:        4a66f02f8876edf6bbbc127d2888a0f50f8be611
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jun 17 12:17:33 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

libdm: cache dm name in stats handle

Cache the device-mapper name of a bound device in the dm_stats
handle.

This will be used by stats groups to report a device name or
user defined alias for groups.
---
 libdm/libdm-stats.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 58f8951..99e4d72 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -81,6 +81,7 @@ struct dm_stats {
 	char *bind_name; /* device-mapper device name */
 	char *bind_uuid; /* device-mapper UUID */
 	char *program_id; /* default program_id for this handle */
+	const char *name; /* cached device_name used for reporting */
 	struct dm_pool *mem; /* memory pool for region and counter tables */
 	struct dm_pool *hist_mem; /* separate pool for histogram tables */
 	uint64_t nr_regions; /* total number of present regions */
@@ -167,6 +168,8 @@ struct dm_stats *dm_stats_create(const char *program_id)
 	dms->bind_name = NULL;
 	dms->bind_uuid = NULL;
 
+	dms->name = NULL;
+
 	/* by default all regions use msec precision */
 	dms->timescale = NSEC_PER_MSEC;
 	dms->precise = 0;
@@ -267,9 +270,12 @@ static void _stats_clear_binding(struct dm_stats *dms)
 		dm_pool_free(dms->mem, dms->bind_name);
 	if (dms->bind_uuid)
 		dm_pool_free(dms->mem, dms->bind_uuid);
+	if (dms->name)
+		dm_free((char *) dms->name);
 
 	dms->bind_name = dms->bind_uuid = NULL;
 	dms->bind_major = dms->bind_minor = -1;
+	dms->name = NULL;
 }
 
 int dm_stats_bind_devno(struct dm_stats *dms, int major, int minor)
@@ -446,6 +452,38 @@ bad:
 }
 
 /*
+ * Cache the dm device_name for the device bound to dms.
+ */
+static int _stats_set_name_cache(struct dm_stats *dms)
+{
+	struct dm_task *dmt;
+
+	if (dms->name)
+		return 1;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
+		return_0;
+
+	if (!_set_stats_device(dms, dmt))
+		goto_bad;
+
+	if (!dm_task_run(dmt))
+		goto_bad;
+
+	if (!(dms->name = dm_strdup(dm_task_get_name(dmt))))
+		goto_bad;
+
+	dm_task_destroy(dmt);
+
+	return 1;
+
+bad:
+	log_error("Could not retrieve device-mapper name for device.");
+	dm_task_destroy(dmt);
+	return 0;
+}
+
+/*
  * Parse a histogram specification returned by the kernel in a
  * @stats_list response.
  */
@@ -714,6 +752,9 @@ int dm_stats_list(struct dm_stats *dms, const char *program_id)
 	if (!program_id)
 		program_id = dms->program_id;
 
+	if (!_stats_set_name_cache(dms))
+		return_0;
+
 	r = dm_snprintf(msg, sizeof(msg), "@stats_list %s", program_id);
 
 	if (r < 0) {
@@ -1347,6 +1388,8 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 	if (all_regions && !dm_stats_list(dms, program_id)) {
 		log_error("Could not parse @stats_list response.");
 		goto bad;
+	} else if (!_stats_set_name_cache(dms)) {
+		goto_bad;
 	}
 
 	/* successful list but no regions registered */
@@ -1391,6 +1434,7 @@ void dm_stats_destroy(struct dm_stats *dms)
 	dm_pool_destroy(dms->mem);
 	dm_pool_destroy(dms->hist_mem);
 	dm_free(dms->program_id);
+	dm_free((char *) dms->name);
 	dm_free(dms);
 }
 



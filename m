From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:25 +0000 (UTC)
Subject: master - libdm: rename dm_stats name, devno and uuid members
Message-ID: <20160705185425.A0B0860D29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a66f02f8876edf6bbbc127d2888a0f50f8be611
Commit:        4a66f02f8876edf6bbbc127d2888a0f50f8be611
Parent:        81fad9e853c45a5c3e56b2bede3a3fc7d7bed30b
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Mar 10 16:51:02 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

libdm: rename dm_stats name, devno and uuid members

The device-mapper name, device numbers and uuid stored in the
dm_stats handle are used only to bind the handle to a specific
device in order to issue ioctls.

Rename them to "bind_*" to reflect this usage in preparation
for caching the device-mapper name of the bound device in the
dm_stats handle.

This will be used to allow optional aliases to be set for
dmstats groups.
---
 libdm/libdm-stats.c |   52 +++++++++++++++++++++++++-------------------------
 1 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 3d53755..58f8951 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -76,10 +76,10 @@ struct dm_stats_region {
 
 struct dm_stats {
 	/* device binding */
-	int major;  /* device major that this dm_stats object is bound to */
-	int minor;  /* device minor that this dm_stats object is bound to */
-	char *name; /* device-mapper device name */
-	char *uuid; /* device-mapper UUID */
+	int bind_major;  /* device major that this dm_stats object is bound to */
+	int bind_minor;  /* device minor that this dm_stats object is bound to */
+	char *bind_name; /* device-mapper device name */
+	char *bind_uuid; /* device-mapper UUID */
 	char *program_id; /* default program_id for this handle */
 	struct dm_pool *mem; /* memory pool for region and counter tables */
 	struct dm_pool *hist_mem; /* separate pool for histogram tables */
@@ -162,10 +162,10 @@ struct dm_stats *dm_stats_create(const char *program_id)
 		goto bad;
 	}
 
-	dms->major = -1;
-	dms->minor = -1;
-	dms->name = NULL;
-	dms->uuid = NULL;
+	dms->bind_major = -1;
+	dms->bind_minor = -1;
+	dms->bind_name = NULL;
+	dms->bind_uuid = NULL;
 
 	/* by default all regions use msec precision */
 	dms->timescale = NSEC_PER_MSEC;
@@ -242,19 +242,19 @@ static void _stats_regions_destroy(struct dm_stats *dms)
 
 static int _set_stats_device(struct dm_stats *dms, struct dm_task *dmt)
 {
-	if (dms->name)
-		return dm_task_set_name(dmt, dms->name);
-	if (dms->uuid)
-		return dm_task_set_uuid(dmt, dms->uuid);
-	if (dms->major > 0)
-		return dm_task_set_major(dmt, dms->major)
-			&& dm_task_set_minor(dmt, dms->minor);
+	if (dms->bind_name)
+		return dm_task_set_name(dmt, dms->bind_name);
+	if (dms->bind_uuid)
+		return dm_task_set_uuid(dmt, dms->bind_uuid);
+	if (dms->bind_major > 0)
+		return dm_task_set_major(dmt, dms->bind_major)
+			&& dm_task_set_minor(dmt, dms->bind_minor);
 	return_0;
 }
 
 static int _stats_bound(struct dm_stats *dms)
 {
-	if (dms->major > 0 || dms->name || dms->uuid)
+	if (dms->bind_major > 0 || dms->bind_name || dms->bind_uuid)
 		return 1;
 	/* %p format specifier expects a void pointer. */
 	log_debug("Stats handle at %p is not bound.", (void *) dms);
@@ -263,13 +263,13 @@ static int _stats_bound(struct dm_stats *dms)
 
 static void _stats_clear_binding(struct dm_stats *dms)
 {
-	if (dms->name)
-		dm_pool_free(dms->mem, dms->name);
-	if (dms->uuid)
-		dm_pool_free(dms->mem, dms->uuid);
+	if (dms->bind_name)
+		dm_pool_free(dms->mem, dms->bind_name);
+	if (dms->bind_uuid)
+		dm_pool_free(dms->mem, dms->bind_uuid);
 
-	dms->name = dms->uuid = NULL;
-	dms->major = dms->minor = -1;
+	dms->bind_name = dms->bind_uuid = NULL;
+	dms->bind_major = dms->bind_minor = -1;
 }
 
 int dm_stats_bind_devno(struct dm_stats *dms, int major, int minor)
@@ -277,8 +277,8 @@ int dm_stats_bind_devno(struct dm_stats *dms, int major, int minor)
 	_stats_clear_binding(dms);
 	_stats_regions_destroy(dms);
 
-	dms->major = major;
-	dms->minor = minor;
+	dms->bind_major = major;
+	dms->bind_minor = minor;
 
 	return 1;
 }
@@ -288,7 +288,7 @@ int dm_stats_bind_name(struct dm_stats *dms, const char *name)
 	_stats_clear_binding(dms);
 	_stats_regions_destroy(dms);
 
-	if (!(dms->name = dm_pool_strdup(dms->mem, name)))
+	if (!(dms->bind_name = dm_pool_strdup(dms->mem, name)))
 		return_0;
 
 	return 1;
@@ -299,7 +299,7 @@ int dm_stats_bind_uuid(struct dm_stats *dms, const char *uuid)
 	_stats_clear_binding(dms);
 	_stats_regions_destroy(dms);
 
-	if (!(dms->uuid = dm_pool_strdup(dms->mem, uuid)))
+	if (!(dms->bind_uuid = dm_pool_strdup(dms->mem, uuid)))
 		return_0;
 
 	return 1;



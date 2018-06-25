From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 25 Jun 2018 09:10:19 -0400
Subject: master - device_mapper: add new _dm_task_create_device_status
Message-ID: <201806251310.w5PDAJPP031478@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4194fc9bbdc9107120ba09c22e56612d854fdd41
Commit:        4194fc9bbdc9107120ba09c22e56612d854fdd41
Parent:        739a213d2ee01cc95861c342fde73e87088de6bb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 23 23:02:24 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 25 15:07:55 2018 +0200

device_mapper: add new _dm_task_create_device_status

Introduce new function _dm_task_create_device_status for grabbing
status of device for better code sharing.
---
 device_mapper/libdm-deptree.c |   32 +++++++++++++++++++++++---------
 1 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 5327b2e..bb552b6 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -1382,20 +1382,14 @@ out:
 	return r;
 }
 
-static int _thin_pool_get_status(struct dm_tree_node *dnode,
-				 struct dm_status_thin_pool *s)
+static struct dm_task *_dm_task_create_device_status(uint32_t major, uint32_t minor)
 {
 	struct dm_task *dmt;
-	int r = 0;
-	uint64_t start, length;
-	char *type = NULL;
-	char *params = NULL;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
-		return_0;
+		return_NULL;
 
-	if (!dm_task_set_major(dmt, dnode->info.major) ||
-	    !dm_task_set_minor(dmt, dnode->info.minor)) {
+	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
 		log_error("Failed to set major minor.");
 		goto out;
 	}
@@ -1406,6 +1400,26 @@ static int _thin_pool_get_status(struct dm_tree_node *dnode,
 	if (!dm_task_run(dmt))
 		goto_out;
 
+	return dmt;
+out:
+	dm_task_destroy(dmt);
+
+	return NULL;
+}
+
+static int _thin_pool_get_status(struct dm_tree_node *dnode,
+				 struct dm_status_thin_pool *s)
+{
+	struct dm_task *dmt;
+	int r = 0;
+	uint64_t start, length;
+	char *type = NULL;
+	char *params = NULL;
+
+	if (!(dmt = _dm_task_create_device_status(dnode->info.major,
+						  dnode->info.minor)))
+		return_0;
+
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
 	if (!type || (strcmp(type, "thin-pool") != 0)) {



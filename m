From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:57:48 -0500
Subject: master - cleanup: mark success at the end
Message-ID: <201712041457.vB4Evmtx007146@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3366787b6349a190063a09b0c37ad5a641fcccf
Commit:        e3366787b6349a190063a09b0c37ad5a641fcccf
Parent:        10f37345ebbd4822083bd9451f59df6074995bb8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 12:49:57 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: mark success at the end

Simplify setting 'success' return value and use common use-pattern
for handling return code.
---
 libdm/libdm-deptree.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d0b4658..ba11388 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -875,7 +875,7 @@ static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
 			const char **name, const char **uuid)
 {
 	struct dm_task *dmt;
-	int r;
+	int r = 0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
 		log_error("_info_by_dev: dm_task creation failed");
@@ -883,32 +883,30 @@ static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
 	}
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
-		log_error("_info_by_dev: Failed to set device number");
-		dm_task_destroy(dmt);
-		return 0;
+		log_error("_info_by_dev: Failed to set device number.");
+		goto out;
 	}
 
 	if (!with_open_count && !dm_task_no_open_count(dmt))
 		log_warn("WARNING: Failed to disable open_count.");
 
-	if (!(r = dm_task_run(dmt)))
+	if (!dm_task_run(dmt))
 		goto_out;
 
-	if (!(r = dm_task_get_info(dmt, info)))
+	if (!dm_task_get_info(dmt, info))
 		goto_out;
 
 	if (name && !(*name = dm_pool_strdup(mem, dm_task_get_name(dmt)))) {
 		log_error("name pool_strdup failed");
-		r = 0;
 		goto out;
 	}
 
 	if (uuid && !(*uuid = dm_pool_strdup(mem, dm_task_get_uuid(dmt)))) {
 		log_error("uuid pool_strdup failed");
-		r = 0;
 		goto out;
 	}
 
+	r = 1;
 out:
 	dm_task_destroy(dmt);
 
@@ -1341,7 +1339,7 @@ static int _suspend_node(const char *name, uint32_t major, uint32_t minor,
 			 int skip_lockfs, int no_flush, struct dm_info *newinfo)
 {
 	struct dm_task *dmt;
-	int r;
+	int r = 0;
 
 	log_verbose("Suspending %s (%" PRIu32 ":%" PRIu32 ")%s%s",
 		    name, major, minor,
@@ -1355,8 +1353,7 @@ static int _suspend_node(const char *name, uint32_t major, uint32_t minor,
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
 		log_error("Failed to set device number for %s suspension.", name);
-		dm_task_destroy(dmt);
-		return 0;
+		goto out;
 	}
 
 	if (!dm_task_no_open_count(dmt))
@@ -1372,7 +1369,7 @@ static int _suspend_node(const char *name, uint32_t major, uint32_t minor,
 		inc_suspended();
 		r = dm_task_get_info(dmt, newinfo);
 	}
-
+out:
 	dm_task_destroy(dmt);
 
 	return r;



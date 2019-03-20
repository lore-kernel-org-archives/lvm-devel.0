From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:39:37 -0400
Subject: master - dev_manager: add dev_manager_remove_dm_major_minor
Message-ID: <201903201339.x2KDdbvf012396@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1eeb2fa3f687e71a541299383fe15bdb9e5a8088
Commit:        1eeb2fa3f687e71a541299383fe15bdb9e5a8088
Parent:        da31541bd8c6945158266f32a31842884e45a09b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 13 12:59:59 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:37:10 2019 +0100

dev_manager: add dev_manager_remove_dm_major_minor

Move DM usage into dev_manager.c source file.
Also convert STATUS to INFO ioctl - as that's enough
to obtain UUID - this also avoid issuing unwanted flush on checked DM
device for being mpath.
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |   20 +-------------------
 lib/activate/dev_manager.c |   17 +++++++++++++++++
 lib/activate/dev_manager.h |    2 ++
 4 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 61d347a..168b267 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Use device INFO instead of STATUS when checking for mpath device uuid.
   Change default io_memory_size from 4 to 8 MiB.
   Add config setting io_memory_size to set bcache size.
   Fix pvscan autoactivation for concurrent pvscans.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ddc175c..38e21be 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -539,25 +539,7 @@ int target_version(const char *target_name, uint32_t *maj,
 
 int lvm_dm_prefix_check(int major, int minor, const char *prefix)
 {
-	struct dm_task *dmt;
-	const char *uuid;
-	int r;
-
-	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
-		return_0;
-
-	if (!dm_task_set_minor(dmt, minor) ||
-	    !dm_task_set_major(dmt, major) ||
-	    !dm_task_run(dmt) ||
-	    !(uuid = dm_task_get_uuid(dmt))) {
-		dm_task_destroy(dmt);
-		return 0;
-	}
-
-	r = strncasecmp(uuid, prefix, strlen(prefix));
-	dm_task_destroy(dmt);
-
-	return r ? 0 : 1;
+	return dev_manager_check_prefix_dm_major_minor(major, minor, prefix);
 }
 
 int module_present(struct cmd_context *cmd, const char *target_name)
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 37ce2bf..09fca63 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -943,6 +943,23 @@ static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
 	return _info_run(NULL, info, NULL, 0, 0, 0, major, minor);
 }
 
+int dev_manager_check_prefix_dm_major_minor(uint32_t major, uint32_t minor, const char *prefix)
+{
+	struct dm_task *dmt;
+	const char *uuid;
+	int r = 1;
+
+	if (!(dmt = _setup_task_run(DM_DEVICE_INFO, NULL, NULL, NULL, 0, major, minor, 0, 0, 0)))
+		return_0;
+
+	if (!(uuid = dm_task_get_uuid(dmt)) || strncasecmp(uuid, prefix, strlen(prefix)))
+		r = 0;
+
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 int dev_manager_info(struct cmd_context *cmd,
 		     const struct logical_volume *lv, const char *layer,
 		     int with_open_count, int with_read_ahead,
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index e8e8ae3..d159364 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -107,6 +107,8 @@ int dev_manager_device_uses_vg(struct device *dev,
 
 int dev_manager_remove_dm_major_minor(uint32_t major, uint32_t minor);
 
+int dev_manager_check_prefix_dm_major_minor(uint32_t major, uint32_t minor, const char *prefix);
+
 int get_cache_vol_meta_data(struct cmd_context *cmd,
                                     struct logical_volume *lv,
                                     struct logical_volume *pool_lv,



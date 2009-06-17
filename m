From: Milan Broz <mbroz@redhat.com>
Date: Wed, 17 Jun 2009 19:33:52 +0200
Subject: [PATCH] Fix backward compatibility for major:minor query
Message-ID: <4A392900.2030600@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix backward compatibility for major:minor query.

Is an application uses query and set major:minor
to device, it should not fallback to default major by default.

Add new function whoich allows that (and use it in lvm2).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 WHATS_NEW                   |    1 +
 WHATS_NEW_DM                |    1 +
 lib/activate/dev_manager.c  |    8 +++-----
 libdm/.exported_symbols     |    1 +
 libdm/ioctl/libdm-iface.c   |    3 ++-
 libdm/ioctl/libdm-targets.h |    1 +
 libdm/libdevmapper.h        |    1 +
 libdm/libdm-common.c        |   12 ++++++++++++
 8 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1ae02d9..69f8fc0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Explicitly request fallback to default major number in device mapper.
   Ignore suspended devices during repair.
   Call vgreduce --removemissing automatically to clean up bad PVs in dmeventd.
   Suggest use lvchange --resync when up converting not yet synced mirror.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6ad04cf..e1882c0 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.33 -
 ===============================
+  Do not fallback to default major number, provide new function instead (1.02.31)
   Do not fork daemon when dmeventd cannot be found.
   Add crypt target handling to libdevmapper node.
   Add splitname command to dmsetup.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index ab61817..87a5c69 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -111,10 +111,8 @@ static struct dm_task *_setup_task(const char *name, const char *uuid,
 	if (event_nr)
 		dm_task_set_event_nr(dmt, *event_nr);
 
-	if (major) {
-		dm_task_set_major(dmt, major);
-		dm_task_set_minor(dmt, minor);
-	}
+	if (major)
+		dm_task_set_major_minor(dmt, major, minor, 1);
 
 	return dmt;
 }
@@ -171,7 +169,7 @@ int device_is_usable(dev_t dev)
 		return 0;
 	}
 
-	if (!dm_task_set_major(dmt, MAJOR(dev)) || !dm_task_set_minor(dmt, MINOR(dev)))
+	if (!dm_task_set_major_minor(dmt, MAJOR(dev), MINOR(dev), 1))
 		goto_out;
 
 	if (!dm_task_run(dmt)) {
diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index 82a7c9e..f5d3852 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -24,6 +24,7 @@ dm_task_set_newname
 dm_task_set_event_nr
 dm_task_set_major
 dm_task_set_minor
+dm_task_set_major_minor
 dm_task_set_sector
 dm_task_set_message
 dm_task_set_uid
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 3698eda..2f8a930 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1335,7 +1335,8 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 			goto bad;
 		}
 
-		if (!_dm_multiple_major_support && dmt->major != _dm_device_major) {
+		if (!_dm_multiple_major_support && dmt->allow_default_major_fallback &&
+		    dmt->major != _dm_device_major) {
 			log_verbose("Overriding major number of %" PRIu32 
 				    " with %" PRIu32 " for persistent device.",
 				    dmt->major, _dm_device_major);
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index 1bb9ce1..267bb8d 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -41,6 +41,7 @@ struct dm_task {
 	uint32_t event_nr;
 	int major;
 	int minor;
+	int allow_default_major_fallback;
 	uid_t uid;
 	gid_t gid;
 	mode_t mode;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 4d03a21..3cecf4c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -145,6 +145,7 @@ int dm_task_set_ro(struct dm_task *dmt);
 int dm_task_set_newname(struct dm_task *dmt, const char *newname);
 int dm_task_set_minor(struct dm_task *dmt, int minor);
 int dm_task_set_major(struct dm_task *dmt, int major);
+int dm_task_set_major_minor(struct dm_task *dmt, int major, int minor, int allow_default_major_fallback);
 int dm_task_set_uid(struct dm_task *dmt, uid_t uid);
 int dm_task_set_gid(struct dm_task *dmt, gid_t gid);
 int dm_task_set_mode(struct dm_task *dmt, mode_t mode);
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index bbb46f5..9246923 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -118,6 +118,7 @@ struct dm_task *dm_task_create(int type)
 	dmt->type = type;
 	dmt->minor = -1;
 	dmt->major = -1;
+	dmt->allow_default_major_fallback = 1;
 	dmt->uid = DM_DEVICE_UID;
 	dmt->gid = DM_DEVICE_GID;
 	dmt->mode = DM_DEVICE_MODE;
@@ -190,6 +191,7 @@ int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
 int dm_task_set_major(struct dm_task *dmt, int major)
 {
 	dmt->major = major;
+	dmt->allow_default_major_fallback = 0;
 
 	return 1;
 }
@@ -201,6 +203,16 @@ int dm_task_set_minor(struct dm_task *dmt, int minor)
 	return 1;
 }
 
+int dm_task_set_major_minor(struct dm_task *dmt, int major, int minor,
+			    int allow_default_major_fallback)
+{
+	dmt->major = major;
+	dmt->minor = minor;
+	dmt->allow_default_major_fallback = allow_default_major_fallback;
+
+	return 1;
+}
+
 int dm_task_set_uid(struct dm_task *dmt, uid_t uid)
 {
 	dmt->uid = uid;




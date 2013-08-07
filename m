From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  7 Aug 2013 22:50:38 +0000 (UTC)
Subject: master - Mirror: Fix issue preventing PV creation on mirror LVs
Message-ID: <20130807225038.5CBE5617CF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c95f17ea64e3faee3d36be95544c907b5e89c073
Commit:        c95f17ea64e3faee3d36be95544c907b5e89c073
Parent:        b15278c3dca14d7ee09a2ebcca4b91cbdf8428af
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Aug 7 17:42:26 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Aug 7 17:42:26 2013 -0500

Mirror: Fix issue preventing PV creation on mirror LVs

Commit b248ba0a396d7fc9a459eea02cfdc70b33ce3441 attempted to
prevent mirror devices which had a failed device in their
mirrored log from being usable/readable by LVM.  This was to
protect against circular dependancies where one LVM command
could be blocked trying to read one of these affected mirrors
while the LVM command to fix/unblock that mirror was stuck
behind the currently running command.

The above commit went wrong when it used 'device_is_usable()' to
recurse on the mirrored log device to check if it was suspended
or blocked.  The 'device_is_usable' function also contains a check
for reserved names - like *_mlog, etc.  This last check always
triggered when checking a mirror's log simply because of the name,
not because it was suspended or blocked - a false positive.

The solution is to create a new function like 'device_is_usable',
but without the check for reserved names.  Using this new function
(device_is_suspended_or_blocked), we can check the status of a
mirror's log device properly.
---
 lib/activate/activate.h    |   10 +++++++++-
 lib/activate/dev_manager.c |   34 +++++++++++++++++++++++++++++++---
 2 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 80733fe..f34d376 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -167,11 +167,19 @@ int pv_uses_vg(struct physical_volume *pv,
 	       struct volume_group *vg);
 
 /*
- * Returns 1 if mapped device is not suspended.
+ * Returns 1 if mapped device is not suspended, blocked or
+ * is using a reserved name.
  */
 int device_is_usable(struct device *dev);
 
 /*
+ * Returns 1 if the device is suspended or blocking.
+ * (Does not perform check on the LV name of the device.)
+ * N.B.  This is !device_is_usable() without the name check.
+ */
+int device_is_suspended_or_blocking(struct device *dev);
+
+/*
  * Declaration moved here from fs.h to keep header fs.h hidden
  */
 void fs_unlock(void);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6a68653..294606c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -275,7 +275,7 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 				goto_out;
 
 			tmp_dev->dev = log_dev;
-			if (!device_is_usable(tmp_dev))
+			if (device_is_suspended_or_blocking(tmp_dev))
 				goto_out;
 		}
 	}
@@ -329,7 +329,24 @@ out:
 	return r;
 }
 
-int device_is_usable(struct device *dev)
+/*
+ * _device_is_usable
+ * @dev
+ * @check_lv_names
+ *
+ * A device is considered not usable if it is:
+ *     1) An empty device (no targets)
+ *     2) A blocked mirror (i.e. a mirror with a failure and block_on_error set)
+ *     3) ignore_suspended_devices is set and
+ *        a) the device is suspended
+ *        b) it is a snapshot origin
+ *     4) an error target
+ * And optionally, if 'check_lv_names' is set
+ *     5) the LV name is a reserved name.
+ *
+ * Returns: 1 if usable, 0 otherwise
+ */
+static int _device_is_usable(struct device *dev, int check_lv_names)
 {
 	struct dm_task *dmt;
 	struct dm_info info;
@@ -416,7 +433,8 @@ int device_is_usable(struct device *dev)
 	/* FIXME Also check dependencies? */
 
 	/* Check internal lvm devices */
-	if (uuid && !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
+	if (check_lv_names &&
+	    uuid && !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
 		if (!(vgname = dm_strdup(name)) ||
 		    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
 			goto_out;
@@ -436,6 +454,16 @@ int device_is_usable(struct device *dev)
 	return r;
 }
 
+int device_is_usable(struct device *dev)
+{
+	return _device_is_usable(dev, 1);
+}
+
+int device_is_suspended_or_blocking(struct device *dev)
+{
+	return !_device_is_usable(dev, 0);
+}
+
 static int _info(const char *dlid, int with_open_count, int with_read_ahead,
 		 struct dm_info *info, uint32_t *read_ahead)
 {



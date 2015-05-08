From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:44 +0000 (UTC)
Subject: master - cleanup: cast minor to dev_t
Message-ID: <20150508131644.9A4F360759@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5232fd13f362334286ca2076db99a0063919341c
Commit:        5232fd13f362334286ca2076db99a0063919341c
Parent:        b8dfd7a53d6ef203ca6204d00f7c26c0baea99f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 11:03:48 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 15:15:10 2015 +0200

cleanup: cast minor to dev_t

Let the arithmetic run with a single dev_t type (Coverity).
---
 lib/device/dev-type.c     |    4 ++--
 libdm/ioctl/libdm-iface.c |    6 +++---
 libdm/libdm-common.c      |    2 +-
 libdm/libdm-deptree.c     |    4 ++--
 tools/pvscan.c            |    4 ++--
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 5a4c658..82e37e0 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -433,7 +433,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	 */
 	if ((parts = dt->dev_type_array[major].max_partitions) > 1) {
 		if ((residue = minor % parts)) {
-			*result = MKDEV((dev_t)major, (minor - residue));
+			*result = MKDEV((dev_t)major, (dev_t)(minor - residue));
 			ret = 2;
 		} else {
 			*result = dev->dev;
@@ -510,7 +510,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 			  path, buffer);
 		goto out;
 	}
-	*result = MKDEV((dev_t)major, minor);
+	*result = MKDEV((dev_t)major, (dev_t)minor);
 	ret = 2;
 out:
 	if (fp && fclose(fp))
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 1f301f9..298723e 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -245,7 +245,7 @@ static int _control_exists(const char *control, uint32_t major, uint32_t minor)
 		return -1;
 	}
 
-	if (major && buf.st_rdev != MKDEV((dev_t)major, minor)) {
+	if (major && buf.st_rdev != MKDEV((dev_t)major, (dev_t)minor)) {
 		log_verbose("%s: Wrong device number: (%u, %u) instead of "
 			    "(%u, %u)", control,
 			    MAJOR(buf.st_mode), MINOR(buf.st_mode),
@@ -288,7 +288,7 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 	(void) dm_prepare_selinux_context(control, S_IFCHR);
 	old_umask = umask(DM_CONTROL_NODE_UMASK);
 	if (mknod(control, S_IFCHR | S_IRUSR | S_IWUSR,
-		  MKDEV((dev_t)major, minor)) < 0)  {
+		  MKDEV((dev_t)major, (dev_t)minor)) < 0)  {
 		log_sys_error("mknod", control);
 		(void) dm_prepare_selinux_context(NULL, 0);
 		return 0;
@@ -1142,7 +1142,7 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 		}
 
 		dmi->flags |= DM_PERSISTENT_DEV_FLAG;
-		dmi->dev = MKDEV((dev_t)dmt->major, dmt->minor);
+		dmi->dev = MKDEV((dev_t)dmt->major, (dev_t)dmt->minor);
 	}
 
 	/* Does driver support device number referencing? */
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index bd51645..fa533f8 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -959,7 +959,7 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 {
 	char path[PATH_MAX];
 	struct stat info;
-	dev_t dev = MKDEV((dev_t)major, minor);
+	dev_t dev = MKDEV((dev_t)major, (dev_t)minor);
 	mode_t old_mask;
 
 	if (!_build_dev_path(path, sizeof(path), dev_name))
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index cd63061..578f645 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -511,7 +511,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 	dm_list_init(&node->activated);
 	dm_list_init(&node->props.segs);
 
-	dev = MKDEV((dev_t)info->major, info->minor);
+	dev = MKDEV((dev_t)info->major, (dev_t)info->minor);
 
 	if (!dm_hash_insert_binary(dtree->devs, (const char *) &dev,
 				sizeof(dev), node)) {
@@ -535,7 +535,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 static struct dm_tree_node *_find_dm_tree_node(struct dm_tree *dtree,
 					       uint32_t major, uint32_t minor)
 {
-	dev_t dev = MKDEV((dev_t)major, minor);
+	dev_t dev = MKDEV((dev_t)major, (dev_t)minor);
 
 	return dm_hash_lookup_binary(dtree->devs, (const char *) &dev,
 				     sizeof(dev));
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 307187d..2c997b7 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -262,7 +262,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 				ret = ECMD_FAILED;
 				continue;
 			}
-			devno = MKDEV((dev_t)major, minor);
+			devno = MKDEV((dev_t)major, (dev_t)minor);
 			if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
 				if (!(_clear_dev_from_lvmetad_cache(devno, major, minor, handler))) {
 					stack;
@@ -295,7 +295,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 		if (major < 0 || minor < 0)
 			continue;
 
-		devno = MKDEV((dev_t)major, minor);
+		devno = MKDEV((dev_t)major, (dev_t)minor);
 
 		if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
 			if (!(_clear_dev_from_lvmetad_cache(devno, major, minor, handler))) {



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:32 +0000 (UTC)
Subject: master - cleanup: keep MKNOD type cast clean
Message-ID: <20120823124232.1D507A33BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff86c6ed00859a93b984ffd5944c6ba3e450c747
Commit:        ff86c6ed00859a93b984ffd5944c6ba3e450c747
Parent:        ba309e0da5bd22f844dbfc284c1606ca413f79f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 16 20:06:07 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:21 2012 +0200

cleanup: keep MKNOD type cast clean

Setup major already a dev_t type before it gets shifted.
---
 lib/device/device.c       |    2 +-
 libdm/ioctl/libdm-iface.c |    6 +++---
 libdm/libdm-common.c      |    2 +-
 libdm/libdm-deptree.c     |    4 ++--
 tools/pvscan.c            |    2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/device/device.c b/lib/device/device.c
index 37bed63..3e5e2a4 100644
--- a/lib/device/device.c
+++ b/lib/device/device.c
@@ -347,7 +347,7 @@ int get_primary_dev(const char *sysfs_dir,
 			  path, buffer);
 		goto out;
 	}
-	*result = MKDEV(pri_maj, pri_min);
+	*result = MKDEV((dev_t)pri_maj, pri_min);
 	ret = 1;
 
 out:
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 5276c11..9932aa9 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -239,7 +239,7 @@ static int _control_exists(const char *control, uint32_t major, uint32_t minor)
 		return -1;
 	}
 
-	if (major && buf.st_rdev != MKDEV(major, minor)) {
+	if (major && buf.st_rdev != MKDEV((dev_t)major, minor)) {
 		log_verbose("%s: Wrong device number: (%u, %u) instead of "
 			    "(%u, %u)", control,
 			    MAJOR(buf.st_mode), MINOR(buf.st_mode),
@@ -282,7 +282,7 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 	(void) dm_prepare_selinux_context(control, S_IFCHR);
 	old_umask = umask(DM_CONTROL_NODE_UMASK);
 	if (mknod(control, S_IFCHR | S_IRUSR | S_IWUSR,
-		  MKDEV(major, minor)) < 0)  {
+		  MKDEV((dev_t)major, minor)) < 0)  {
 		log_sys_error("mknod", control);
 		(void) dm_prepare_selinux_context(NULL, 0);
 		return 0;
@@ -1062,7 +1062,7 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 		}
 
 		dmi->flags |= DM_PERSISTENT_DEV_FLAG;
-		dmi->dev = MKDEV(dmt->major, dmt->minor);
+		dmi->dev = MKDEV((dev_t)dmt->major, dmt->minor);
 	}
 
 	/* Does driver support device number referencing? */
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index fd775ca..7929889 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -841,7 +841,7 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 {
 	char path[PATH_MAX];
 	struct stat info;
-	dev_t dev = MKDEV(major, minor);
+	dev_t dev = MKDEV((dev_t)major, minor);
 	mode_t old_mask;
 
 	_build_dev_path(path, sizeof(path), dev_name);
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 503b240..28d1153 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -484,7 +484,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 	dm_list_init(&node->used_by);
 	dm_list_init(&node->props.segs);
 
-	dev = MKDEV(info->major, info->minor);
+	dev = MKDEV((dev_t)info->major, info->minor);
 
 	if (!dm_hash_insert_binary(dtree->devs, (const char *) &dev,
 				sizeof(dev), node)) {
@@ -508,7 +508,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 static struct dm_tree_node *_find_dm_tree_node(struct dm_tree *dtree,
 					       uint32_t major, uint32_t minor)
 {
-	dev_t dev = MKDEV(major, minor);
+	dev_t dev = MKDEV((dev_t)major, minor);
 
 	return dm_hash_lookup_binary(dtree->devs, (const char *) &dev,
 				  sizeof(dev));
diff --git a/tools/pvscan.c b/tools/pvscan.c
index a040899..a846322 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -209,7 +209,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 		if (major < 0 || minor < 0)
 			continue;
 
-		devno = MKDEV(major, minor);
+		devno = MKDEV((dev_t)major, minor);
 
 		if (!(dev = dev_cache_get_by_devt(devno, NULL))) {
 			if (!dm_asprintf(&buf, "%" PRIi32 ":%" PRIi32, major, minor))



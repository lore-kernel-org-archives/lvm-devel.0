From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:18:59 +0000 (UTC)
Subject: master - cleanup: use just PATH_MAX size
Message-ID: <20140819141859.D911C6030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94786a3bbf0b68883a2618c9bc25fc88e367f9f8
Commit:        94786a3bbf0b68883a2618c9bc25fc88e367f9f8
Parent:        5cd3b5c0cf562edc3ec2d860b4d51313525e4130
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 19 11:35:18 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 19 14:33:06 2014 +0200

cleanup: use just PATH_MAX size

Avoid playing with +1.

PATH_MAX code needs probably more thinking anyway, since
there is no MAX path in Linux - user may easily create path
with 64kB chars - so 4kB buffer is surelly not enough for
such dirs.

Note:
http://insanecoding.blogspot.cz/2007/11/pathmax-simply-isnt.html
---
 lib/device/dev-type.c      |   10 +++++-----
 lib/filters/filter-mpath.c |    5 ++---
 libdm/libdm-common.c       |    4 ++--
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 902b7d1..ecceb2d 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -348,8 +348,8 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	const char *sysfs_dir = dm_sysfs_dir();
 	int major = (int) MAJOR(dev->dev);
 	int minor = (int) MINOR(dev->dev);
-	char path[PATH_MAX+1];
-	char temp_path[PATH_MAX+1];
+	char path[PATH_MAX];
+	char temp_path[PATH_MAX];
 	char buffer[64];
 	struct stat info;
 	FILE *fp = NULL;
@@ -378,7 +378,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	 */
 
 	/* check if dev is a partition */
-	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/partition",
+	if (dm_snprintf(path, sizeof(path), "%s/dev/block/%d:%d/partition",
 			sysfs_dir, major, minor) < 0) {
 		log_error("dm_snprintf partition failed");
 		goto out;
@@ -400,14 +400,14 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	 * - basename ../../block/md0/md0  = md0
 	 * Parent's 'dev' sysfs attribute  = /sys/block/md0/dev
 	 */
-	if ((size = readlink(dirname(path), temp_path, PATH_MAX)) < 0) {
+	if ((size = readlink(dirname(path), temp_path, sizeof(temp_path) - 1)) < 0) {
 		log_sys_error("readlink", path);
 		goto out;
 	}
 
 	temp_path[size] = '\0';
 
-	if (dm_snprintf(path, PATH_MAX, "%s/block/%s/dev",
+	if (dm_snprintf(path, sizeof(path), "%s/block/%s/dev",
 			sysfs_dir, basename(dirname(temp_path))) < 0) {
 		log_error("dm_snprintf dev failed");
 		goto out;
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 468dc6c..0f12c73 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -145,9 +145,8 @@ static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
 	const char *part_name, *name;
-	char path[PATH_MAX+1];
-	char parent_name[PATH_MAX+1];
 	struct stat info;
+	char path[PATH_MAX], parent_name[PATH_MAX];
 	const char *sysfs_dir = dm_sysfs_dir();
 	int major = MAJOR(dev->dev);
 	int minor = MINOR(dev->dev);
@@ -175,7 +174,7 @@ static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
 		return 0;
 	}
 
-	if (dm_snprintf(path, PATH_MAX, "%s/block/%s/holders", sysfs_dir, name) < 0) {
+	if (dm_snprintf(path, sizeof(path), "%s/block/%s/holders", sysfs_dir, name) < 0) {
 		log_error("Sysfs path to check mpath is too long.");
 		return 0;
 	}
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index ea5b97e..bfa60a2 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1649,8 +1649,8 @@ static void _unmangle_mountinfo_string(const char *src, char *buf)
 /* Parse one line of mountinfo and unmangled target line */
 static int _mountinfo_parse_line(const char *line, unsigned *maj, unsigned *min, char *buf)
 {
-	char root[PATH_MAX + 1];
-	char target[PATH_MAX + 1];
+	char root[PATH_MAX];
+	char target[PATH_MAX];
 
 	/* TODO: maybe detect availability of  %ms  glib support ? */
 	if (sscanf(line, "%*u %*u %u:%u %" DM_TO_STRING(PATH_MAX)



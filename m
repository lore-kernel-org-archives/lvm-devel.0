From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:05 +0000 (UTC)
Subject: master - dev-type: use text format as direct arg for printf
Message-ID: <20131122200905.1EF1F61133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d079c81ab49648fc5506490e34e16244c20fa45f
Commit:        d079c81ab49648fc5506490e34e16244c20fa45f
Parent:        6fa95d17ee85ffd77d4dc90b23cdd024f65c279c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 12:57:35 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:54 2013 +0100

dev-type: use text format as direct arg for printf

Put common printf() case into a function and use
the string with text format as direct arg to make
the compile time validation of args easier and
code shorter.

Switch log_error() to log_warn(), since 'return 0'
doesn't cause any failure here.
---
 lib/device/dev-type.c |   33 +++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index a98cf45..f3f29b2 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -445,13 +445,25 @@ out:
 
 #ifdef __linux__
 
+static int _snprintf_attr(char *buf, size_t buf_size, const char *sysfs_dir,
+			 const char *attribute, dev_t dev)
+{
+	if (dm_snprintf(buf, buf_size, "%s/dev/block/%d:%d/%s", sysfs_dir,
+			(int)MAJOR(dev), (int)MINOR(dev),
+			attribute) < 0) {
+		log_warn("dm_snprintf %s failed.", attribute);
+		return 0;
+	}
+
+	return 1;
+}
+
 static unsigned long _dev_topology_attribute(struct dev_types *dt,
 					     const char *attribute,
 					     struct device *dev)
 {
 	const char *sysfs_dir = dm_sysfs_dir();
-	static const char sysfs_fmt_str[] = "%s/dev/block/%d:%d/%s";
-	char path[PATH_MAX+1], buffer[64];
+	char path[PATH_MAX], buffer[64];
 	FILE *fp;
 	struct stat info;
 	dev_t uninitialized_var(primary);
@@ -463,12 +475,8 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 	if (!sysfs_dir || !*sysfs_dir)
 		return_0;
 
-	if (dm_snprintf(path, PATH_MAX, sysfs_fmt_str, sysfs_dir,
-			(int)MAJOR(dev->dev), (int)MINOR(dev->dev),
-			attribute) < 0) {
-		log_error("dm_snprintf %s failed", attribute);
-		return 0;
-	}
+	if (!_snprintf_attr(path, sizeof(path), sysfs_dir, attribute, dev->dev))
+                return_0;
 
 	/*
 	 * check if the desired sysfs attribute exists
@@ -484,12 +492,9 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 			return 0;
 
 		/* get attribute from partition's primary device */
-		if (dm_snprintf(path, PATH_MAX, sysfs_fmt_str, sysfs_dir,
-				(int)MAJOR(primary), (int)MINOR(primary),
-				attribute) < 0) {
-			log_error("primary dm_snprintf %s failed", attribute);
-			return 0;
-		}
+		if (!_snprintf_attr(path, sizeof(path), sysfs_dir, attribute, primary))
+			return_0;
+
 		if (stat(path, &info) == -1) {
 			if (errno != ENOENT)
 				log_sys_error("stat", path);



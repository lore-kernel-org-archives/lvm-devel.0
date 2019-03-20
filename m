From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:39:39 -0400
Subject: master - filter: enhance mpath detection
Message-ID: <201903201339.x2KDddcC012410@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dc6dea40331687b8740cc48833f4c7c42a2db1a1
Commit:        dc6dea40331687b8740cc48833f4c7c42a2db1a1
Parent:        1eeb2fa3f687e71a541299383fe15bdb9e5a8088
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 13 13:02:09 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:37:42 2019 +0100

filter: enhance mpath detection

Internal detection of SCSI device being in-use by DM mpath has been
performed several times for each component device - this could be
eventually racy - so instead when we do remember  1st. checked result
for device being mpath and use it consistenly over the filter runtime.
---
 WHATS_NEW                  |    1 +
 lib/filters/filter-mpath.c |   78 +++++++++++++++++++++++++++++++++++++-------
 2 files changed, 67 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 168b267..ad92827 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Query mpath device only once per command for its state.
   Use device INFO instead of STATUS when checking for mpath device uuid.
   Change default io_memory_size from 4 to 8 MiB.
   Add config setting io_memory_size to set bcache size.
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index f0374b4..25a507c 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -27,6 +27,14 @@
 
 #define MPATH_PREFIX "mpath-"
 
+
+struct mpath_priv {
+	struct dm_pool *mem;
+	struct dev_filter f;
+	struct dev_types *dt;
+	struct dm_hash_table *hash;
+};
+
 static const char *_get_sysfs_name(struct device *dev)
 {
 	const char *name;
@@ -174,7 +182,8 @@ static int _udev_dev_is_mpath(struct device *dev)
 
 static int _native_dev_is_mpath(struct dev_filter *f, struct device *dev)
 {
-	struct dev_types *dt = (struct dev_types *) f->private;
+	struct mpath_priv *mp = (struct mpath_priv *) f->private;
+	struct dev_types *dt = mp->dt;
 	const char *part_name, *name;
 	struct stat info;
 	char path[PATH_MAX], parent_name[PATH_MAX];
@@ -182,6 +191,7 @@ static int _native_dev_is_mpath(struct dev_filter *f, struct device *dev)
 	int major = MAJOR(dev->dev);
 	int minor = MINOR(dev->dev);
 	dev_t primary_dev;
+	long look;
 
 	/* Limit this filter only to SCSI devices */
 	if (!major_is_scsi_device(dt, MAJOR(dev->dev)))
@@ -228,7 +238,22 @@ static int _native_dev_is_mpath(struct dev_filter *f, struct device *dev)
 	if (major != dt->device_mapper_major)
 		return 0;
 
-	return lvm_dm_prefix_check(major, minor, MPATH_PREFIX);
+	/* Avoid repeated detection of multipath device and use first checked result */
+	look = (long) dm_hash_lookup_binary(mp->hash, &minor, sizeof(minor));
+	if (look > 0) {
+		log_debug_devs("%s(%u:%u): already checked as %sbeing mpath.",
+			       parent_name, major, minor, (look > 1) ? "" : "not ");
+		return (look > 1) ? 0 : 1;
+	}
+
+	if (lvm_dm_prefix_check(major, minor, MPATH_PREFIX)) {
+		(void) dm_hash_insert_binary(mp->hash, &minor, sizeof(minor), (void*)2);
+		return 1;
+	}
+
+	(void) dm_hash_insert_binary(mp->hash, &minor, sizeof(minor), (void*)1);
+
+	return 0;
 }
 
 static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
@@ -263,36 +288,65 @@ static int _ignore_mpath(struct cmd_context *cmd, struct dev_filter *f, struct d
 
 static void _destroy(struct dev_filter *f)
 {
+	struct mpath_priv *mp = (struct mpath_priv*) f->private;
+
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying mpath filter while in use %u times.", f->use_count);
 
-	free(f);
+	dm_hash_destroy(mp->hash);
+	dm_pool_destroy(mp->mem);
 }
 
 struct dev_filter *mpath_filter_create(struct dev_types *dt)
 {
 	const char *sysfs_dir = dm_sysfs_dir();
-	struct dev_filter *f;
+	struct dm_pool *mem;
+	struct mpath_priv *mp;
+	struct dm_hash_table *hash;
 
 	if (!*sysfs_dir) {
 		log_verbose("No proc filesystem found: skipping multipath filter");
 		return NULL;
 	}
 
-	if (!(f = zalloc(sizeof(*f)))) {
-		log_error("mpath filter allocation failed");
+	if (!(hash = dm_hash_create(128))) {
+		log_error("mpath hash table creation failed.");
 		return NULL;
 	}
 
-	f->passes_filter = _ignore_mpath;
-	f->destroy = _destroy;
-	f->use_count = 0;
-	f->private = dt;
-	f->name = "mpath";
+	if (!(mem = dm_pool_create("mpath", 256))) {
+		log_error("mpath pool creation failed.");
+		dm_hash_destroy(hash);
+		return NULL;
+	}
+
+	if (!(mp = dm_pool_zalloc(mem, sizeof(*mp)))) {
+		log_error("mpath filter allocation failed.");
+		goto bad;
+	}
+
+	if (!(mp = dm_pool_zalloc(mem, sizeof(*mp)))) {
+		log_error("mpath filter allocation failed.");
+		goto bad;
+	}
+
+	mp->f.passes_filter = _ignore_mpath;
+	mp->f.destroy = _destroy;
+	mp->f.use_count = 0;
+	mp->f.private = mp;
+	mp->f.name = "mpath";
+
+	mp->mem = mem;
+	mp->dt = dt;
+	mp->hash = hash;
 
 	log_debug_devs("mpath filter initialised.");
 
-	return f;
+	return &mp->f;
+bad:
+	dm_pool_destroy(mem);
+	dm_hash_destroy(hash);
+	return NULL;
 }
 
 #else



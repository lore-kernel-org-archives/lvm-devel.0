From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Jun 2013 13:06:03 +0000 (UTC)
Subject: master - dev-type: refine dev_get_primary_dev return codes and add more comments
Message-ID: <20130612130603.BCA2160E16@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ebf0898d69f53664fa5c1f88207aa8bc970b84fc
Commit:        ebf0898d69f53664fa5c1f88207aa8bc970b84fc
Parent:        56ee1de7e4509aff264d2c682e7690101248b73d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 12 14:33:28 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 12 14:33:28 2013 +0200

dev-type: refine dev_get_primary_dev return codes and add more comments

---
 lib/device/dev-md.c        |    2 +-
 lib/device/dev-type.c      |   30 ++++++++++++++++++++++--------
 lib/filters/filter-mpath.c |    6 +++---
 3 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 84d9ce3..a8bbe81 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -141,7 +141,7 @@ static int _md_sysfs_attribute_snprintf(char *path, size_t size,
 
 	if (MAJOR(dev) == dt->blkext_major) {
 		/* lookup parent MD device from blkext partition */
-		if (dev_get_primary_dev(dt, blkdev, &dev) < 1)
+		if (!dev_get_primary_dev(dt, blkdev, &dev))
 			return ret;
 	}
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index b28fe75..39777f1 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -203,7 +203,7 @@ int dev_subsystem_part_major(struct dev_types *dt, struct device *dev)
 		return 1;
 
 	if ((MAJOR(dev->dev) == dt->blkext_major) &&
-	    (dev_get_primary_dev(dt, dev, &primary_dev) > 0) &&
+	    dev_get_primary_dev(dt, dev, &primary_dev) &&
 	    (MAJOR(primary_dev) == dt->md_major))
 		return 1;
 
@@ -320,10 +320,24 @@ int dev_is_partitioned(struct dev_types *dt, struct device *dev)
 
 /*
  * Get primary dev for the dev supplied.
+ *
+ * We can get a primary device for a partition either by:
+ *   A: knowing the number of partitions allowed for the dev and also
+ *      which major:minor number represents the primary and partition device
+ *      (by using the dev_types->dev_type_array)
+ *   B: by the existence of the 'partition' sysfs attribute
+ *      (/dev/block/<major>:<minor>/partition)
+ *
+ * Method A is tried first, then method B as a fallback if A fails.
+ *
+ * N.B. Method B can only do the decision based on the pure existence of
+ *      the 'partition' sysfs item. There's no direct scan for partition
+ *      tables whatsoever!
+ *
  * Returns:
- *   0 if the dev is already a primary dev
- *   1 if the dev is a partition, primary dev in result
- *   -1 on error
+ *   0 on error
+ *   1 if the dev is already a primary dev, primary dev in 'result'
+ *   2 if the dev is a partition, primary dev in 'result'
  */
 int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 {
@@ -344,10 +358,10 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	if ((parts = dt->dev_type_array[major].max_partitions) > 1) {
 		if ((residue = minor % parts)) {
 			*result = MKDEV((dev_t)major, (minor - residue));
-			ret = 1;
+			ret = 2;
 		} else {
 			*result = dev->dev;
-			ret = 0; /* dev is not a partition! */
+			ret = 1; /* dev is not a partition! */
 		}
 		goto out;
 	}
@@ -370,7 +384,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 		if (errno != ENOENT)
 			log_sys_error("stat", path);
 		*result = dev->dev;
-		ret = 0; goto out; /* dev is not a partition! */
+		ret = 1; goto out; /* dev is not a partition! */
 
 	}
 
@@ -465,7 +479,7 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 			log_sys_error("stat", path);
 			return 0;
 		}
-		if (dev_get_primary_dev(dt, dev, &primary) < 0)
+		if (!dev_get_primary_dev(dt, dev, &primary))
 			return 0;
 
 		/* get attribute from partition's primary device */
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 16e2105..76d8a2d 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -130,14 +130,14 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 		return 0;
 
 	switch (dev_get_primary_dev(dt, dev, &primary_dev)) {
-		case -1:
+		case 0:
 			/* Error. */
 			log_error("Failed to get primary device for %d:%d.", major, minor);
 			return 0;
-		case 0:
+		case 1:
 			/* The dev is already a primary dev. Just continue with the dev. */
 			break;
-		case 1:
+		case 2:
 			/* The dev is partition. */
 			name = dev_name(dev); /* name of original dev for log_debug msg */
 


